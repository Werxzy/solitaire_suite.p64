--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-07-17 07:25:18",revision=3141]]

include "suite_scripts/confetti.lua"
include "cards_api/card_gen.lua"

-- updates card size if it changed
card_width = 45
card_height = 60

all_suit_colors = {
	{1, 1,16,12},
	{8, 24,8,14},
	{21, 21,18,13},
	{25, 4,25,9}
}

-- alternate color settings that have spades/clubs and hearts/diamonds match
all_suit_colors_matching = {
	{1, 1,16,12},
	{8, 24,8,14},
	{1, 1,16,12},
	{8, 24,8,14}
}

function get_card_sprite()
	return card_gen_standard({
		suits = 4, 
		ranks = rank_count, 
		suit_colors = game_save.suit_colors and all_suit_colors_matching or all_suit_colors
	})
end

rank_count = 13 -- adjustable

function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		wins = 0, suit_colors = false
	}	
		
	local card_gap = 4
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		{
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal
		})
		
	local card_back = suite_card_back()
	local card_sprites = get_card_sprite()
	
	for suit = 1,4 do
		for rank = 1,rank_count do		
			card_new({
				sprite = card_sprites[suit][rank], 
				back_sprite = card_back,
				stack = deck_stack,
				a = 0.5,
				suit = suit,
				rank = rank
			})
		end
	end
	
	stack_quick_shuffle(deck_stack)	
	
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			{
				reposition = stack_repose_normal(),
				can_stack = stack_can_rule, 
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up), 
				on_double = stack_on_double_goal
			}))
			
	end
	
	stack_goals = {}
	for i = 0,3 do
		add(stack_goals, stack_new(
			{5},
			8*(card_width + card_gap*2) + card_gap,
			i*(card_height + card_gap*2-1) + card_gap,
			{
				reposition = stack_repose_normal(0),
				can_stack = stack_can_goal, 
				on_click = stack_on_click_unstack(card_is_top)
			}))
	end
	
	
	deck_playable = stack_new(
		{5,7},
		card_gap, card_height + card_gap*3,
		{
			reposition = stack_repose_top_three,
			on_click = stack_on_click_unstack(card_is_top), 
			on_double = stack_on_double_goal
		})	

	suite_menuitem_init()
	suite_menuitem({
		text = "New Game",
		colors = {12, 16, 1}, 
		on_click = function()
			cards_api_coroutine_add(game_reset_anim)
		end
	})
	
	suite_menuitem_rules()
	
	wins_button = suite_menuitem({
		text = "Wins", 
		value = "0000"
	})
	wins_button.update_val = function(b)
		local s = "\fc"..tostr(game_save.wins)
		while(#s < 6) s = "0".. s
		b:set_value(s)
	end	
	wins_button:update_val()
	
	suite_button_simple({
		text = "Auto Place ->", 
		x = 340, y = 248, 
		on_click = function()
			cards_api_coroutine_add(game_auto_place_anim)
		end
	})
	
	cards_api_coroutine_add(game_setup_anim)
	card_position_reset_all()
end

-- deals the cards out
function game_setup_anim()
	pause_frames(30)

	for i = 1,7 do	
		for j, s in pairs(stacks_supply) do
			if j >= i then
				local c = get_top_card(deck_stack)
				if(not c) break
				
				c.a_to = j == i and 0 or 0.5
				stack_add_card(s, c)
				--sfx(3)
				pause_frames(3)
			end
		end
		pause_frames(5)
	end

	cards_api_game_started()
end

-- places all the cards back onto the main deck
function game_reset_anim()
	stack_collecting_anim(deck_stack, stacks_supply, stack_goals, deck_playable)
	pause_frames(35)
	stack_standard_shuffle_anim(deck_stack)
	
	game_setup_anim()
end


-- goes through each card and plays a card where it expects
-- easier than double clicking each card
function game_auto_place_anim()
	::again::
	pause_frames(6) -- delay between cards
	
	-- checks each of the supply stacks, starting from the closest to the goal stacks
	for i = #stacks_supply, 1, -1 do
		if stack_on_double_goal(get_top_card(stacks_supply[i])) then
			-- if found, find the next card the can be stacked on the goal
			goto again
		end
	end
	
	if stack_on_double_goal(get_top_card(deck_playable)) then
		goto again
	end
end

function game_action_resolved()
	if not get_held_stack() then
		for s in all(stacks_supply) do
			local c = get_top_card(s)
			if(c) c.a_to = 0
		end
	end
end

function game_win_anim()
	confetti_new(130,135, 100, 10)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
end

function game_win_condition()
	for g in all(stack_goals) do
		for i = 1,rank_count do
			if not g.cards[i] or g.cards[i].rank ~= i then
				return false
			end
		end
	end
	return true
end

function game_count_win()
	game_save.wins += 1
	wins_button:update_val()
	suite_store_save(game_save)
	cards_api_coroutine_add(game_win_anim)
end

-- reposition calculation that has fixed positions
function stack_repose_top_three(stack)
	local y = stack.y_to
	local len = #stack.cards - 3
	for i, c in pairs(stack.cards) do
		c.x_to = stack.x_to
		c.y_to = y
		y += i <= len and 2 or 12
	end
end

-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	if #stack.cards == 0 then
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	if c1.rank - 1 == c2.rank 
	and (c1.suit + c2.suit) % 2 == 1 then -- alternating suits (b,r,b,r) (0,1,2,3)
		return true
	end

	--if c1.rank - 1 == c2.rank then
	--	return true
	--end
end

-- expects to be stacked from ace to king with the same suit
function stack_can_goal(stack, stack2)
	
	if #stack2.cards ~= 1 then
		return false
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1] 
	
	if #stack.cards == 0 and c2.rank == 1 then
		return true
	end
	
	
	if #stack.cards > 0 and c1.rank + 1 == c2.rank and c1.suit == c2.suit then
		return true
	end
end

function stack_on_click_reveal()
	local s = deck_stack.cards
	
	-- draw 3 cards
	if #s > 0 then
		cards_api_coroutine_add(function()
			for i = 1, 3 do
				if #s > 0 then
					local c = s[#s]
					stack_add_card(deck_playable, c)
					c.a_to = 0
					pause_frames(10)
				end
			end
		end)
		
	-- put stack of cards back
	else
		local s = deck_playable.cards
		while #s > 0 do
			local c = s[#s]
			stack_add_card(deck_stack, c)
			c.a_to = 0.5
		end
	end
end

-- attempts to place the card onto any of the goal stacks
-- returns true if successful
function stack_on_double_goal(card)
	-- only accept top card (though could work with multiple cards
	if card and (from_hand or card_is_top(card)) then 
		local old_stack = card.stack
		-- create a temporary stack containing the card
		local temp_stack = from_hand or unstack_cards(card)
		
		-- attempt to place on each of the goal stacks
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				stack_cards(g, temp_stack)
				card.a_to = 0 -- turn face up
				return true
			end
		end
			
		-- if temp stack still exists, then return card to original stack
		if temp_stack then
			stack_apply_unresolved(temp_stack)
		end
	end
end

function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		-- either rank matches, not decending by 1
		if next_card.suit == card.suit or next_card.rank+1 ~= card.rank then
			return false
		end
	
		card = next_card -- current card becomes previous card
	end
	
	return true
end

function game_draw(layer)
	if layer == 0 then
		cls(3)
	
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	confetti_update()
end

function game_settings_opened()
	suite_window_add_options("Suit Colors", function(op)
		game_save.suit_colors = op == 2
		reset_card_suit_colors()
		suite_store_save(game_save)
	end, {"4 Colors", "2 Colors"}, game_save.suit_colors and 2 or 1)
end

function reset_card_suit_colors()
	local card_sprites = get_card_sprite()
	
	for c in all(get_all_cards()) do
		c.sprite = card_sprites[c.suit][c.rank]
	end
end


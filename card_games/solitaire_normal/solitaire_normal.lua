--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-03-31 23:05:23",revision=1866]]

function game_load() -- !!! start of game load function
-- this is to prevent overwriting of game modes

include "suite_scripts/rolling_score.lua"
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

rank_count = 13 -- adjustable

cards_api_clear()
cards_api_shadows_enable(true)

function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		wins = 0
	}	
	
	local card_sprites = card_gen_standard(4, rank_count, nil, nil, all_suit_colors)

	local card_gap = 4
	for suit = 1,4 do
		for rank = 1,rank_count do		
			local c = card_new(card_sprites[suit][rank], 240,100)
			c.suit = suit
			c.rank = rank
		end
	end
	
	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			stack_repose_normal(),
			true, stack_can_rule, 
			stack_on_click_unstack(unstack_rule_decending), stack_on_double_goal))
			
	end
	
	stack_goals = {}
	for i = 0,3 do
		add(stack_goals, stack_new(
			{5},
			8*(card_width + card_gap*2) + card_gap,
			i*(card_height + card_gap*2-1) + card_gap,
			stack_repose_normal(0),
			true, stack_can_goal, stack_on_click_unstack(card_is_top)))
	end
	
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		stack_repose_static(-0.16),
		true, stack_cant, stack_on_click_reveal)
	
	deck_playable = stack_new(
		{5,7},
		card_gap, card_height + card_gap*3,
		stack_repose_top_three,
		true, stack_cant, stack_on_click_unstack(card_is_top), stack_on_double_goal)
	
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, function()
		rule_cards = nil
		suite_exit_game()
	end).always_active = true
	
	-- rules cards 
	rule_cards = rule_cards_new(135, 192, game_info(), "right")
	rule_cards.y_smooth = smooth_val(270, 0.8, 0.09, 0.0001)
	rule_cards.on_off = false
	local old_update = rule_cards.update
	rule_cards.update = function(rc)
		rc.y = rc.y_smooth(rc.on_off and 192.5 or 280.5)
		old_update(rc)
	end
	
	button_simple_text("Rules", 97, 248, function()
		rule_cards.on_off = not rule_cards.on_off
	end).always_active = true
	
	button_simple_text("Auto Place ->", 340, 248, function()
		if not cards_coroutine then
			cards_coroutine = cocreate(game_auto_place_anim)
		end
	end)

	cards_coroutine = cocreate(game_setup_anim)
	
	game_score = rolling_score_new(6, 220, 3, 3, 21, 16, 16, 4, 49, function(s, x, y)
			-- shadows
			spr(52, x, y)
			spr(51, x, y) -- a bit overkill, could use sspr or rectfill
			-- case
			spr(50, x, y)
	end)
	game_score.value = game_save.wins
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
	
	game_setup_anim()
end


-- goes through each card and plays a card where it expects
-- easier than double clicking each card
function game_auto_place_anim()
	local found = true
	
	local function find_placement(stack)
		-- create temp stack with top card
		local card = get_top_card(stack)
		if not card then
			return
		end
		local temp_stack = unstack_cards(card)
	
		-- check with each goal stack if card can be placed
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				found = true
				card.a_to = 0
				stack_cards(g, temp_stack)
				break
			end
		end
		
		-- return card to original stack
		if not found then
			stack_cards(stack, temp_stack)
		end
	end
	
	while found do
		found = false
		for i = #stacks_supply, 1, -1 do
			find_placement(stacks_supply[i])
			if found then
				break
			end
		end
		if not found then
			find_placement(deck_playable)
		end
		pause_frames(6)
	end
end

function game_action_resolved()
	if not held_stack then
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
	game_score.value += 1
	game_save.wins += 1
	suite_store_save(game_save)
	cards_coroutine = cocreate(game_win_anim)
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
		cards_coroutine = cocreate(function()
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

function stack_on_double_goal(card)
	-- only accept top card (though could work with multiple cards
	if card and card_is_top(card) then 
		local old_stack = card.stack
		-- create a temporary stack
		local temp_stack = unstack_cards(card)
		
		-- attempt to place on each of the goal stacks
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				stack_cards(g, temp_stack)
				temp_stack = nil
				break
			end
		end
			
		-- if temp stack still exists, then return card to original stack
		if temp_stack then
			stack_cards(old_stack, temp_stack)
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
	
	elseif layer == 1 then
		spr(58, 7, 207) -- wins label
		game_score:draw()
		if(rule_cards) rule_cards:draw()
		
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	game_score:update()
	confetti_update()
	if(rule_cards) rule_cards:update()
end

end -- !!! end of game load function
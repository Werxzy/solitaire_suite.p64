--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-06-19 16:48:00",revision=7624]]

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
	
	local card_back = suite_card_back()

	local card_sprites = card_gen_standard{
		suits = 4, 
		ranks = rank_count, 
		suit_colors = all_suit_colors
	}

	local card_gap = 4
	for suit = 1,4 do
		for rank = 1,rank_count do		
			local c = card_new({
				sprite = card_sprites[suit][rank], 
				back_sprite = card_back,
				x = 240,
				y = 100
			})
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
			{
				reposition = stack_repose_normal(),
				can_stack = stack_can_rule, 
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up), 
			}))
			
	end
		
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		{
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal, -- todo replace with drawing a card
		})
		
	hand_stack = stack_hand_new(
		{},
		150, 180,
		{
			hand_width = 200,
			hand_max_delta = 30,
			can_stack = function() return true end,
		})
		
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	suite_menuitem_init()
	suite_menuitem({
		text = "New Game",
		colors = {12, 16, 1}, 
		on_click = function()
			cards_coroutine = cocreate(game_reset_anim)
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
	
	suite_button_simple("Test Button", 300, 200)
	
	cards_coroutine = cocreate(game_setup_anim)
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
	
	game_setup_anim()
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
end

function game_win_condition()
	return false
end

function game_count_win()
	game_save.wins += 1
	wins_button:update_val()
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
	
	if #s > 0 then
		local c = s[#s]
		stack_add_card(hand_stack, c)
		c.a_to = 0
	end
end

function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		-- not decending by 1
		if next_card.rank+1 ~= card.rank then
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


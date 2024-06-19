--[[pod_format="raw",created="2024-03-17 19:21:13",modified="2024-06-19 16:00:29",revision=10163]]


include "suite_scripts/confetti.lua"
include "cards_api/card_gen.lua"

-- updates card size if it changed
card_width = 45
card_height = 60

rank_count = 13 -- adjustable

cards_api_clear()
cards_api_shadows_enable(true)

function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		wins = 0
	}	
	
	local card_back = suite_card_back()

	local card_gap = 4
	local card_sprites = card_gen_standard({
		suits = 4, 
		ranks = rank_count
	})
	
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
	
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		{
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal
		})
	
	deck_playable = stack_new(
		{5,7},
		card_gap, card_height + card_gap*3,
		{
			reposition = stack_repose_static(2),
			on_click = stack_on_click_unstack(card_is_top), 
			on_double = stack_on_double_goal
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
		
	suite_button_simple("Auto Place ->", 340, 248, function()
		if not cards_coroutine then
			cards_coroutine = cocreate(game_auto_place_anim)
		end
	end)
	
	cards_coroutine = cocreate(game_setup_anim)
end

-- deals the cards out
function game_setup_anim()
	pause_frames(30)

	for i = 1,5 do	
		for s in all(stacks_supply) do
			local c = get_top_card(deck_stack)
			if(not c) break
			
			stack_add_card(s, c)
			c.a_to = 0
			pause_frames(3)
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
	cards_coroutine = cocreate(game_win_anim)
end

--[[ as cool as this might be, it's expensive

!!! also doesn't use the new stack function parameters

function stack_win_anim()
	win_stack = stack_new({}, 0, 0, stack_win_reposition, false, stack_cant, stack_cant)
	for s in all(stack_goals) do
		while #s.cards > 0 do
			local c = get_top_card(s)
			stack_add_card(win_stack, c)
			c.a_to=0
			pause_frames(3)
		end
	end
end
	
function stack_win_reposition(stack)
	local dx, dy = 240 - card_width/2, 135 - card_height/2
	for i, c in pairs(stack.cards) do
		i = -i
		local r = 170
		local t = time()/9 + i/#stack.cards
		local t2 = time() + i/#stack.cards*6
		c.x_to = sin(t)*r + dx + sin(t2)  * 14
		c.y_to = cos(t)*r/2 + dy + cos(t2) * 14
	end
end
]]

-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	if #stack.cards == 0 then
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	if c1.rank - 1 == c2.rank 
	and c1.suit ~= c2.suit then
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
		stack_add_card(deck_playable, c)
		c.a_to = 0
				
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
			
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	confetti_update()
end

--[[pod_format="raw",created="2024-03-21 00:44:11",modified="2024-03-30 00:09:36",revision=2436]]


function game_load() -- !!! start of game load function
-- this is to prevent overwriting of game modes

include "suite_scripts/rolling_score.lua"
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
	
	local card_gap = 4
	local card_sprites = card_gen_standard(4, rank_count)
	
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
			true, stack_cant, 
			stack_on_click_unstack(card_is_top),
			stack_on_double_goal))
			
	end
	
	deck_stack = stack_new(
		{5,23},
		240-card_width-card_gap*2, 160,
		stack_repose_static(-0.16),
		true, stack_cant, stack_on_click_reveal)
	
	deck_goal = stack_new(
		{5,15},
		240+card_gap*2, 160,
		stack_repose_static(-0.16),
		true, stack_can_goal, stack_cant)
	
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
		
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, suite_exit_game).always_active = true
	
	-- rules cards 
	rule_cards = rule_cards_new(303, 160, game_info(), "top")
	rule_cards.y_smooth = smooth_val(300, 0.8, 0.09, 0.0001)
	rule_cards.on_off = false
	local old_update = rule_cards.update
	rule_cards.update = function(rc) 
		rc.y = rc.y_smooth(rc.on_off and 192.5 or 300)
		old_update(rc)
	end
	
	button_simple_text("Rules", 97, 248, function()
		rule_cards.on_off = not rule_cards.on_off
	end).always_active = true
	
	
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
	for a in all{stacks_supply, {deck_goal}} do
		for s in all(a) do
			while #s.cards > 0 do
				local c = get_top_card(s)
				stack_add_card(deck_stack, c)
				c.a_to = 0.5
				pause_frames(3)
			end
		end
	end
	
	pause_frames(35)
	
	game_shuffle_anim()
	game_shuffle_anim()
	game_shuffle_anim()
	
	game_setup_anim()
end

-- physically shuffle the cards
function game_shuffle_anim()
	local temp_stack = stack_new(
		nil, deck_stack.x_to + card_width + 4, deck_stack.y_to, 
		stack_repose_static(-0.16), 
		false, stack_cant, stack_cant)
		
	for i = 1, rnd(10)-5 + #deck_stack.cards/2 do
		stack_add_card(temp_stack, get_top_card(deck_stack))
	end
	
	pause_frames(30)
	
	for c in all(temp_stack.cards) do
		stack_add_card(deck_stack, c, rnd(#deck_stack.cards+1)\1+1)
	end
	for c in all(deck_stack.cards) do
		card_to_top(c)
	end
	del(stacks_all, temp_stack)
	
	pause_frames(20)
end

function game_win_anim()
	confetti_new(130,135, 100, 10)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
end

function game_win_condition()
	return #deck_goal.cards == #cards_all
end

function game_count_win()
	game_score.value += 1
	game_save.wins += 1
	suite_store_save(game_save)
	cards_coroutine = cocreate(game_win_anim)
end


function stack_on_click_reveal()
	local s = deck_stack.cards
	
	if #s > 0 then
		local c = s[#s]
		stack_add_card(deck_goal, c)
		c.a_to = 0
	end
end

-- accepts any card if nothing is in the stack.
-- otherwise requires a single card of 1 rank higher or lower than the top of the stack.
function stack_can_goal(stack, stack2)
	if #stack.cards == 0 then -- any card
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1] 
	
	local dif = (c1.rank - c2.rank) % rank_count
	
	return dif == 1 or dif == rank_count - 1
end

-- attempt to stack the top card onto the goal stack
function stack_on_double_goal(card)
	-- only accept top card (though could work with multiple cards
	if card and card_is_top(card) then 
		local old_stack = card.stack
		-- create a temporary stack
		local temp_stack = unstack_cards(card)
		
		-- attempt to place on each of the goal stacks
		if deck_goal:can_stack(temp_stack) then
			stack_cards(deck_goal, temp_stack)
		else
			stack_cards(old_stack, temp_stack)
		end
	end
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


end -- end of load
	
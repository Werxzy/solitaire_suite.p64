--[[pod_format="raw",created="2024-03-21 00:44:11",modified="2024-06-24 17:20:23",revision=2868]]


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
	local cards_all = get_all_cards()
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			5,	
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			{
				reposition = stack_repose_normal(),
				on_click = stack_on_click_unstack(card_is_top),
				on_double = stack_on_double_goal
			}))
			
	end
	
	deck_stack = stack_new(
		{5,23},
		240-card_width-card_gap*2, 160,
		{
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal
		})
	
	deck_goal = stack_new(
		{5,15},
		240+card_gap*2, 160,
		{
			reposition = stack_repose_static(-0.16),
			can_stack = stack_can_goal
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
			cards_api_coroutine_add(cocreate(game_reset_anim))
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
	
	-- extra delay to wait for the transition
	cards_api_coroutine_add(cocreate(
		function() pause_frames(50) end
	))
	cards_api_coroutine_add(cocreate(game_setup_anim))
	card_position_reset_all()
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
	stack_collecting_anim(deck_stack, stacks_supply, deck_goal)
	
	game_setup_anim()
end

function game_win_anim()
	confetti_new(130,135, 100, 10)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
end

function game_win_condition()
	local cards_all = get_all_cards()
	return #deck_goal.cards == #cards_all
end

function game_count_win()
	game_save.wins += 1
	wins_button:update_val()
	suite_store_save(game_save)
	cards_api_coroutine_add(cocreate(game_win_anim))
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
			
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	confetti_update()
end

--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-07-10 09:33:48",revision=11242]]

-- built-in card sprite generation script
include "cards_api/card_gen.lua"

-- including or fetching files next to the main file should include
-- "/game/" or "game/" at the start of the path
include "game/stack_rules.lua"



--[[
idea
5 columns, 5 prepare slots, 1 deck and 1 discard/set-slot on the left, 3 item/card slots on the right

after each action, reveal 1 card in the prepare slots
after all prepare slots are revealed, place them on top (or bottom?) of the 5 columns
	refresh replace the prepare slots
	if there's less than 5 then shuffle the discard stack and put it in the deck stack
		probably check if empty after each draw
		
a straight consists of 5 cards in a row, which are then moved to the discard pile
every straight is a point
every 7? actions that scores a point results in a multiplier increase
	after 7 actions with no scoring, reset the multiplier

new counter display for the score
	accelerates to the right number
	maybe have a smear versions of the sprite at certain speeds

after so many points, there's a level up
	either increasing suit count, increasing range of ranks, adding cards with negative effects
	
maybe rig the revealing cards, to ensure there's an even distribution

3 types of item cards can appear
	bomb, takes out column
		maybe another one that removes the top two rows?
	wild, can be used in place of any card
	
	shuffle?
	
item/card slots on the right can hold onto any item or 

after a slot has a certain amount of cards or more, there is a warning symbol
	probably have a meter to show how close it is to overflowing
	if cards are added from the prepare slots while one is overflowing, then it's game over

]]

-- some variables used for consistency
card_width = 45
card_height = 60
card_gap = 4


-- function called after the game is selected and started from the main menu
-- name must match
function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		highscore = 0 -- default save data, can store game settings here
	}	
		
	-- stack that will contain all the cards
	deck_stack = stack_new(
		{5},
		card_gap, card_gap,
		{
			reposition = stack_repose_static(-0.16),
		})
		
	-- stack that will contain all the cards
	stack_discard = stack_new(
		{5},
		card_gap, card_gap*3 + card_height,
		{
			reposition = stack_repose_static(-0.16),
		})
	
	-- get the card back sprite that the player wants to use
	local card_back = suite_card_back()

	-- generates sprites with given parameters
	card_sprites = card_gen_standard{
		suits = 4, 
		ranks = 10,
	}
	
	for i = 1,8 do
		for rank = 1,5 do
			local c = card_new({
				sprite = card_sprites[1][rank],
				back_sprite = card_back,
				stack = deck_stack,
				a = 0.5
			})
			
			-- assigns the card it's suit and rank
			c.suit = 1
			c.rank = rank
		end
	end
	
	
	stacks_supply = {}
	for i = 1,5 do
		local s = add(stacks_supply, stack_new(
			{5},
			(i + 0.5)*(card_width + card_gap*2) + card_gap, card_gap*3 + card_height, 
			{
				reposition = stack_repose_normal(),				
				can_stack = stack_can_rule, 				
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up), 			
			}))
			
		wrap_stack_resolve(s)
	end
	
	stacks_prepare = {}
	for i = 1,5 do
		add(stacks_prepare, stack_new(
			{5},
			(i + 0.5)*(card_width + card_gap*2) + card_gap, card_gap, 
			{
				reposition = stack_repose_normal(),							
			}))
			
	end
	
	-- creates 3 stack for storing extra cards
	stack_storage = {}
	for i = 1,3 do
		local s = add(stack_storage, stack_new(
			{5},
			7*(card_width + card_gap*2) + card_gap,
			(i-0.5)*(card_height + card_gap*2-1) + card_gap,
			{
				on_click = stack_on_click_unstack(),
				can_stack = can_stack_only_one,
			}))
			
		wrap_stack_resolve(s)
	end
	
	stack_off_frame = stack_new(
		{},
		-card_width*2,
		-card_height*2,
		{
			reposition = stack_repose_normal(0)
		})

	init_menus()
	
	suite_button_simple({
		text = "Drop Cards", 
		x = 8, y = 180, 
		on_click = function()
			cards_api_coroutine_add(reveal_next_card)
		end
	})
		
	-- adds a coroutine that sets up the game and prevents interaction with any of the cards
	cards_api_coroutine_add(game_setup_anim)
	
	-- resets the position of all cards
	card_position_reset_all()
end

function init_menus()
	-- initializes the menu bar
	-- will currently contain the click, exit game, and settings buttons
	suite_menuitem_init()
	
	-- new game button the resets how the game plays
	suite_menuitem({
		text = "New Game",
		colors = {12, 16, 1}, 
		on_click = function()
			-- when clicked, create a new coroutine that will control the game
			cards_api_coroutine_add(game_reset_anim)
		end
	})
	
	-- adds a button for the built in rules text box
	suite_menuitem_rules()
	
	-- adds a label for the number of wins in the game
	wins_button = suite_menuitem({
		text = "Highscore", -- name
		value = "000000" -- default value
		-- no on_click attribute means it will not do anything when clicked
	})
	
	-- function used to update the text value
	wins_button.update_val = function(b)
		local s = "\fc"..tostr(game_save.highscore)
		while(#s < 8) s = "0".. s
		b:set_value(s)
	end	
	-- updates the value on setup
	wins_button:update_val()
end

-- deals the cards out
function game_setup_anim()
	-- wait for a bit
	pause_frames(30)
	
	stack_quick_shuffle(deck_stack)

	-- deal 7 cards out
	for i = 1,4 do	
		-- for each stack
		for j, s in pairs(stacks_supply) do
			-- take the top card
			local c = get_top_card(deck_stack)
			if(not c) break
			
			c.a_to = 0
			stack_add_card(s, c)
			pause_frames(3)
		end
		-- extra pause between every row of cards dealt
		pause_frames(5)
	end
	
	game_dealout_anim()

	-- notify the api that a new game has started
	-- this is important for re-enabling card interaction
	cards_api_game_started()
end

function game_dealout_anim()
	local adding = random_least(5)
	for i, s in pairs(stacks_prepare) do
		local c = get_top_card(deck_stack)
		
		if not c then
			game_shuffle_discard()
			c = get_top_card(deck_stack)
			
			if not c then
				-- TODO: make sure this isn't possible
				-- ensure there's enough cards by constantly adding
				-- or by having a decent count added
				break
			end
		end
		
		-- assign new rank
		local new_rank = del(adding, rnd(adding))
		c.rank = new_rank
		c.sprite = card_sprites[1][new_rank]
		
		c.a_to = 0.5
		stack_add_card(s, c)
		
		pause_frames(5)
	end
	
	pause_frames(10)
	-- reveals the first card
	stacks_prepare[1].cards[1].a_to = 0
end

function game_card_drop_anim()
	for i, s in pairs(stacks_prepare) do
		local c = get_top_card(s)
		
		c.a_to = 0
		stack_add_card(stacks_supply[i], c)
		
		pause_frames(3)
	end
	
	game_dealout_anim()
end

function game_shuffle_discard()
	stack_collecting_anim(deck_stack, stack_discard)
end

-- coroutine that places all the cards back onto the main deck
function game_reset_anim()
	stack_collecting_anim(deck_stack, stacks_prepare, stacks_supply, stack_storage, stack_discard)

	game_prepare_start_cards_anim()
	
	game_setup_anim()
end

-- while all cards are inside deck_stack, put them into the starting state
-- for now, all cards are the same suit and go from 1 to 5
function game_prepare_start_cards_anim()
	-- get rid of extra cards
	while #deck_stack.cards > 40 do
		local c = get_top_card(deck_stack)
		c.a_to = 0.5
		stack_add_card(stack_off_frame, c)
		
		pause_frames(5)
	end
	
	local i = 0
	
	for c in all(deck_stack.cards) do
		c.rank = (i % 5) + 1
		c.suit = 1
		c.sprite = card_sprites[c.suit][c.rank]
		
		i += 1
	end
end

-- called any time a game action is done
function game_action_resolved()
	-- if no cards are being held
	if not get_held_stack() then
		-- check all stacks
		local m = 0
		for s in all(stacks_supply) do
			
			local r = 1
			for i = 1, 5, 1 do
				local c = s.cards[#s.cards-i+1]
				
				if c and (c.rank == r or c.rank == "wild") then
					r += 1
				else
					break
				end
			end
			
			m = max(m, r)
			
			if r == 6 then
				local s2 = s
				cards_api_coroutine_add(function()
					pause_frames(15)
					for i = 1,5 do
						stack_cards(stack_discard, unstack_cards(s2.cards[#s2.cards]))
						pause_frames(3)
					end
				end)
			end
		end		

		if action_count_up then
			action_count_up = false
			
			reveal_next_card()
		end
	end
end

function reveal_next_card()
	for i = 1,6 do
		if i == 6 then
			cards_api_coroutine_add(function()
				pause_frames(20)
				game_card_drop_anim()
			end)
			break
		end
			
		local c = stacks_prepare[i].cards[1]
		if c.a_to == 0.5 then
			c.a_to = 0
			break
		end
	end
end


-- called when the game's win condition is fulfilled
-- (yes, it's important that this is separate)
function game_count_win()
	-- increase the win count
	game_save.wins += 1
	-- update the value displayed by wins_button
	wins_button:update_val()
	-- save the game data
	suite_store_save(game_save)
	
	-- play the win animation
	cards_api_coroutine_add(game_win_anim)
end

-- primary draw function, called multiple times with layers being from 0 to 3
-- don't forget to check layer number
-- name must match
function game_draw(layer)
	-- layer 0 is below everything, screen needs to be reset here
	if layer == 0 then
		-- clear function needs to be called during layer 0
		-- or at least drawing over the entire screen
		cls(3)
	
	-- layer 1 is above all layer 1 buttons and stack sprites
	
	-- layer 2 is drawn above all cards
	end
	
	-- layer 3 and 4 are mostly reserved and are drawn above everything else 
end

-- primay update function
-- name must match
function game_update()
end



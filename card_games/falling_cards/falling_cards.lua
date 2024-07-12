--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-07-12 04:48:14",revision=12104]]

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

function game_values_reset()
	dealout_flip_count = 1
	game_score = 0
	game_combo = 1
	game_combo_decay = 0
	game_level = 1
	game_levelup = 0
	game_overload_check = false
	game_card_limit = 10
	game_over = false
end
game_values_reset()

-- function called after the game is selected and started from the main menu
-- name must match
function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		highscore = 0 -- default save data, can store game settings here
	}	
		
	-- stack that will contain all the cards
	deck_stack = stack_new(
		{1+256},
		28, 16,
		{
			reposition = stack_repose_static(-0.16),
			y_off = -5,
		})
		
	-- stack that will contain all the cards
	stack_discard = stack_new(
		{2+256},
		28, 86,
		{
			reposition = stack_repose_static(-0.16),
			y_off = -5,
		})
	
	-- get the card back sprite that the player wants to use
	local card_back = suite_card_back()

	-- generates sprites with given parameters
	card_sprites = card_gen_standard{
		suits = 4, 
		ranks = 10,
	}
	
	for i = 1,12 do
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
			{4+256},
			(i-1) * (card_width + 9) + 109, 90, 
			{
				reposition = stack_repose_normal(),				
				can_stack = stack_can_rule, 				
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up),
				y_off = -5,
			}))
			
		wrap_stack_resolve(s)
	end
	
	stacks_prepare = {}
	for i = 1,5 do
		add(stacks_prepare, stack_new(
			{3+256},
			(i-1) * (card_width + 9) + 109, 6, 
			{
				reposition = stack_repose_normal(),	
				offset = -4,						
			}))
			
	end
	
	-- creates 3 stack for storing extra cards
	stack_storage = {}
	for i = 1,3 do
		local s = add(stack_storage, stack_new(
			{1+256},
			406,
			(i-1)*(70) + 35,
			{
				on_click = stack_on_click_unstack(),
				can_stack = can_stack_only_one,
				y_off = -5,
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
	
	local b = button_new({ 
		x = 30, y = 163,
		width = 41, height = 13,
		on_click = function(b)
			if not game_over then
				apply_combo_decay()
				cards_api_coroutine_add(reveal_next_card)
				b.t = 1
			end
		end,
		draw = function(b)
			b.t = max(b.t - 0.07)
			
			local click_y = ((b.t*2-1)^2 * 2.5 - 2.5) \ 1
			rectfill(b.x, b.y, b.x+b.width, b.y+b.height, 5)
			spr(b.highlight and not game_over and 262 or 263, b.x, b.y-click_y)
			spr(279, b.x-3, b.y-2)
		end
	})
	b.t = 0
	
		
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
	highscore_button = suite_menuitem({
		text = "Highscore", -- name
		value = "000000" -- default value
		-- no on_click attribute means it will not do anything when clicked
	})
	
	-- function used to update the text value
	highscore_button.update_val = function(b)
		local s = "\fc"..tostr(game_save.highscore)
		while(#s < 8) s = "0".. s
		b:set_value(s)
	end	
	-- updates the value on setup
	highscore_button:update_val()
end

-- deals the cards out
function game_setup_anim()
	game_values_reset()

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
	for i = 1,dealout_flip_count do
		stacks_prepare[i].cards[1].a_to = 0
	end
end

function game_card_drop_anim()
	for i, s in pairs(stacks_prepare) do
		local c = get_top_card(s)
		
		c.a_to = 0
		stack_add_card(stacks_supply[i], c)	
	
		pause_frames(3)
	end
	game_overload_check = true
	
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
	--[[
	while #deck_stack.cards > 60 do
		local c = get_top_card(deck_stack)
		c.a_to = 0.5
		stack_add_card(stack_off_frame, c)
		
		pause_frames(5)
	end
	]]
	
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
		local scored = false
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
					game_score += game_combo
					game_combo += 1
					game_combo_decay = 7
				end)
				scored = true
			end
		end		

		if action_count_up then
			action_count_up = false
			
			if not scored then
				apply_combo_decay()
			end
			
			reveal_next_card()
		end
		
		if game_overload_check and not scored then
			game_overload_check = false
			
			local overloaded = {}
			for s in all(stacks_supply) do
				if #s.cards > game_card_limit then
					add(overloaded, s)
				end
			end
			if #overloaded > 0 then
				game_over_anim(overloaded)
			end
		end
	end
end

function game_over_anim(stacks)
	-- TODO, add animation of explosions on stacks
	cards_api_coroutine_add(function()
		yield()
		
		cards_api_set_frozen(true)
		
		-- new highscore
		if game_save.highscore < game_score then
			game_save.highscore = game_score
			highscore_button:update_val()
			suite_store_save(game_save)
		end
		
		game_over = true
		
		-- TEMP
		notify"game over"
	end)
end

function apply_combo_decay()
	if game_combo_decay > 0 then
		game_combo_decay -= 1
		if game_combo_decay <= 0 then
			game_combo = 1
		end
	end
end

function reveal_next_card()
	for i = 1,6 do
		if i == 6 then
			cards_api_coroutine_add(function()
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

-- primary draw function, called multiple times with layers being from 0 to 3
-- don't forget to check layer number
-- name must match
function game_draw(layer)
	-- layer 0 is below everything, screen needs to be reset here
	if layer == 0 then
		-- clear function needs to be called during layer 0
		-- or at least drawing over the entire screen
		cls(22)		

	-- layer 1 is above all layer 1 buttons and stack sprites		
	elseif layer == 1 then
	
		-- center meters
		local w = {[0]=1, 2,4,6,8,10, 14,18,22,26, 36}
		for s in all(stacks_supply) do
			local w = w[mid(#s.cards, 0, 10)]+1

			local x, y = s.x_to + 3, s.y_to - 20
			sspr(269, 0,0, w+1,14, x,y)
			sspr(268, w,0, 39-w,14, x+w,y)
		end	
		
		-- center edges
		rectfill(101, 0, 101, 269, 6)
		spr(276, 96, 69)	
		rectfill(377, 0, 377, 269, 5)
		spr(277, 377, 69)

		-- screws
		for i = 0,5 do
			spr(274, 100 + 54*i, 74)
		end
		
		-- stack boxes
		ui_boxes(14,2,2)
		ui_boxes(392,21,3)
		spr(261,400,9)
		
		-- scoring
		spr(265, 23, 185)
		ui_numbers(68, 198, min(game_score, 9999999))
		ui_numbers(68, 213, min(game_combo, 99))
		ui_numbers(68, 230, min(game_level, 99))
		
		ui_bar_levels(26, 224, game_combo_decay)
		ui_bar_levels(26, 241, game_levelup)

	-- layer 2 is drawn above all cards
	end
	
	-- layer 3 and 4 are mostly reserved and are drawn above everything else 
end

-- just to simplify the drawing calls
function ui_left_edge(x, y)
	sspr(275, 0,3, 3,11, x,y)
end
function ui_right_edge(x, y)
	sspr(275, 12,3, 3,11, x,y)
end
function ui_top_edge(x, y)
	sspr(275, 2,0, 11,4, x,y)
end
function ui_bottom_edge(x, y)
	sspr(275, 2,11, 11,10, x,y)
end

function ui_boxes(x, y, n)
	ui_top_edge(x+2, y)
	ui_top_edge(x+60, y)
	rectfill(x+14, y+3, x+60, y+3, 6) 

	for i = 0,n do
		local yi = y+i*70
		ui_left_edge(x, yi+3)
		ui_right_edge(x+70, yi+3)
		spr(273, x+4, yi+4)
		spr(273, x+62, yi+4)
	
		if i > 0 then
			rectfill(x+3, yi-58, x+3, yi+2, 6)
			rectfill(x+69, yi-58, x+69, yi+2, 5)
		end
	end
	
	local yn = y+n*70
	ui_bottom_edge(x+2, yn+11)
	ui_bottom_edge(x+60, yn+11)
	rectfill(x+13, yn+11, x+60, yn+13, 5) 
end

function ui_numbers(x, y, n)
	assert(n >= 0 and n%1 == 0, "invalid number")
	
	repeat
		local v = n%10
		n \= 10
		
		sspr(266, v*5,0, 6,10, x,y)
		
		x -= 7
	until n == 0
end

-- currently out of 7
function ui_bar_levels(x, y, n)
	local sp_x = n < 3 and 0
		or n < 5 and 6 
		or 12
	
	for i = 0,n-1 do
		sspr(267, sp_x,0, 6,4, x, y)
		x += 7
	end
end


-- primay update function
-- name must match
function game_update()
end



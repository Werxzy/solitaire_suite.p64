--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-07-17 08:05:03",revision=15066]]

-- built-in card sprite generation script
include "cards_api/card_gen.lua"

-- including or fetching files next to the main file should include
-- "/game/" or "game/" at the start of the path
include "game/stack_rules.lua"
include "game/particles.lua"

--[[
maybe later?

? bonus suit that awards x2 points, multiple cards with the bonus suit increases the bonus exponentially
]]

-- some variables used for consistency
card_width = 45
card_height = 60
card_gap = 4

bonus_card_ranks = {"wild", "bomb", "shuffle"}

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
	game_prepare_bonus = false
	game_super_bonus = false
	new_highscore_found = false
	
	game_exploded_meters = {}
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
		suits = 1, 
		ranks = 8,
		rank_chars = {"1","2","3","4","5","\^:10081e3d3f3f3f1e","?", "S"},
		suit_show = {true, true, true, true, true, false, false, false},
		face_sprites = {[6] = 24+256, [7] = 25+256, [8] = 32+256}
	}
	
	for i = 1,12 do
		for rank = 1,5 do
			card_new({
				sprite = card_sprites[1][rank],
				back_sprite = card_back,
				stack = deck_stack,
				a = 0.5,
				
				-- assign the card it's rank and suit
				suit = 1,
				rank = rank,
			})
		end
	end
	
	
	stacks_supply = {}
	for i = 1,5 do
		local s = add(stacks_supply, stack_new(
			{4+256},
			(i-1) * (card_width + 9) + 109, 90, 
			{
				reposition = stack_repose_normal(nil, nil, 140),				
				can_stack = stack_can_rule, 				
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up),
				y_off = -5,
			}))
			
		wrap_stack_resolve(s, true)
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
	
	button_new({ 
		x = 30, y = 163,
		width = 41, height = 13,
		on_click = function(b)
			if not game_over then
				apply_combo_decay()
				cards_api_coroutine_add(reveal_next_card)
				b.t = 1
					
				-- sparks
				for i = 1,5 do
					new_particles(b.x+rnd(b.width), b.y+rnd(b.height), 1, 0.5)
				end
				new_particles(b.x, b.y + b.height/2, 5, 0.8)
				new_particles(b.x+b.width, b.y + b.height/2, 5, 0.8)
			end
		end,
		draw = function(b)
			b.t = max(b.t - 0.07)
			
			local click_y = ((b.t*2-1)^2 * 2.5 - 2.5) \ 1
			rectfill(b.x, b.y, b.x+b.width, b.y+b.height, 5)
			spr(b.highlight and not game_over and 262 or 263, b.x, b.y-click_y)
			spr(279, b.x-3, b.y-2)
		end,
		t = 0
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
	highscore_button = suite_menuitem({
		text = "Highscore", -- name
		value = "0000000" -- default value
		-- no on_click attribute means it will not do anything when clicked
	})
	
	-- function used to update the text value
	highscore_button.update_val = function(b)
		local s = tostr(game_save.highscore)
		while(#s < 7) s = "0".. s
		b:set_value("\fc"..s)
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
	local adding = nil
	
	-- 3% chance that all dealt cards are bonus cards 
	-- only once per game
	if game_prepare_bonus 
	and not game_super_bonus 
	and rnd() < 0.03 
	and game_level >= 11 then
		game_super_bonus = true
		game_prepare_bonus = false
		
		adding = {}
		for i = 1,5 do
			add(adding, rnd(bonus_card_ranks))
		end
	 
	elseif game_prepare_bonus then
		game_prepare_bonus = false
		
		adding = random_least(4)
		add(adding, rnd(bonus_card_ranks))
	
	else
		adding = random_least(5)
	end

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
		
		if type(new_rank) == "number" then
			c.sprite = card_sprites[1][new_rank]
		
		elseif new_rank == "bomb" then
			c.sprite = card_sprites[1][6]
			
		elseif new_rank == "wild" then
			c.sprite = card_sprites[1][7]
			
		elseif new_rank == "shuffle" then
			c.sprite = card_sprites[1][8]
			
		end
		
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
	pause_frames(35)
	stack_shuffle_anim(deck_stack)
end

-- coroutine that places all the cards back onto the main deck
function game_reset_anim()
	stack_collecting_anim(deck_stack, stacks_prepare, stacks_supply, stack_storage, stack_discard)
	pause_frames(35)
	stack_standard_shuffle_anim(deck_stack)

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
				-- SCORING
				local s2 = s
				cards_api_coroutine_add(function()
					pause_frames(15)
					for i = 1,5 do
						stack_cards(stack_discard, unstack_cards(s2.cards[#s2.cards]))
						pause_frames(3)
					end
					
					local b = game_combo
					local sx, sy = s2.x_to + s2.width\2, s2.y_to + s2.height\2
					
					if game_combo_decay == 7 then
						new_text_particle(sx, sy - 13, 284)
						game_add_score(game_combo * 2, sx, sy)
					else
						game_add_score(game_combo, sx, sy)
					end
					
					game_combo = min(game_combo + 1, 99)
					game_combo_decay = 7
					
					sparks_on_change(71, 218, b, game_combo)
					
					inc_levelup(2)
					
					
				end)
				scored = true
			end
		end		
		
		local effect_wait = false
		if action_effect_check then
			local c = get_top_card(action_effect_check)
			local stack = action_effect_check
			
			if c.rank == "bomb" then
				cards_api_coroutine_add(function()
					pause_frames(5)
					local sx, sy = c.x_to + c.width\2, c.y_to + c.height\2
					new_explode_particle(sx, sy)
					new_particles(sx, sy, 35, 2.5)
					pause_frames(30)
					stack_collecting_anim(stack_discard, 0, stack)
					pause_frames(15)
				end)
				effect_wait = true
			end
			
			if c.rank == "shuffle" then
				cards_api_coroutine_add(function()
					
					stack_collecting_anim(stack, 0, stacks_supply)
					pause_frames(15)
					stack_add_card(stack_discard, c)
					pause_frames(15)
					
					local lowest = true
					while lowest do
						lowest = nil
						local l = #stack.cards
						for s in all(stacks_supply) do
							local l2 = #s.cards
							if s != stack and l2 < l then
								lowest = s
								l = l2
							end
						end
						if lowest then
							stack_add_card(lowest, rnd(stack.cards))
						end
						pause_frames(3)
					end
					
					pause_frames(15)
					
					for s in all(stacks_prepare) do
						local c = get_top_card(s)
						if c.a_to == 0 then
							c.a_to = 0.5
							reveal_spark(s)
							pause_frames(15)
						end
					end	
			
				end)
				effect_wait = true
			end
			
			action_effect_check = false
		end
		
		-- if a bonus card is needing to take effect, the wait until after the animations
		if not effect_wait then
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
				for i, s in pairs(stacks_supply) do
					if #s.cards > game_card_limit then
						add(overloaded, {i, s})
					end
				end
				if #overloaded > 0 then
					game_over_anim(overloaded)
				end
			end
		end
	end
end

function game_over_anim(stacks)
	cards_api_coroutine_add(function()

		cards_api_set_frozen(true)
		game_over = true
		
		for s in all(stacks) do
			game_exploded_meters[s[1]] = true
			
			local s = s[2]
			local sx, sy = s.x_to + s.width\2, s.y_to - 17
			new_explode_particle(sx, sy)
			new_particles(sx, sy, 35, 2.5)
			pause_frames(40)
		end
		
		new_text_particle(240, 180, 278, 120)
	end)
end

function apply_combo_decay()
	if game_combo_decay > 0 then
		game_combo_decay -= 1
		if game_combo_decay <= 0 then
			sparks_on_change(71, 218, game_combo, 1)
			game_combo = 1
		end
	end
end

function reveal_next_card(spark)
	for i = 1,6 do
		if i == 6 then
			cards_api_coroutine_add(function()
				if spark then
					foreach(stacks_prepare, reveal_spark)
				end
				game_card_drop_anim()
			end)
			break
		end
		
		local s = stacks_prepare[i]
		local c = s.cards[1]
		if c.a_to == 0.5 then
			c.a_to = 0
			
			if spark then
				reveal_spark(s)
			end
			break
		end
	end
end

function reveal_spark(s)
	local sx, sy = s.x_to + s.width\2, s.y_to + s.height\2
	new_text_particle(sx, sy, 287)
	new_particles(sx, sy, 10, 1)
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
		for i, s in pairs(stacks_supply) do
			local x, y = s.x_to + 3, s.y_to - 20
			
			if game_exploded_meters[i] then
				spr(270, x, y)
				
			else
				local wi = mid(#s.cards, 0, 10)
				if wi == 10 and time()%1 < 0.333 then -- flash the last light
					wi -= 1
				end
				local w = w[wi]+1
				
				sspr(269, 0,0, w+1,14, x,y)
				sspr(268, w,0, 39-w,14, x+w,y)
			end
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
	elseif layer == 2 then
		particles_draw()
	
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
--[[
	local mx, my, mb = mouse()
	if mb&1 == 1 and lastmb&1 == 0 then
		new_particles(mx, my, 3, 0.5)
	end
	lastmb = mb
]]
	particles_update()
end
--local lastmb = 0


function inc_levelup(n)
	game_levelup += n
	if game_levelup >= 8 then
		local a = game_level
		game_level = min(game_level+1, 99)
		game_levelup -= 8
		
		new_text_particle(50, 215, 285)
		sparks_on_change(71, 235, a, game_level)
		
		if game_level % 2 == 0 then
			game_prepare_bonus = true
		end
		
		-- increase difficulty by increasing the starting amount of revealed cards
		if game_level == 15 
		or game_level == 30
		or game_level == 45
		or game_level == 60 then
			dealout_flip_count += 1
		end
		
		-- reveal cards on level up, half the previous level rounded up
		local flip_n = min(game_level\2, 5)
		local function add_next()
			if flip_n > 0 then
				flip_n -= 1
				cards_api_coroutine_add(function()
					reveal_next_card(true)
					pause_frames(5)
					add_next()
				end)
			end
		end
				
		add_next()
	end
end

function game_add_score(n, x, y)
	local a = game_score
	game_score += n
	
	new_text_particle(x, y, tostr(n))
	new_particles(x, y, 15, 1.5)
	
	-- store highest score
	if game_score > game_save.highscore then
		if not new_highscore_found then
			new_highscore_found = true
			new_text_particle(50, 200, 286)
		end
		game_save.highscore = game_score
		highscore_button:update_val()
		suite_store_save(game_save)	
	end
	
	sparks_on_change(71, 203, a, game_score)
end
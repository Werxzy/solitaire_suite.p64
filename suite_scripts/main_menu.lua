--[[pod_format="raw",created="2024-03-19 15:14:10",modified="2024-07-14 11:36:55",revision=22860]]

include"cards_api/card_gen.lua"
--#if not example
include"suite_scripts/suite_mod_window.lua"
--#end

-- this isn't actually a game, but still uses the cards api, but instead a menu for all the game modes and options

cards_api_clear()
cards_api_shadows_enable(true)
main_menu_selected = nil
cards_animated = {} -- clears animated card backs to prevent overflowing memory

-- stores the original display palette just in case a custom game changes it.
if original_display_palette then
	poke(0x5000, unpack(original_display_palette))
else
	original_display_palette = {peek(0x5000, 0x400)}
end


local x_offset = smooth_val(0, 0.5, 0.1)

function update_all_assets()
	
	-- initializes the list of game variant folders
	game_list = {}
	--#if not example
	for loc in all{"card_games", suite_save_folder .. "/card_games"} do
		local trav = folder_traversal(loc)
	--[[#else
		local trav = folder_traversal("card_games")
	--#end]]
	
		for p in trav do
			-- find any game info files
			if trav("find", "game_info.lua") then
				local op = add(game_list, {p:dirname(), p:basename()})
				trav"exit" -- don't allow 
			end
		end
		
	--#if not example
	end
	--#end
	
	-- clear original animated card backs	
	cards_animated = {}

	-- initializes the card back info
	all_card_back_info = {}
	for loc in all{"card_backs", suite_save_folder .. "/card_backs"} do 
		local trav = folder_traversal(loc)
		local e = cap_env()
		
		for p in trav do
			for cb in all(ls(p)) do
				e.get_info = nil
				local p2 = p .. "/" .. cb
				
				if fstat(p2) == "file" and cb:ext() == "lua" then
					local ok, err1, err2 = cap_load(p2, e)
					
					-- send message of the file's error
					if not ok then
						cards_api_display_error(err1, err2)
					
					elseif e.get_info then
						for info in all(e.get_info()) do
							if type(info.sprite) == "function" then
								card_back_animated(info)
							end
							
							add(all_card_back_info, info)
						end
					end
				end
			end
		end
	end
	
	-- make sure the card back in question is available
	set_card_back(has_key(all_card_back_info, "id", settings_data.card_back_id) or rnd(all_card_back_info))
	
	-- initializes the ui for the assets
	update_game_options()
	update_card_back_options()
end

function update_game_options()
	-- cleanup
	main_menu_selected = nil
	for b in all(game_mode_buttons) do
		b:destroy()
	end

	-- creates buttons for each game mode
	game_mode_buttons = {}
	local bx = 2
	
	local all_info = {}
	
	for game in all(game_list) do
		local p, n = unpack(game)
		
		local info_path = p .. "/" .. n .. "/game_info.lua"
		local info, err1, err2 = get_game_info(info_path)()
		
		if not info then
			cards_api_display_error(err1, err2)
	
		elseif info.api_version == api_version_expected then
			local op = add(all_info, info)	
			op.order = op.order or 999999
			op.game = p .. "/" .. n .. "/" .. n .. ".lua"	
			op.info_path = info_path
		end
	end
	
	quicksort(all_info, "order")
	
	for info in all(all_info) do
		
		-- grab sprite 0 from 1.gfx if there is one for the game
		if not info.sprite then
			local extra_sprite = fetch(info.info_path:dirname() .. "/1.gfx")
			if extra_sprite then
				info.sprite = extra_sprite[0].bmp
			else
				info.sprite = 32
			end
		end
		
		-- if a number is provided for the sprite, use get_spr to allow for :width()
		if type(info.sprite) == "number" then
			info.sprite = get_spr(info.sprite)
		end
		
		local b = add(game_mode_buttons, 
			button_new({
				x = bx, y = 100 - info.sprite:height() + 78, 
				width = info.sprite:width(), 
				height = info.sprite:height(),
				draw = button_deckbox_draw, 
				on_click = button_deckbox_click
			})
		)
			
		b.sprite = info.sprite
		b.game = info.game
		b.info_path = info.info_path
		b.info = info
		b.x_old = bx
		
		bx += info.sprite:width() + 10
	end
	
	if #game_mode_buttons > 1 then
		local third = game_mode_buttons[3] or game_mode_buttons[1]
		x_offset("pos", 240 - third.sprite:width() - 5 - third.x_old)
	else
		local first = game_mode_buttons[1]
		x_offset("pos", 240 - first.sprite:width()\2 - 1 - first.x_old)
	end
		
	button_deckbox_click()
end

function update_card_back_options()
	-- cleanup step
	
	-- delete all original cards and stacks
	local cs = get_all_cards()
	for c in all(cs) do
		c.stack = nil
		del(cs, c)
	end
	local st = get_all_stacks()
	for s in all(st) do
		del(st, s)
	end
	

	-- init step
	
	card_back_edit_button = stack_new(
		{10}, 300, 190, 
		{
			reposition = stack_repose_normal(),
			can_stack = function() return true end, 
			on_click = function(c)
				stack_on_click_unstack()(c)
				main_menu_y_to = 1
			end,
			resolve_stack = swap_stacks,
			x_off = -12,
			y_off = -13,
		})
		

	local cb_sprite = suite_card_back()
	local cb = has_key(all_card_back_info, "id", settings_data.card_back_id)
	local cb_front = cb.gen and cb.gen() or card_gen_back({sprite = cb.sprite})
			
	local c = card_new({
			sprite = cb_front, 
			back_sprite = cb_sprite,
			x = 300,
			y = 190
		})
	c.info = card_back
	stack_add_card(card_back_edit_button, c)
	

	local card_width = 45
	local card_height = 60 
	
	local function create_card_back_stack(i)
		local s = stack_new(
			{9},
			(i\2)*(60) + 7, 365 + i%2 * (card_height + 10) + 17, 
			{
				reposition = stack_repose_normal(),
				can_stack = function(stack) 
					if #card_back_edit_button.cards == 0 then
						return #stack.cards == 1
					end
					return true
				end, 
				on_click = stack_on_click_unstack(),
				resolve_stack = swap_stacks,
				x_off = -7,
				y_off = -4,
			})
		s.base_x = s.x_to
			
		return add(card_back_options, s)
	end

-- adds card back options
	card_back_options = {}
	for cb in all(all_card_back_info) do
		if cb.id ~= card_back.id then
			local s = create_card_back_stack(#card_back_options)
			
			local front_sprite = nil
				
			if cb.gen then
				front_sprite = cb.gen()	
			else
				front_sprite = card_gen_back({sprite = cb.sprite})
			end
			
			
			local c = card_new({
				sprite = front_sprite,
				back_sprite = cb_sprite,
				stack = s
			})
			c.info = cb
		end
	end
	
-- adds extra card back slots for looks
	local extra = 0
	while #card_back_options < 16 
	or #card_back_options % 4 ~= 0
	or extra < 4 do
		extra += 1
		create_card_back_stack(#card_back_options)
	end
	card_back_scroll_max = min(480 - #card_back_options \ 2 * 60)
	for i = -4,-1 do
		create_card_back_stack(i)
	end
end


function box_shadow(x1, y1, x2, y2)
	-- draw shadows, based on the the boxes size
	-- 32 is the shadow applying color
	fillp(0xa5a5a5a5)
	rect(x1,y1,x2,y2, 32)
	rect(x1+1,y1+1,x2-1,y2-1)
	rectfill(x1+4,y1+4,x2-4,y2-4)
	fillp()
	rectfill(x1+2,y1+2,x2-2,y2-2)
end

function button_deckbox_draw(b)
	box_shadow(b.x-3, b.y+10, b.x+b.width+2, b.y+b.height+2)
	
	-- interpolates the draw position
	b.y2 = lerp(b.y2 or 0, (b.highlight and 3 or 0) + (b == main_menu_selected and 8 or 0), 0.15)
	-- didn't want to do lerp, but it's simpler here >:(
	spr(b.sprite, b.x, b.y - (b.y2 + 0.5)\1)
end

function button_deckbox_click(b)
	main_menu_selected = b
	--rule_cards.info = b.info
	--rule_cards.page = 0
	
	local s = get_spr(21)
	local w, h = s:width(), s:height()
	game_description = userdata("u8", w, h)
	
	local old_x, old_y = camera()	
	set_draw_target(game_description)
	
	rectfill(3, 3, w-3, h-3, 7)
	
	-- give info
	if b and b.info then
		local info = b.info
		
		local x = print_size(info.name)
		double_print(info.name, 179/2-x/2+4, 7, 2)
		
		local by = "\nBy " .. info.author
		local x = print_size(by)
		double_print(by, 179/2-x/2+4, 7, 1)
		
		local s =  "\n\n" .. info.description
		local loreprint, lw, lh = print_wrap_prep(s, 175)
		double_print(loreprint, 6, 7, 1)
		
		if info.desc_score then
			local sc = info.desc_score
			
			local vals = {}
			local save = fetch(suite_save_folder .. "/saves/"
				.. suite_get_game_name(info.game) .. ".pod") or {}
	
			for p in all(sc.param) do
				add(vals, save[p] or 0)
			end
						
			local s = string.format(sc.format, unpack(vals))
			double_print(s, 6, 64, 1)
			
			fillp(0xa5a5a5a5a5a5a5a5)
			rect(1,61,w,61,32)
			fillp()
		end
		
	-- say click to get description
	else
		local s =  "Click a deck box to see information about it."
		local loreprint, lw, lh = print_wrap_prep(s, 175)
		double_print(loreprint, 6, 7, 1)
	end
	
	rect(4,5,w-5,h-2, 32)
	spr(21)
	
	set_draw_target()
	camera(old_x, old_y)	
end


function set_card_back(info)
	card_back = info
	assert(info)
	
	suite_card_back_set(info)
	
	if cards_all and cards_all[1] then
		local old_sp = cards_all[1].back_sprite
		if old_sp.destroy then
			old_sp:destroy()
		end
	end
	
	local sp = suite_card_back()
	for c in all(cards_all) do
		c.back_sprite = sp
	end
	
	settings_data.card_back_id = info.id
	suite_store_save(settings_data)
end

local function card_button_draw(button)
	local left = button.highlight and 6 or 0
	button.t = lerp(button.t, left, 0.2)
	nine_slice(8, button.x + button.t, button.y + button.off, button.width, 45)
	double_print(button.str, button.x2 + button.t, button.y+3, button.col)
end

local function card_button_new(str, col, y, on_click, offset)
	local b = button_new({
		x = 205, y = y, 
		width = 65, height = 13, 
		draw = card_button_draw, 
		on_click = on_click
	})
	b.str = str
	b.col = col
	b.x2 = b.x + (b.width - print_size(str)) \ 2
	b.t = 0
	b.off = offset or 0
end


function game_setup()

	settings_data = suite_load_save() or {
		card_back_id = 1
	}

	main_menu_y = smooth_val(0, 0.8, 0.023, 0.00001)
	main_menu_y_to = 0
	
	local cb = {
		{"Start Game", 8, 
			function() 
				if main_menu_selected then
					last_selected_game = main_menu_selected.info_path
					game_info = get_game_info(main_menu_selected.info_path)
					suite_load_game(main_menu_selected.game)
				end
			end
		},
--#if not example
		{"Manage Mods", 16, suite_open_mod_manager},
--#end
		{"Settings", 27, suite_open_settings},
		{"Exit Game", 25, stop},
	}
	for i, d in pairs(cb) do
		local f = d[3]
		
		-- prevent buttons from being clicked when the camera is moving
		d[3] = function(...)
			if abs(main_menu_y"vel") < 0.01 then
				f(...)
			end
		end
		
		card_button_new(d[1], d[2], 185 + (i-1 + 4-#cb)*13, d[3])
	end
			
	card_button_new("Return", 16, 310, 
		function() 
			main_menu_y_to = 0
		end, -30)
	
	
	
-- adds card back scrolling buttons
	card_back_scroll_to = 0
	card_back_scroll = smooth_val(0, 0.7, 0.04, 0.05)

	local function scroll(x)
		return function (b)
			b.t = 1
			card_back_scroll_to = mid(120, card_back_scroll_to + x, card_back_scroll_max)
		end
	end
	
	local function draw_button(b)
		b.t = max(b.t - 0.07)
		local y = ((b.t*2-1)^2 * 2.5 - 1.5) \ 1
		local h = 20 + y
		spr(2, b.x-4, b.y-2)
		sspr(b.highlight and 4 or 3, 0, 0, 21, h, b.x, b.y-y, 21, h, b.fl)
	end

	local b = button_new({
		x = 215, y = 335, 
		width = 20, height = 21, 
		draw = draw_button, 
		on_click = scroll(120)
	})
	b.t = 0
	b.fl = true
	
	local b = button_new({
		x = 245, y = 335, 
		width = 20, height = 21, 
		draw = draw_button, 
		on_click = scroll(-120)
	})
	b.t = 0
	

	update_all_assets()
	

	-- if there's only one game, auto select it
	if #game_mode_buttons == 1 then
		game_mode_buttons[1]:on_click()
		menu_selected_inst = true
	end
	
	if last_selected_game then
		for b in all(game_mode_buttons) do
			if b.info_path == last_selected_game then
				b:on_click()
				menu_selected_inst = true
				last_selected_game = nil
			end
		end
	end
end

-- also updates the card back
function swap_stacks(stack, stack2)
	local old_cards = {}
	local old_stack = stack2.old_stack
	
	for c in all(stack2.cards) do
		add(old_cards, c)
	end
	
	for c in all(stack.cards) do
		add(old_stack.cards, del(stack.cards, c))
		card_to_top(c)
		c.stack = old_stack
	end
	
	for c in all(old_cards) do
		add(stack.cards, del(stack2.cards, c))
		card_to_top(c)
		c.stack = stack
	end
	
	stack2.old_stack = nil
	
	if not stack2.perm then
		del(stacks_all, stack2)
	end
	
	set_card_back(card_back_edit_button.cards[1].info)
end

function game_update()
	local x_to = main_menu_selected and 240 - main_menu_selected.sprite:width()/2 - main_menu_selected.x_old or x_offset()
	local x = x_offset(x_to) 
		
	-- instantly move to the position of the selected box
	if menu_selected_inst then
		x_offset("pos", x_to)
		x_offset("vel", 0)
		menu_selected_inst = false
	end
		
	for b in all(game_mode_buttons) do
		b.x = x + b.x_old
	end
	
	main_menu_y(main_menu_y_to)
	
	local new_to = lerp(196.5, 281.5, main_menu_y())\1
	local d_to = new_to - card_back_edit_button.y_to
	card_back_edit_button.y_to = new_to
	for c in all(card_back_edit_button.cards) do
		c.y("pos", c.y() + d_to)
	end
	
	
	local sc = card_back_scroll(card_back_scroll_to)\1

	for s in all(card_back_options) do
		local newx = s.base_x + sc
		local dx = newx - s.x_to
		s.x_to = newx
		
		for c in all(s.cards) do
			c.x("pos", c.x() + dx)
		end
	end
end

function game_draw(layer)
	if layer == 0 then		
		
-- example color palette
--#if not example
		cls(3)
		
--[[#else
		-- EDIT THIS (remove, or adjust colors)
		--normally cls(3)
		cls(18)
		pal(3,18) 
		pal(27,13) 
		pal(19,2)
		pal(11,29)
--#end]]
	
		local cy = main_menu_y() * 260.5
		camera(0, cy)	
		spr(22, 121, 2) -- feel free to replae this this
	
		-- keep this, it's based on the suite version
		print("Version " .. game_version, 1, 262, 19)
		
--[[#if example
	-- but please keep this in some fashion
	print("Made with Picotron", 390, 230)
	print("Solitaire Suite", 399, 240)
--#end]]
		print("Mostly by Werxzy", 399, 261)
		
--#if not example

--[[#else
		-- EDIT THIS (remove or edit colors)
		print("EXAMPLE PROJECT", 160, 85)
		pal(3,3)
		pal(27,27)
		pal(19,19)
		pal(11,11)
--#end]]
		
	-- card back info
		local full_w = 187 - 12
		local x, y = 10, 283
		
		local s = "Artist : " .. card_back.artist
		local w = print_size(s)
		local loreprint, lw, lh = print_wrap_prep(card_back.lore, full_w)
		
		rectfill(x + 2, y + 2, x + 185, y + 76, 7)
		
		double_print(s, full_w/2 + x + 6 - w/2, y + 12, 1)
		double_print(loreprint, full_w/2 + x + 6 - lw/2, y + 28, 1)
		
		rect(x + 4, y + 5, x + 182, y + 76, 32)	
		spr(21, 10, y)	
		

	-- game info
		spr(game_description, 8, 182)
		
	-- card back selection details
		rectfill(0, 518, 480, 519, 3)
		rectfill(0, 530, 480, 540, 21)
		for i = 0, 479,175  do
			spr(12, i, 364)
			spr(12, i, 520)
		end
			
		local sc = card_back_scroll()\1
		local i2 = sc - sc % 78
		for i = -78-i2, 479-i2,78  do
			spr(11, i+sc, 372)
		end
		
	elseif layer == 1 then
		box_shadow(203, 241-3, 203+73, 241+12)
		box_shadow(203-3, 260, 203+73+3, 309)
		spr(1, 203, 241)
	end
	
end


function cards_game_exiting()
	suite_load_game"suite_scripts/main_menu.lua"
end


function game_on_error()
	-- call's the subgame's original game_on_error function, if provided
	if (subgame_on_error) subgame_on_error()
	suite_load_game"suite_scripts/main_menu.lua"
end


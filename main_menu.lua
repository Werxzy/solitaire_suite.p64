--[[pod_format="raw",created="2024-03-19 15:14:10",modified="2024-03-28 02:00:12",revision=8337]]

include"cards_api/rule_cards.lua"

cards_api_save_folder = "/appdata/solitaire_collection"
game_version = "0.1.0"
api_version_expected = 1

-- this isn't actually a game, but still uses the cards api, but instead a menu for all the game modes and options

function game_load() -- similar to game_load, but we always want this available

cards_api_clear()
cards_api_shadows_enable(true)
main_menu_selected = nil

mkdir(cards_api_save_folder .. "/card_games")
mkdir(cards_api_save_folder .. "/card_backs")

-- initializes the list of game variant folders
game_list = {}
for loc in all{"card_games", cards_api_save_folder .. "/card_games"} do
	local trav = folder_traversal(loc)
	for p in trav do
		-- find any game info files
		if trav("find", "game_info.lua") then
			local op = add(game_list, {p:dirname(), p:basename()})
			trav"exit" -- don't allow 
		end
	end
end


all_card_back_info = {}

for loc in all{"card_backs", cards_api_save_folder .. "/card_backs"} do 
	local trav = folder_traversal(loc)
	for p in trav do
		for cb in all(ls(p)) do
			include(p .. "/" .. cb)
			for info in all(get_info()) do
				
				if type(info.sprite) == "function" then
					info = card_back_animated(info.sprite, info)
					info.update(true)
				end
				
				add(all_card_back_info, info)
			end
		end
	end
end


local x_offset = smooth_val(0, 0.5, 0.1)

function button_deckbox_draw(b)
	
	-- draw shadows, based on the the boxes size
	-- 32 is the shadow applying color
	local x1, y1, x2, y2 = b.x-3, b.y+10, b.x+b.w+2, b.y+b.h+2
	fillp(0xa5a5a5a5)
	rect(x1,y1,x2,y2, 32)
	rect(x1+1,y1+1,x2-1,y2-1, 32)
	rectfill(x1+4,y1+4,x2-4,y2-4, 32)
	fillp()
	rectfill(x1+2,y1+2,x2-2,y2-2, 32)
	
	-- interpolates the draw position
	b.y2 = lerp(b.y2 or 0, (b.highlight and 3 or 0) + (b == main_menu_selected and 8 or 0), 0.15)
	-- didn't want to do lerp, but it's simpler here >:(
	spr(b.sprite, b.x, b.y - (b.y2 + 0.5)\1)
end

function button_deckbox_click(b)
	main_menu_selected = b
	rule_cards.info = b.info
	rule_cards.page = 0
end

function set_card_back(info)
	card_back = info
	assert(info)
	settings_data.card_back_id = info.id
	cards_api_save(settings_data)
end

function game_setup()

	settings_data = cards_api_load() or {
		card_back_id = 1
	}

	set_card_back(has_key(all_card_back_info, "id", settings_data.card_back_id) or rnd(all_card_back_info))
	
	main_menu_y = smooth_val(0, 0.8, 0.023, 0.00001)
	main_menu_y_to = 0

	-- creates buttons for each game mode
	game_mode_buttons = {}
	local bx = 2
	
	local all_info = {}
	
	for game in all(game_list) do
		local p, n = unpack(game)
		
		local info_path = p .. "/" .. n .. "/game_info.lua"
		if include(info_path) then
			local op = add(all_info, game_info())	
			op.order = op.order or 999999
			op.game = p .. "/" .. n .. "/" .. n .. ".lua"	
			op.info_path = info_path
		end
	end
	
	quicksort(all_info, "order")

	for info in all(all_info) do
				
		if type(info.sprite) == "number" then
			info.sprite = get_spr(info.sprite)
		end
		
		local b = add(game_mode_buttons, 
			button_new(bx, 100, 
				info.sprite:width(), info.sprite:height(), 
				button_deckbox_draw, 
				button_deckbox_click)
			)
			
		b.sprite = info.sprite
		b.game = info.game
		b.info_path = info.info_path
		b.info = info
		b.x_old = bx
		
		bx += info.sprite:width() + 10
	end
	
	local third = game_mode_buttons[3]
	x_offset("pos", 240 - third.sprite:width() - 5 - third.x_old)
	
	set_draw_target(userdata("u8", 1, 1)) -- TEMP : draw target isn't initialized? print doesn't return any values
	
	button_center(button_simple_text("Start Game", 200, 200, 
		function() 
			if main_menu_selected then
				rule_cards = nil
				include(main_menu_selected.info_path)
				cards_api_load_game(main_menu_selected.game)
			end
		end))
	
	button_center(button_simple_text("Exit Game", 200, 220, exit))
	
	button_simple_text("Back", 355, 270, 
		function() 
			main_menu_y_to = 0
		end)
		
	rule_cards = rule_cards_new(22, 186)
	
	set_draw_target()
	
	card_back_edit_button = stack_new(
		{5},
		300, 200, 
		stack_repose_normal(),
		true, function() return true end, 
		function(c)
			stack_on_click_unstack()(c)
			main_menu_y_to = 1
		end)
		
	card_back_edit_button.resolve_stack = swap_stacks
	
	stack_add_card(card_back_edit_button, card_new(card_back, 300, 200))
	
	card_back_options = {}
	for cb in all(all_card_back_info) do
		if cb.id ~= card_back.id then
			local i = #card_back_options
			local s = add(card_back_options, stack_new(
				{5},
				 i*(card_width + 10)/2 + 10, 365 + i%2 * (card_height + 10), 
				stack_repose_normal(),
				true, function() return true end, 
				stack_on_click_unstack()))
			s.resolve_stack = swap_stacks
			
		
			local c = card_new(cb, s.x_to, s.y_to)
			c.info = cb
			stack_add_card(s,  c)
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
	
	set_card_back(card_back_edit_button.cards[1].sprite)
end

function game_update()
	local x = main_menu_selected 
		and x_offset(240 - main_menu_selected.sprite:width()/2 - main_menu_selected.x_old)
		or x_offset(x_offset())
		
	for b in all(game_mode_buttons) do
		b.x = x + b.x_old
	end
	
	main_menu_y(main_menu_y_to)
	
	card_back_edit_button.y_to = lerp(200.5, 280.5, main_menu_y())
end

function game_draw(layer)
	if layer == 0 then
	
		for c in all(cards_all) do -- update all card_backs
			if c.sprite.update and c.sprite ~= c.card_back then
				c.sprite.update()
			end
		end	

		cls(3)
		
	
		local cy = main_menu_y() * 260.5
		camera(0, cy)	
		spr(22, 121, 2)
	
		print("Version " .. game_version, 1, 262, 19)
		print("Mostly by Werxzy", 399, 261)
		
	-- card back info
		local s = "Artist : " .. card_back.artist
		
		local x = print(s, 0, -1000) 
		local w = x + 10
		
		local x1, y1, x2, y2 = 200 - w/2, 290, 240 + w/2, 308
		local truew = x2-x1
		local lw, lh, loreprint = print_wrap_prep(card_back.lore, truew-5)
		nine_slice(8, x1, y1, x2-x1, y2-y1 + lh)
		--rectfill(x1, y1, x2, y2, 7)
		
		
		double_print(s, 220 - x/2, 295, 1)
		
		double_print(loreprint, x1+4 + (truew-lw-5)/2, y1+16, 1)
		
		nine_slice(8, 275, 345, 97, 15)
		double_print("Selected Card Back", 280, 348, 1)
		

	-- game info
		rule_cards:draw()
	end
end

function cards_game_exiting()
	cards_api_load_game"main_menu.lua"
end

end -- end of load

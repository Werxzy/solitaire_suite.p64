--[[pod_format="raw",created="2024-03-19 15:14:10",modified="2024-03-20 22:09:48",revision=4544]]

game_version = "0.1.0"

include"cards_api/card_backs.lua"

-- this isn't actually a game, but still uses the cards api, but instead a menu for all the game modes and options


function game_load() -- similar to game_load, but we always want this available

cards_api_clear()
cards_api_shadows_enable(true)
main_menu_selected = nil

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
end

function set_card_back(info)
	current_card_back_info = info
	card_back = info.sprite
	settings_data.card_back_id = info.id
	cards_api_save(settings_data)
end

function game_setup()

	settings_data = cards_api_load() or {
		card_back_id = 1
	}

	set_card_back(has_key(card_back_info, "id", settings_data.card_back_id) or rnd(card_back_info))
	
	main_menu_y = smooth_val(0, 0.8, 0.023, 0.00001)
	main_menu_y_to = 0

	-- creates buttons for each game mode
	game_mode_buttons = {}
	local bx = 2
	
	for game in all(game_list) do
	
		-- game exists
		if include(game) then 
		
			-- get info provided by game
			info = game_info()
			
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
			b.game = game
			b.info = info
			b.x_old = bx
			
			bx += info.sprite:width() + 10
		end
	end
	
	local first = game_mode_buttons[1]
	x_offset("pos", 240 - first.sprite:width()/2 - first.x_old)
	
	set_draw_target(userdata("u8", 1, 1)) -- TEMP : draw target isn't initialized? print doesn't return any values
	
	button_center(button_simple_text("Start Game", 200, 200, 
		function() 
			if main_menu_selected then
				cards_api_load_game(main_menu_selected.game)
			end
		end))
	
	button_center(button_simple_text("Exit Game", 200, 220, exit))
	
	button_simple_text("Back", 355, 270, 
		function() 
			main_menu_y_to = 0
		end)
		
	
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
	
	card_back_selected = card_new(card_back, 300, 200)
	card_back_selected.info = current_card_back_info
	stack_add_card(card_back_edit_button, card_back_selected)
	
	card_back_options = {}
	for cb in all(card_back_info) do
		if cb.id ~= current_card_back_info.id then
			local i = #card_back_options
			local s = add(card_back_options, stack_new(
				{5},
				 i*(card_width + 10)/2 + 10, 365 + i%2 * (card_height + 10), 
				stack_repose_normal(),
				true, function() return true end, 
				stack_on_click_unstack()))
			s.resolve_stack = swap_stacks
			
		
			local c = card_new(cb.sprite, s.x_to, s.y_to)
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
	
	set_card_back(card_back_edit_button.cards[1].info)
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
		cls(3)
		local cy = main_menu_y() * 260.5
		camera(0, cy)	
	
		print("Version " .. game_version, 1, 262, 19)
		print("Mostly by Werxzy", 399, 261)
		
		local s = "Artist : " .. current_card_back_info.artist
		
		local x = print(s, 0, -1000) 
		local w = x + 10
		
		local x1, y1, x2, y2 = 200 - w/2, 290, 240 + w/2, 308
		local truew = x2-x1
		local lw, lh, loreprint = print_wrap_prep(current_card_back_info.lore, truew-5)
		nine_slice(8, x1, y1, x2-x1, y2-y1 + lh)
		--rectfill(x1, y1, x2, y2, 7)
		
		
		print(s, 220 - x/2, 295, 1)
		
		print(loreprint, x1+4 + (truew-lw-5)/2, y1+16)
		
		nine_slice(8, 275, 345, 97, 15)
		print("Selected Card Back", 280, 348)
	end
end

-- THE NORMAL PRINT WRAPPING CANNOT BE TRUSTED
function print_wrap_prep(s, width)
	local words = split(s, " ")
	local lines = {}
	local current_line = ""
	local final_w = 0
	
	for w in all(words) do
		local c2 = current_line == "" and w or current_line .. " " .. w
		local x = print(c2, 0, -1000)
		if x > width then
			current_line = current_line .. "\n" .. w
		else
			current_line = c2
			final_w = max(final_w, x)
		end
	end
	local _, final_h = print(current_line, 0, -1000)
	final_h += 1000
	
	return final_w, final_h, current_line
end

function cards_game_exiting()
	cards_api_load_game"cards_api/main_menu.lua"
end

end -- end of load
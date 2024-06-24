--[[pod_format="raw",created="2024-06-24 16:28:42",modified="2024-06-24 16:32:46",revision=44]]

suite_settings_to = -0.1
suite_settings_t = smooth_val(0, 0.87, 0.02, 0.00003)
suite_settings_buttons = {}
suite_settings_width, suite_settings_height = 300, 200

local suite_setting_layout_y = 10

function suite_settings_draw(layer)
	local sett_x, sett_y = (480 - suite_settings_width) / 2, (270 - suite_settings_height) / 2
		
	if layer == 2 then
		suite_menuitem_draw_pages()
		
		local y = (1 - suite_settings_t(suite_settings_to)) * 270 + sett_y
		y \= 1
		for b in all(suite_settings_buttons) do
			b.x = b.base_x + sett_x
			b.y = b.base_y + y
		end
		
	elseif layer == 3 then
	
		local y = suite_settings_t"pos"
		if y > 0 then
			y = (1-y)*270 + sett_y
			y \= 1
			
			--rectfill(0,0,480*x,270,32)
			--[[
			local sx = x * 300
			rectfill(240-sx, 135-sx, 241+sx, 136+sx, 32)
			
			local sx = x * 150 \ 1
			local sy = (x - suite_settings_t"vel" * 6) * 100 \ 1
			
			if sx > 0 and sy > 0 then
				rectfill(240-sx, 136+sy, 241+sx, 136+sy + 15, 32)
				
				rectfill(240-sx, 135-sy, 241+sx, 136+sy, 7)
			end
			]]
			
			local cx, cy = camera(-sett_x, -y)
			rectfill(0,suite_settings_height,
				suite_settings_width-1,suite_settings_height+10, 32)
			rectfill(0,0,
				suite_settings_width-1,suite_settings_height-1, 7)
			camera(cx, cy)
		end
	end
end

function suite_open_settings()
	-- clear old buttons
	for b in all(suite_settings_buttons) do
		b:destroy()
	end
	suite_settings_buttons = {}
	suite_setting_layout_y = 10
	suite_settings_to = 1
	
	-- interaction blocker
	suite_settings_blocker = button_new({
		x = -1000, y = -1000, 
		w = 3000, h = 3000, 
		draw = function() end, 
		group = 3
	})
	
	-- TODO fill with more things
	-- allow for the base to be used by other menus
	
	if(game_settings_opened) game_settings_opened()
	
	suite_settings_add_button("Exit Settings", suite_close_settings, true)

	-- change height of settings menu to fit the buttons
	suite_settings_height = suite_setting_layout_y + 10
end

function suite_close_settings()
	suite_settings_to = -0.1
	suite_settings_blocker:destroy()
	suite_settings_blocker = nil
	
	if(game_settings_closed) game_settings_closed()
end

function suite_settings_button_add(button)
	add(suite_settings_buttons, button)
	button.on_click = suite_settings_button_check(button.on_click)
	button.base_x = button.base_x or button.x
	button.base_y = button.base_y or button.y
end

-- prevents button from being pressed unless the menu is open
function suite_settings_button_check(func)
	return function(button)
		if suite_settings_to >= 1 then
			func(button)
		end
	end
end


-- available button types to add to the settings menu

function suite_settings_add_button(name, func, right_side)
	local b = suite_button_simple(name, 10, suite_setting_layout_y, func, nil, 3)
	if right_side then
		b.x = suite_settings_width - b.w - 10
	end
			
	suite_settings_button_add(b)
	
	suite_setting_layout_y += 20
end

function suite_settings_add_options(name, func, ops, current)
	
	-- TODO

	suite_setting_layout_y += 20
end

function suite_settings_add_range(name, func, min, max, current)
	
	

	suite_setting_layout_y += 20
end

-- TODO other potential ui elements for the settings menu
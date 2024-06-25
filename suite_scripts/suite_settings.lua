--[[pod_format="raw",created="2024-06-24 16:28:42",modified="2024-06-25 21:48:47",revision=1146]]

-- TODO: likely be renamed to something other than settings

suite_settings_to = -0.1
suite_settings_t = smooth_val(0, 0.87, 0.02, 0.00003)
suite_settings_buttons = {}
suite_settings_elements = {}
suite_settings_width, suite_settings_height = 300, 200
suite_settings_title = "\^w\^tSettings"

local suite_setting_layout_y = 10

function suite_settings_draw(layer)
	local sett_x, sett_y = (480 - suite_settings_width) / 2, (270 - suite_settings_height) / 2
		
	if layer == 2 then
		suite_menuitem_draw_pages()
		
		local cx, cy = camera() -- for fixing the button position based on camera
		
		local y = (1 - suite_settings_t(suite_settings_to)) * 270 + sett_y
		y \= 1
		for b in all(suite_settings_buttons) do
			b.x = b.base_x + sett_x + cx
			b.y = b.base_y + y + cy
		end
		
		camera(cx, cy)
		
	elseif layer == 3 then
	
		local y = suite_settings_t"pos"
		if y > 0 then
			y = (1-y)*270 + sett_y
			y \= 1
						
			local cx, cy = camera(-sett_x, -y)
			
			local w, h = print_size(suite_settings_title)
			
			nine_slice(35, 0, -h-20, 
				w+20, h+20, 20)
			
			print(suite_settings_title, 11, -h-7, 21)
			print(suite_settings_title, 11, -h-1-7, 4)
				
			
		
			--[[
			rectfill(0,suite_settings_height,
				suite_settings_width-1,suite_settings_height+10, 32)
			rectfill(0,0,
				suite_settings_width-1,suite_settings_height-1, 7)
			--]]
			rectfill(-10,suite_settings_height, 
				suite_settings_width+9,suite_settings_height+30, 32)
			nine_slice(33, -10, -10, 
				suite_settings_width+20, suite_settings_height+20, 7)
				
			for el in all(suite_settings_elements) do
				el()
			end
			
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
	suite_settings_elements = {}
	suite_setting_layout_y = 9
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
	

-- [[
	-- TEMP options for testing out ui functions
	local function pr(p)
		notify(tostr(p))
	end
	
	suite_settings_add_options("test options", pr, {"yes", "no", "maybe"}, 1)
	
	suite_settings_add_range("test range", pr, 0, 100, 10, 50)

	suite_settings_add_divider(5, 6)
--]]
	
	suite_settings_add_buttons({{"Exit Settings", suite_close_settings}}, true)

	-- change height of settings menu to fit the buttons
	suite_settings_height = suite_setting_layout_y + 7
end

function suite_close_settings()
	suite_settings_to = -0.1
	suite_settings_blocker:destroy()
	suite_settings_blocker = nil
	
	if(game_settings_closed) game_settings_closed()
end

-- adds a button to the list of settings buttons
-- and manages it's position and clickability
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

-- adds multiple buttons in a row, each with their own function to call
-- ops = {{name, func}, {...}, ...}
function suite_settings_add_buttons(ops, right_side)
	suite_settings_add_mulibutton(suite_setting_layout_y, ops, right_side)	
	suite_setting_layout_y += 20
end

-- adds multiple buttons, but only one should be selected at a time
function suite_settings_add_options(name, func, ops, current)

	local y = suite_setting_layout_y
	
	-- updates the selected status of a button
	local x, buttons = nil
	local function update_options()
		for i, b in ipairs(buttons) do
			b.selected = i == current
		end
	end

	-- wraps the functions to control the appearance of the button
	-- also to control what buttons are selected
	local ops2 = {}
	for i, o in ipairs(ops) do
		add(ops2, {o,
			function(b)
				current = i
				update_options()
				func(i)
			end
		})
	end
	
	-- adds the button options
	x, buttons = suite_settings_add_mulibutton(y, ops2, true)
	update_options()
	
	-- adds text label
	suite_settings_add_text_part(name, x-8, y)

	suite_setting_layout_y += 20
end

function suite_settings_add_range(name, func, t0, t1, inc, current, inc_width)

	local y = suite_setting_layout_y
	inc_width = inc_width or 6
	
	-- increment buttons
	local b2 = suite_button_simple("+", suite_settings_width - 23, y, function()
		current = mid(current + inc, t0, t1)
		func(current)
	end, nil, 3)
	local b1 = suite_button_simple("-", suite_settings_width - 130, y, function()
		current = mid(current - inc, t0, t1)
		func(current)
	end, nil, 3)
	
	-- calculates number of marks
	local i1 = (t1-t0) \ inc
	
	-- calculates left edge of marks
	local left = b2.x - i1 * inc_width - 7
	
	-- repositions "-" button based on size
	b1.x = left - b1.w - 8
	local x2 = b1.x - 6
	
	-- add text
	suite_settings_add_text_part(name, b1.x - 8, y)
	
	-- draw marks
	if inc_width <= 3 then
		add(suite_settings_elements, function()
			
			for i = 0,i1-1 do
				local x = i*inc_width + left
				rectfill(x, y+4, x+inc_width-2, y+16, current >= (i+1)*inc and 1 or 32)
			end
		end)
		
	else
		add(suite_settings_elements, function()
			-- draw marks
			for i = 0,i1-1 do
				local x = i*inc_width + left
				color(current >= (i+1)*inc and 1 or 32)
				rectfill(x+1, y+4, x+inc_width-3, y+16)
				rectfill(x, y+5, x+inc_width-2, y+15)
			end
		end)
	end
	
	
	-- draw value
	
	add(suite_settings_elements, function()
		local w, h = print_size(current)
		rectfill(x2 - w - 2, y + 3, x2+1, y+h+3, 7)
		double_print(current, x2 - w, y + 5, 1)
	end)
	
	-- add buttons
	suite_settings_button_add(b1)
	suite_settings_button_add(b2)
	
	suite_setting_layout_y += 20
end

-- adds a simple divider to separate elements
function suite_settings_add_divider(edge, col)
	local y = suite_setting_layout_y + 2
	
	add(suite_settings_elements, function()
		rect(edge, y, suite_settings_width - edge - 1, y, col) 
	end)
	
	suite_setting_layout_y += 5
end

-- ui helper that adds a text label to a row
function suite_settings_add_text_part(text, right_x, y)

	local tw = print_size(text) + 13
	
	-- adds text label and dotted line
	add(suite_settings_elements, function()
		fillp(0x77777777)
		rectfill(tw, y+12, right_x, y+12, 32) 
		fillp()

		double_print(text, 10, y+5, 2)
	end)
end

-- ui helper that adds multiple buttons in a packed row
function suite_settings_add_mulibutton(y, ops, right_side)
	-- creates a button for each option
	local op_buttons = {}
	for o in all(ops) do
		add(op_buttons, suite_button_simple(o[1], 0, y, o[2], nil, 3))
	end
	
	local x = 10
	
	if right_side then
		-- repositions buttons to be packed correctly on the right side
		x = suite_settings_width
		for i = #op_buttons, 1, -1 do
			local b = op_buttons[i]
			
			x -= b.w + 10
			b.x = x
			
			suite_settings_button_add(b)
		end
		
	else
		-- repositions buttons to be packed correctly on the left
		for i = 1, #op_buttons do
			local b = op_buttons[i]
			b.x = x
			x += b.w + 10
						
			suite_settings_button_add(b)
		end
	end	

	return x, op_buttons
end

-- TODO other potential ui elements for the settings menu

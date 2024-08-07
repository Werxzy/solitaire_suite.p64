--[[pod_format="raw",created="2024-06-24 16:28:42",modified="2024-07-17 06:55:57",revision=3010]]

suite_window_to = -0.1
suite_window_t = smooth_val(0, 0.87, 0.02, 0.00003)
suite_window_buttons = {}
suite_window_elements = {}
suite_window_width, suite_window_height = 300, 200
suite_window_title = "\^w\^tSettings"
local suite_window_layout_y = 10

-- TODO: page control?
-- TODO: better control for custom elements?


-- extra functions for windows with custom elements in custom games
function get_suite_window_layout_y()
	return suite_window_layout_y
end
function set_suite_window_layout_y(y)
	suite_window_layout_y = y
end
function suite_window_add_element(el)
	add(suite_window_elements, el)
end
function suite_window_add_button(button)
	add(suite_window_buttons, button)
end

-- initializes a window with the given title and width
-- height is entirely dependant on the contents
function suite_window_init(name, width)
	-- clear old buttons and draw elements
	for b in all(suite_window_buttons) do
		b:destroy()
	end
	suite_window_buttons = {}
	suite_window_elements = {}
	suite_window_layout_y = 9
	suite_window_to = 1
	suite_window_width = width or 300
	suite_window_title = "\^w\^t" .. name
	
	-- interaction blocker
	suite_window_blocker = button_new({
		x = -1000, y = -1000, 
		width = 3000, height = 3000, 
		draw = function() end, 
		group = 3
	})

	suite_window_is_settings = name == "Settings"
end

-- creates an exit button for the window
-- exit_text is a string that is by default "Exit"
function suite_window_footer(exit_text)
	if #suite_window_buttons > 0 or #suite_window_elements > 0 then
		suite_window_add_divider(5, 6)
	end

	-- forced-ish exit button
	suite_window_add_buttons({{exit_text or "Exit", suite_close_window}}, true)

	-- change height of settings menu to fit the buttons
	suite_window_height = suite_window_layout_y + 7
end

-- draw function for the window
-- already handled by the suite
function suite_window_draw(layer)
	local sett_x, sett_y = (480 - suite_window_width) / 2, (270 - suite_window_height) / 2 + 20
		
	if layer == 2 then
		suite_menuitem_draw_pages()
		
		local cx, cy = camera() -- for fixing the button position based on camera
		
		local y = (1 - suite_window_t(suite_window_to)) * 270 + sett_y
		y \= 1
		for b in all(suite_window_buttons) do
			b.x = b.base_x + sett_x + cx
			b.y = b.base_y + y + cy
		end
		
		camera(cx, cy)
		
	elseif layer == 3 then
	
		local y = suite_window_t"pos"
		if y > 0 then
			y = (1-y)*270 + sett_y
			y \= 1
						
			local cx, cy = camera(-sett_x, -y)
			
			local w, h = print_size(suite_window_title)
			
			rectfill(w+10, -h, 
				w+30, h+20, 32)
			nine_slice(35, 0, -h-20, 
				w+20, h+20, 20)
			
			print(suite_window_title, 11, -h-7, 21)
			print(suite_window_title, 11, -h-1-7, 4)
				
			
		
			--[[
			rectfill(0,suite_window_height,
				suite_window_width-1,suite_window_height+10, 32)
			rectfill(0,0,
				suite_window_width-1,suite_window_height-1, 7)
			--]]
			rectfill(0, 10, 
				suite_window_width+19,suite_window_height+30, 32)
			nine_slice(33, -10, -10, 
				suite_window_width+20, suite_window_height+20, 7)
				
			for el in all(suite_window_elements) do
				el()
			end
			
			camera(cx, cy)
		end
	end
end


function suite_open_settings()
	suite_window_init("Settings")
	
	if(game_settings_opened) game_settings_opened()
	
	if #suite_window_buttons > 0 or #suite_window_elements > 0 then
		suite_window_add_divider(5, 6)
	end
	
	-- TODO fill with more things
	-- probably volume control or others
	
-- [[
	-- TEMP options for testing out ui functions
	local function pr()end
	suite_window_add_options("TODO: more settings", pr, {"Okay", "Ok", "K"}, 1)
	suite_window_add_range("Volume?", pr, "%i%%", 0, 100, 10, 50)
--]]

	suite_window_footer("Exit Settings")
end

-- closes the current window
function suite_close_window()
	suite_window_to = -0.1
	suite_window_blocker:destroy()
	suite_window_blocker = nil
	
	-- only call function for the settings
	if(suite_window_is_settings and game_settings_closed) game_settings_closed()
end

-- adds a button to the list of settings buttons
-- and manages it's position and clickability
function suite_window_button_add(button)
	add(suite_window_buttons, button)
	local old_destory = button.on_destroy
	
	button.on_destroy = function(b)
		del(suite_window_buttons, b)
		if old_destroy then
			old_destroy()
		end
	end
	
	button.on_click = suite_window_button_check(button.on_click)
	button.base_x = button.base_x or button.x
	button.base_y = button.base_y or button.y
end

-- prevents button from being pressed unless the menu is open
function suite_window_button_check(func)
	if func then
		return function(button)
			if suite_window_to >= 1 then
				func(button)
			end
		end
	end
end


-- available button types to add to the settings menu

-- adds multiple buttons in a row, each with their own function to call
-- ops = {{name, func}, {...}, ...}
function suite_window_add_buttons(ops, right_side)
	local b = suite_window_add_mulibutton(suite_window_layout_y, ops, right_side)	
	suite_window_layout_y += 20
	return b
end

-- adds multiple buttons, but only one should be selected at a time
function suite_window_add_options(name, func, ops, current)

	local y = suite_window_layout_y
	
	-- updates the selected status of a button
	local buttons, x = nil
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
	buttons, x = suite_window_add_mulibutton(y, ops2, true)
	update_options()
	
	-- adds text label
	suite_window_add_text_part(name, x-8, y)

	suite_window_layout_y += 20
end

function suite_window_add_range(name, func, format, t0, t1, inc, current, inc_width)

	local y = suite_window_layout_y
	inc_width = inc_width or 6
	if type(format) == "string" and #format == 0 then
		format = nil
	end
	
	-- increment buttons
	local b2 = suite_button_simple({
		text = "+", 
		x = suite_window_width - 23, y = y, 
		on_click = function()
			current = mid(current + inc, t0, t1)
			func(current)
		end,
		group = 3,
		always_active = true
	})

	local b1 = suite_button_simple({
		text = "-", 
		x = suite_window_width - 130, y = y, 
		on_click = function()
			current = mid(current - inc, t0, t1)
			func(current)
		end,
		group = 3,
		always_active = true
	})
	
	-- calculates number of marks
	local i1 = (t1-t0) \ inc
	
	-- calculates left edge of marks
	local left = b2.x - i1 * inc_width - 7
	
	-- repositions "-" button based on size
	b1.x = left - b1.width - 8
	local x2 = b1.x - 6
	
	-- add text
	suite_window_add_text_part(name, b1.x - 8, y)
	
	-- draw marks
	if inc_width <= 3 then
		add(suite_window_elements, function()
			
			for i = 0,i1-1 do
				local x = i*inc_width + left
				rectfill(x, y+4, x+inc_width-2, y+16, current-t0 >= (i+1)*inc and 1 or 32)
			end
		end)
		
	else
		add(suite_window_elements, function()
			-- draw marks
			for i = 0,i1-1 do
				local x = i*inc_width + left
				color(current-t0 >= (i+1)*inc and 1 or 32)
				rectfill(x+1, y+4, x+inc_width-3, y+16)
				rectfill(x, y+5, x+inc_width-2, y+15)
			end
		end)
	end
	
	
	-- draw value
	
	add(suite_window_elements, function()
		local s = current
		if(format) s = string.format(format, s)

		local w, h = print_size(s)
		rectfill(x2 - w - 2, y + 3, x2+1, y+h+3, 7)
		double_print(s, x2 - w, y + 5, 1)
	end)
	
	-- add buttons
	suite_window_button_add(b1)
	suite_window_button_add(b2)
	
	suite_window_layout_y += 20
end

-- adds a simple divider to separate elements
function suite_window_add_divider(edge, col)
	local y = suite_window_layout_y + 2
	
	add(suite_window_elements, function()
		rect(edge, y, suite_window_width - edge - 1, y, col) 
	end)
	
	suite_window_layout_y += 5
end

-- ui helper that adds a text label to a row
function suite_window_add_text_part(str, right_x, y)

	local tw = print_size(str) + 13
	
	-- adds text label and dotted line
	add(suite_window_elements, function()
		fillp(0x77777777)
		rectfill(tw, y+12, right_x, y+12, 32) 
		fillp()

		double_print(str, 10, y+5, 2)
	end)
end

-- ui helper that adds multiple buttons in a packed row
function suite_window_add_mulibutton(y, ops, right_side)
	-- creates a button for each option
	local op_buttons = {}
	for o in all(ops) do
		add(op_buttons, suite_button_simple({
			text = o[1], 
			x = 0, y = y, 
			on_click = o[2], 
			group = 3,
			always_active = true
		}))
	end
	
	local x = 10
	
	if right_side then
		-- repositions buttons to be packed correctly on the right side
		x = suite_window_width
		for i = #op_buttons, 1, -1 do
			local b = op_buttons[i]
			
			x -= b.width + 10
			b.x = x
			
			suite_window_button_add(b)
		end
		
	else
		-- repositions buttons to be packed correctly on the left
		for i = 1, #op_buttons do
			local b = op_buttons[i]
			b.x = x
			x += b.width + 10
						
			suite_window_button_add(b)
		end
	end	

	return op_buttons, x
end

-- other potential ui elements for the settings menu

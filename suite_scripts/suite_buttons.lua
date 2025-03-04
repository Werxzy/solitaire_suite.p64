--[[pod_format="raw",created="2024-06-12 07:48:24",modified="2025-02-10 21:42:51",revision=5287]]

local menuitems = {}
local pages_buttons = {}

local suite_page_number = 1
local suite_openned_pages = nil
local suite_next_pages = nil
local suite_pages_t = 0
local suite_pages_x = smooth_val(0, 0.5, 0.1, 0.0001)

local function suite_button_on_destroy(button)
	del(menuitems, button)
end

local function suite_pages_on_destory(button)
	del(pages_buttons, button)
end

local function suite_button_draw(button)
	local x, y = button.x, button.y
	local w = button.width
	local l = button.left
	
	local ox, oy = camera(-x, -y)
	color(button.colors[2])
	
	rectfill(4 + l, 13, button.width+3, 15)
	
	for i = 0, 3 do
		local y = 2 + i * 3
		rectfill(i, y, i, y+2) 
	end
	camera(ox, oy)
	

	y -= (button.t*2-1)^2 * 2.5 - 2.5
	camera(-x, -y)
	
	button.t = max(button.t - 0.07)
	
	color(button.colors[button.highlight and 3 or 1])
	
	w -= 2
	rectfill(l, 0, w, 1)
	rectfill(l+1, 2, w+1, 4)
	rectfill(l+2, 5, w+2, 7)
	rectfill(l+3, 8, w+3, 10)
	rectfill(l+4, 11, w+4, 12)
	
	color(button.colors[2])
	for i = 1, 12 do
		pset((i+1)\3 + w+1, i) 
	end
	
	print(button.text, 7, 3, 22)
	print(button.text, 7, 2, 7)		
	

	if button.value then
		pal(2, button.colors[2])
		sspr(61, 0, 0, button.valw, 11, button.valx, 1)
		sspr(61, 43, 0, 8, 11, button.valx+button.valw, 1)
		pal(2,2)
		print(button.value, button.valx+4, 3, 16)
	end
	camera(ox, oy)
	
	
end

function suite_button_set_value(button, value)
	button.value = value
	-- TODO update layout to fit the new string
end

--[[
creates a button for the menu bar

param is a table with the following possible values

text = text displayed on the button
on_click = function called when the button is clicked
value = extra info displayed next to the text that can be updated, like a win counter
	can be left nil
pages = table of information that be displayed on a seperate window when the button is clicked
	note that this will replace the on_click call
	needs to have the following
	width, height = size of display area
	content = table of strings or userdata to be displayed
colors = table of color values to draw the button with
]]
function suite_menuitem(param)
	local text = param.text or ""
	local on_click = param.on_click
	local value = param.value
	
	if param.pages then
		on_click = suite_menuitem_display_pages
	end
	
	local last = menuitems[#menuitems]
	local x = last and last.x+last.width or 0
	local w = print_size(text) + 10
	
	local b = button_new({
		x = x, y = 255, 
		width = w, height = 15, 
		draw = suite_button_draw, 
		on_click = on_click and function(b)
			b.t = 1
			on_click(b)
		end,
		bottom = true,
		group = 2,
		always_active = param.always_active
	})
	
	b.pages = param.pages
	b.t = 0
	b.text = text
	b.colors = param.colors or {4, 20, 21}
	b.on_destroy = suite_button_on_destroy
	b.set_value = suite_button_set_value
	b.left = #menuitems == 0 and -4 or 0
	
	if not text or #tostr(text) == 0 then
		b.width -= 4
	end

	if value then
		local valw = print_size(value)
			
		b.value = value
		b.valw = valw
		b.valx = b.width - 2
		b.width += valw + 7
	end
	
	return add(menuitems, b)
end

-- specifically for setting up pages
local function suite_pages_button(param)	
	local text = param.text or ""
	local on_click = param.on_click
		
	local w = print_size(text) + 10
	
	local b = button_new({
		x = -100, y = 0, 
		width = w, height = 15, 
		draw = suite_button_draw, 
		on_click = on_click and function(b)
			b.t = 1
			on_click(b)
		end,
		bottom = true,
		group = 2,
		always_active = true,
		
		t = 0,
		text = text,
		colors = {4, 20, 21},
		left = param.left or 0,
		on_destroy = suite_pages_on_destory
	})
	
	if not text or #tostr(text) == 0 then
		b.width -= 4
	end
		
	return add(pages_buttons, b, 1)
end

function suite_menuitem_update_sizes()
	-- TODO
end

-- creates most of the menu bar at the bottom of the screen. Very important to call or add something similar
function suite_menuitem_init()
	local clock = suite_menuitem({
		colors = {27,3,19}, 
		value = "\fc12\fg\-f:\-e\fc00"
	})
	local old_draw = clock.draw
	clock.draw = function(b)
		b.value = date("\fc%H\fg\-f:\-e\fc%M")
		old_draw(b)
	end
	
	suite_menuitem({
		text = "Exit", 
		colors = {8,24,2},
		on_click = function()
			suite_exit_game()
		end,
		always_active = true
	})
	
	suite_menuitem({
		--text = "\^:7f00007f00007f00",
		text = "\^:1f00003e00007c00\-a\^:1f00003e00007c00",
		colors = {27,3,19},
		on_click = suite_open_settings,
		always_active = true
	})
	
	suite_pages_button({
		text = "   ",
		left = -400
	})	
	suite_pages_button({
		text = "\^:63773e1c3e776300", 
		on_click = suite_menuitem_close_pages
	})
	suite_pages_button({
		text = ""
	})
	suite_pages_button({
		text = " \^:60787e7f7e786000 ", 
		on_click = function()
			if suite_openned_pages then
				suite_page_number = max(suite_page_number - 1, 1)
			end
		end
	})
	suite_pages_button({
		text = " \^:030f3f7f3f0f0300 ", 
		on_click = function()
			if suite_openned_pages then
				suite_page_number = min(suite_page_number + 1, #suite_openned_pages.pages.content)
			end
		end
	})
	
end

-- quick way of getting a rules page done
-- width and height are the size of the display area of the rules text
function suite_menuitem_rules(width, height)
	return suite_menuitem({
		text = "Rules", 
		pages = {
			width = width or 175,
			height = height or 80,
			content = game_info().rules,
		},
		always_active = true
	})
end

local function suite_button_simple_draw(b)
	pal(16, b.col[2])
	pal(1, b.col[3])
	pal(12, b.col[1])
	
	spr(b.spr1, b.x-3, b.y)
	
	pal(12, (b.highlight or b.selected) and b.col[3] or b.col[1])	
	
	b.ct += mid((b.selected and 0.5 or 0) - b.ct, -0.07, 0.07)
	local click_y =  ((b.ct*2-1)^2 * 2.5 - 2.5) \ 1
	
	sspr(b.spr2, 
		0,0, 
		b.width,b.height+click_y, 
		b.x,b.y-click_y) 
	
	pal(12, 12)	
	pal(16, 16)
	pal(1, 1)	
end

--[[
creates a simple button

param is a table with the following possible values

x, y = position of the button
text = text displayed on the button, also controlling the size
on_click = function called when the button is clicked
group = drawing group the button belongs to, defaults to 1
always_active = if true, then the button can be clicked even if an animation is playing
colors = table of colors that the button is drawn with

]]
function suite_button_simple(param)
	local text = param.text or " "
	local w, h = print_size(text)
	w += 9
	h += 4
	
	local on_click = param.on_click

	local b = button_new({
		x = param.x, y = param.y, 
		width = w, height = h, 
		draw = suite_button_simple_draw, 
		on_click = function (button)
			button.ct = 1
			if on_click then
				on_click(button)
			end
		end,
		group = param.group,
		always_active = param.always_active,
		col = param.colors or {27,3,19},
		ct = 0,
		text = text
	})
	
	local cx, cy = camera()

	b.spr1 = userdata("u8", b.width + 6, b.height + 4)
	set_draw_target(b.spr1)
	nine_slice(17, 0, 0, b.spr1:width(), b.spr1:height())
	
	b.spr2 = userdata("u8", b.width, b.height)
	set_draw_target(b.spr2)
	nine_slice(18, 0, 0, b.spr2:width(), b.spr2:height())
	print(text, 5, 3, 22)
	print(text, 5, 2, 7)
	
	set_draw_target()
	camera(cx, cy)
	
	return b
end

-- page display functions

function suite_menuitem_draw_pages()

	if suite_next_pages then
		local x = suite_pages_x(0)
		
		-- next page group
		if x <= 0 then
			suite_page_number = 1
			suite_pages_t = 1
			suite_openned_pages = suite_next_pages
			suite_next_pages = nil
		end
	
	elseif suite_openned_pages then
		local x = suite_pages_x(suite_pages_t)
		
		if x <= 0 and suite_pages_t == 0 then
			suite_openned_pages = nil
		end
	end

	if not suite_openned_pages then
		return 
	end
	
	local pos = suite_pages_x"pos"
	local p = suite_openned_pages.pages
	
	pos = (1 - pos) * (p.width + 10)
	local oldx, oldy = camera(pos, 0)
	for i, b in pairs(pages_buttons) do
		pos += b.width
		b.x = p.width  - pos - 1
		b.y = 270 - p.height - 37 -- test
	end
	
	local y = 270-15-p.height - 6
	local x = 0
	local w, h = p.width, p.height
	
	rectfill(x, y, x+w-1, y+h-1, 7)
	rect(x-1, y, x+w-1, y+h, 32)
	
	local c = p.content[suite_page_number]
	local ty = type(c)
	
	if ty == "string" then
		local c = print_wrap_prep(c, p.width-4)
		double_print(c, x+2, y+2, 1)
		
	elseif ty == "userdata" or ty == "number" then
		spr(c, 0, 100)
	end
	
	
--	rectfill(x, y-2, x+w+2, y-1, 20)
	
--	rectfill(x, y-12, x+w-46, y-3, 4)
--	rectfill(x, y-11, x+w-42, y-3, 4) -- VERY temp
--	pset(x+w-45, y-11, 20) -- VERY VERY temp
	
--	spr(19, x+w-22, y-12)
--	spr(20, x+w-44, y-12)
	
	rectfill(x+w, y-1, x+w+2, y+h-1, 4)
	rectfill(x, y+h, x+w+2, y+h+2, 4)
	rectfill(x, y+h+3, x+w+2, y+h+4, 20)
	
	camera(oldx, oldy)
end

-- displays the information on the pages window
function suite_menuitem_display_pages(button)
	if button == suite_openned_pages then
		suite_pages_t = 1 - suite_pages_t
	else
		suite_next_pages = button
	end
end

function suite_menuitem_close_pages()
	suite_pages_t = 0
end

function suite_menuitem_remove_pages()
	suite_openned_pages = nil
	suite_pages_t = 0
	suite_pages_x("pos", 0)
end

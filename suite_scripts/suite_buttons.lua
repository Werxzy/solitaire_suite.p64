--[[pod_format="raw",created="2024-06-12 07:48:24",modified="2024-06-26 14:56:52",revision=4878]]

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
	local w = button.w
	local l = button.left
	
	

	local ox, oy = camera(-x, -y)
	color(button.colors[2])
	
	rectfill(4 + l, 13, button.w+3, 15)
	
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

--function suite_menuitem(text, colors, on_click, value)
function suite_menuitem(param, too_many)
	assert(not too_many, "instead use a single table as the first parameter")
	
	local text = param.text or ""
	local on_click = param.on_click
	local value = param.value
	
	if param.pages then
		on_click = suite_menuitem_display_pages
	end
	
	local last = menuitems[#menuitems]
	local x = last and last.x+last.w or 0
	local w = print_size(text) + 10
	
	local b = button_new({
		x = x, y = 255, 
		w = w, h = 15, 
		draw = suite_button_draw, 
		on_click = on_click and function(b)
			b.t = 1
			on_click(b)
		end,
		bottom = true,
		group = 2,
	})
	
	b.pages = param.pages
	b.t = 0
	b.text = text
	b.colors = param.colors or {4, 20, 21}
	b.on_destroy = suite_button_on_destroy
	b.set_value = suite_button_set_value
	b.left = #menuitems == 0 and -4 or 0
	b.always_active = param.always_active
	
	if not text or #tostr(text) == 0 then
		b.w -= 4
	end

	if value then
		local valw = print_size(value)
			
		b.value = value
		b.valw = valw
		b.valx = b.w - 2
		b.w += valw + 7
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
		w = w, h = 15, 
		draw = suite_button_draw, 
		on_click = on_click and function(b)
			b.t = 1
			on_click(b)
		end,
		bottom = true,
		group = 2,
	})
	
	b.t = 0
	b.text = text
	b.colors = {4, 20, 21}
	b.left = param.left or 0
	b.always_active = true
	b.on_destroy = suite_pages_on_destory
	
	if not text or #tostr(text) == 0 then
		b.w -= 4
	end
		
	return add(pages_buttons, b, 1)
end

function suite_menuitem_update_sizes()
	-- TODO
end

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
function suite_menuitem_rules(width, height)
	return suite_menuitem({
		text = "Rules", 
		pages = {
			width = width or 175,
			height = height or 75,
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
		b.w,b.h+click_y, 
		b.x,b.y-click_y) 
	
	pal(12, 12)	
	pal(16, 16)
	pal(1, 1)	
end

function suite_button_simple(t, x, y, on_click, colors, group)
	local w, h = print_size(t)
	w += 9
	h += 4
	
	local bn = button_new({
		x = x, y = y, 
		w = w, h = h, 
		draw = suite_button_simple_draw, 
		on_click = function (b)
			b.ct = 1
			if on_click then
				on_click(b)
			end
		end,
		group = group
	})
	bn.col = colors or {27,3,19}
	bn.ct = 0	
	bn.text = t
	
	local cx, cy = camera()

	bn.spr1 = userdata("u8", bn.w + 6, bn.h + 4)
	set_draw_target(bn.spr1)
	nine_slice(17, 0, 0, bn.spr1:width(), bn.spr1:height())
	
	bn.spr2 = userdata("u8", bn.w, bn.h)
	set_draw_target(bn.spr2)
	nine_slice(18, 0, 0, bn.spr2:width(), bn.spr2:height())
	print(t, 5, 3, 22)
	print(t, 5, 2, 7)
	
	set_draw_target()
	camera(cx, cy)
	
	return bn
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
		pos += b.w
		b.x = p.width  - pos - 1
		b.y = 270 - p.height - 37 -- test
	end
	
	-- TODO: clear this up and add proper graphics
	local y = 270-15-p.height - 6
	local x = 0
	local w, h = p.width, p.height
	
	rectfill(x, y, x+w-1, y+h-1, 7)
	rect(x-1, y, x+w-1, y+h, 32)
	
	local c = p.content[suite_page_number]
	local ty = type(c)
	
	if ty == "string" then
		local _, _, c = print_wrap_prep(c, p.width-4)
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

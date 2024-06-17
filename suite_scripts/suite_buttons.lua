--[[pod_format="raw",created="2024-06-12 07:48:24",modified="2024-06-17 13:51:46",revision=2364]]

local menuitems = {}

local function suite_button_on_destroy(button)
	del(menuitems, button)
end

local function suite_button_draw(button, layer)
	local x, y = button.x, button.y
	local w = button.w
	local l = button.left
	
	y -= (button.t*2-1)^2 * 2.5 - 2.5
	local ox, oy = camera(-x, -y)
	
	if layer == 1 then
		color(button.colors[2])
		
		rectfill(4 + l, 13, button.w+3, 15)
		
		for i = 0, 3 do
			local y = 2 + i * 3
			rectfill(i, y, i, y+2) 
		end
		
	elseif layer == 2 then
		button.t = max(button.t - 0.07)
		
		color(button.colors[button.highlight and 3 or 1])
		
		w -= 2
		rectfill(l, 0, w, 1)
		rectfill(l+1, 2, w+1, 4)
		rectfill(l+2, 5, w+2, 7)
		rectfill(l+3, 8, w+3, 10)
		rectfill(l+4, 11, w+4, 12)
		
		color(button.colors[2])
		for i = 1, 13 do
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
	
	local b = button_new(x, 255, w, 15, suite_button_draw, 
		on_click and function(b)
			b.t = 1
			on_click(b)
		end)
	
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
	
	-- force button to be on the bottom of the list (to ensure correct draw order)
	del(buttons_all, b)
	add(buttons_all, b, 1)

	return add(menuitems, b)
end

function suite_menuitem_update_sizes()
	-- TODO
end

function suite_menuitem_init()
	suite_menuitem({
		colors = {27,3,19}, 
		value = "\fc12\fg\-f:\-e\fc00"
	})
	
	suite_menuitem({
		text = "Exit", 
		colors = {8,24,2},
		on_click = function()
			rule_cards = nil -- TODO remove?
			suite_exit_game()
		end,
		always_active = true
	})
end

-- quick way of getting a rules page done
function suite_menuitem_rules()
	return suite_menuitem({
		text = "Rules", 
		pages = {
			width = 100,
			height = 100,
			content = game_info().rules,
		},
		always_active = true
	})
end

local function suite_button_simple_draw(b, layer)
	pal(16, b.col[2])
	pal(1, b.col[3])
	
	if layer == 1 then
		pal(12, b.col[1])
		spr(b.spr1, b.x-3, b.y)
		
	elseif layer == 2 then
		pal(12, b.highlight and b.col[3] or b.col[1])	
		
		b.ct = max(b.ct - 0.07)
		local click_y = b.y - ((b.ct*2-1)^2 * 2.5 - 2.5) \ 1
		
		clip(b.x, b.y, b.w, b.h)
		spr(b.spr2, b.x, click_y) 
		clip()		
	end
	
	pal(12, 12)	
	pal(16, 16)
	pal(1, 1)	
end

function suite_button_simple(t, x, y, on_click, colors)
	local w, h = print_size(t)
	w += 9
	h += 4
	
	local bn = button_new(x, y, w, h, suite_button_simple_draw, 
		function (b)
			b.ct = 1
			if on_click then
				on_click(b)
			end
		end)
	bn.col = colors or {27,3,19}
	bn.ct = 0	
	bn.text = t
	
	bn.spr1 = userdata("u8", bn.w + 6, bn.h + 4)
	set_draw_target(bn.spr1)
	nine_slice(17, 0, 0, bn.spr1:width(), bn.spr1:height())
	
	bn.spr2 = userdata("u8", bn.w, bn.h)
	set_draw_target(bn.spr2)
	nine_slice(18, 0, 0, bn.spr2:width(), bn.spr2:height())
	print(t, 5, 3, 22)
	print(t, 5, 2, 7)
	
	set_draw_target()
	
	return bn
end

-- page display functions

-- TODO: figure out how to remove the detail when leaving a game
-- either watch a button's on_destroy or on a game load
local suite_openned_pages = nil

function suite_menuitem_draw_pages()
	if not suite_openned_pages then
		return
	end
	
	local p = suite_openned_pages.pages
	
	-- TODO: clear this up and add proper graphics
	local y = 270-15-p.height - 6
	local x = 0
	local w, h = p.width, p.height
	
	rectfill(x, y, x+w-1, y+h-1, 7)
	rect(x-1, y, x+w-1, y+h, 32)
	
	local c = p.content[1]
	local ty = type(c)
	
	if ty == "string" then
		double_print(c, x+2, y+2, 1)
		
	elseif ty == "userdata" or ty == "number" then
		spr(c, 0, 100)
	end
	
	
	rectfill(x, y-2, x+w+2, y-1, 20)
	
	rectfill(x, y-12, x+w-46, y-3, 4)
	rectfill(x, y-11, x+w-42, y-3, 4) -- VERY temp
	pset(x+w-45, y-11, 20) -- VERY VERY temp
	
	spr(19, x+w-22, y-12)
	spr(20, x+w-44, y-12)
	
	rectfill(x+w, y-1, x+w+2, y+h-1, 4)
	rectfill(x, y+h, x+w+2, y+h+2, 4)
	rectfill(x, y+h+3, x+w+2, y+h+4, 20)
end

function suite_menuitem_display_pages(button)
	suite_menuitem_close_pages()
	
	if button == suite_openned_pages then
		suite_openned_pages = nil
		return
	end
	suite_openned_pages = button
	
	-- TODO open animation
end

function suite_menuitem_close_pages()
	-- TODO close animation
end
--[[pod_format="raw",created="2024-06-12 07:48:24",modified="2024-06-17 11:32:14",revision=1810]]

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

function suite_menuitem(text, colors, on_click, value)
	local last = menuitems[#menuitems]
	local x = last and last.x+last.w or 0
	local w = print_size(text) + 10
	
	local b = button_new(x, 255, w, 15, suite_button_draw, 
		on_click and function(b)
			b.t = 1
			on_click(b)
		end)
	
	b.t = 0
	b.text = text
	b.colors = colors
	b.on_destroy = suite_button_on_destroy
	b.set_value = suite_button_set_value
	b.left = #menuitems == 0 and -4 or 0
	
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
	suite_menuitem("", {27,3,19}, nil, "\fc12\fg\-f:\-e\fc00")
	suite_menuitem("Exit", {8,24,2},
		function()
			rule_cards = nil -- TODO remove?
			suite_exit_game()
		end).always_active = true
end

local function suite_button_simple_draw(b, layer)
	
	if layer == 1 then
		pal(12, b.col[1])	
		pal(16, b.col[2])
		pal(1, b.col[3])
		spr(b.spr1, b.x-3, b.y)
		
	elseif layer == 2 then
		pal(12, b.highlight and b.col[3] or b.col[1])	
		pal(16, b.col[2])
		pal(1, b.col[3])
		
		b.ct = max(b.ct - 0.07)
		local click_y = b.y - ((b.ct*2-1)^2 * 2.5 - 2.5) \ 1
		
		clip(b.x, b.y, b.w, b.h)
		spr(b.spr2, b.y, click_y) 
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

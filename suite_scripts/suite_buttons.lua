--[[pod_format="raw",created="2024-06-12 07:48:24",modified="2024-06-12 09:40:43",revision=461]]

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
		button.t = max(button.t - 0.1)
		
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
	end
	
	camera(ox, oy)
end

function suite_menuitem(text, colors, on_click, value)
	local last = menuitems[#menuitems]
	local x = last and last.x+last.w or 0
	local w = print_size(text) + 10
	
	local b = button_new(x, 255, w, 15, suite_button_draw, 
		function(b)
			b.t = 1
			if on_click then
				on_click(b)
			end
		end)
		
	-- force button to be on the bottom of the list (to ensure correct draw order)
	del(buttons_all, b)
	add(buttons_all, b, 1)
	
	b.t = 0
	b.text = text
	b.colors = colors
	b.on_destroy = suite_button_on_destroy
	b.left = #menuitems == 0 and -4 or 0
	
	add(menuitems, b)
end


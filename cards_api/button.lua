--[[pod_format="raw",created="2024-03-18 02:31:29",modified="2024-03-18 13:33:13",revision=364]]

-- this could use more work
-- the purpose is to allow for animated sprite buttons

buttons_all = {}

function button_new(x, y, w, h, draw, on_click)
	return add(buttons_all, {
		x = x, y = y,
		w = w, h = h,
		draw = draw,
		on_click = on_click,
		highlight = false
	})
end

function button_simple_text(t, x, y, on_click)
	local w, h = print(t, 0, 300)	
	h -= 300
	x += 5
	y += 3
	w += 3
	return button_new(x, y, w, h, function(b)
			rectfill(x-5, y, x+w, y+h+3, 19)
			rectfill(x-5, y-3, x+w, y+h, b.highlight and 11 or 27)
			print(t, x, y, 19)
		end, on_click)
end
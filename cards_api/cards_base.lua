--[[pod_format="raw",created="2024-03-16 15:34:19",modified="2024-03-16 15:46:34",revision=91]]

include"cards_api/stack.lua"
include"cards_api/card.lua"

function has(tab, val)
	for k,v in pairs(tab) do
		if v == val then
			return k
		end
	end
end

function point_box(x1, y1, x2, y2, w, h)
	x1 -= x2
	y1 -= y2
	return x1 >= 0 and y1 >= 0 and x1 < w and y1 < h 
end 


function lerp(a, b, t)
	return a + (b-a) * t
end

function cards_api_draw()
	foreach(stacks_all, draw_stack)	
	foreach(cards_all, draw_card)
end

function cards_api_update()
		foreach(stacks_all, stack_reposition)
	foreach(cards_all, card_update)
end
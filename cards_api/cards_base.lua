--[[pod_format="raw",created="2024-03-16 15:34:19",modified="2024-03-16 16:44:17",revision=398]]

include"cards_api/stack.lua"
include"cards_api/card.lua"

-- maybe stuff these into userdata to evaluate all at once?
function smooth_val(val, damp, acc)
	local vel = 0
	return function(to)
		if to == "vel" then
			return vel
		end
		if to then
			local dif = (to - val) * acc
			vel += dif
			vel *= damp
			val += vel
			if abs(vel) < 0.1 and abs(dif) < 0.1 then
				val, vel = to, 0
			end
		end
		return val
	end
end

-- angle might be overkill
function smooth_angle(val, damp, acc)
	local vel = 0
	return function(to)
		if to == "vel" then
			return vel
		end
		if to then
			local dif = ((to - val + 0.5) % 1 - 0.5) * acc
			vel += dif
			vel *= damp
			val += vel
			if abs(vel) < 0.0006 and abs(dif) < 0.007 then
				val, vel = to, 0
			end
		end
		return val
	end
end

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
	foreach(cards_all, card_draw)
end

function cards_api_update()
	foreach(stacks_all, stack_reposition)
	foreach(cards_all, card_update)
end
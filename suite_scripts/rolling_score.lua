--[[pod_format="raw",created="2024-03-18 21:28:46",modified="2024-03-19 14:34:11",revision=698]]

function rolling_score_update(s)
	local val = s.value
	
	for i = #s.digits, 1, -1 do
		local v = val%10
		local dif = min((v - s.digits[i]) % 10, s.speed)
		
		s.digits[i] += dif

		val \= 10
	end
end

function rolling_score_draw(s)
	for i = 1,#s.digits do
		local sy = s.digits[i]
		local x, y = (i - 1)*s.spread + s.x, s.y
				
		sy += sin(sy) * 0.3 -- little shift
		sy = (9 - sy) * s.dh -- proper direction
		sy %= s.dh*10 -- looping
		
		sspr(s.sprite, 0, sy, s.dw, s.dh, x + s.x2, y + s.y2)
		if sy > s.dh*9 then -- looping digit
			sspr(s.sprite, 0, sy-s.dh*10, s.dh, min(sy - s.dh*9, s.dh), x + s.x2, y + s.y2)
		end
		
		if s.draw_extra then 
			s:draw_extra(x, y)
		end
	end
end
	
--[[
x,y = top left of score
x2,y2 = extra offsets for the digits
spread = horizontal spread between digits
dw,dh = digit sprite size (single digit)
sprite = sprite id or userdata
draw_extra = extra draws done for each digit
]]
function rolling_score_new(x, y, x2, y2, spread, dw, dh, digits, sprite, draw_extra)
	local d = {}
	for i = 1,digits do
		add(d, 0)
	end
	
	return {
		x = x, y = y,
		x2 = x2, y2 = y2,
		spread = spread, 
		dw = dw, dh = dh,
		digits = d,
		value = 0,
		sprite = sprite,
		update =rolling_score_update,
		draw = rolling_score_draw,
		draw_extra = draw_extra,
		speed = 0.05
	}
end
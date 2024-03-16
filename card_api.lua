--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-16 13:58:05",revision=458]]

function card_draw(sprite, x, y, width, height, angle)
	angle /= -3
	local dx, dy = cos(angle), -sin(angle)*0.5
	if dx < 0 then
		sprite = 1
	end
	
	y -= dy * width / 2
		
	if abs(dy*card_width) < 1 then
		sspr(sprite, 0, 0, width, height, x, y)
	else
		local x = x - dx*width/2 + width/2
		local sx = 0
		
		local last_drawn = -999
		for x2 = 0,width - 1 do
			-- only draw one vertical slice at a time
			-- could do this mathmatically, but nah :)
			if x\1 ~= last_drawn then
				sspr(sprite, sx, 0, 1, height, x, y)
				last_drawn = x\1
			end
			sx += 1
			x += dx
			y += dy
		end
	end
end
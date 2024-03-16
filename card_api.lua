--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-16 13:24:34",revision=265]]

function card_draw(sprite, x, y, width, height, angle)
	angle /= -3
	local dx, dy = cos(angle), -sin(angle)
	if dx < 0 then
		sprite = 1
	end
	local sx = 0
	y -= dy * width / 2
--	x -= width / 2
	xw = x - width/2 + dx*width/2
	if abs(dy*card_width) < 1 then
		sspr(sprite, 0, 0, width, height, x, y)
	else
		for x2 = 0,width - 1 do
			sspr(sprite, sx, 0, 1, height, xw, y)
			sx += 1
			x += 1
			xw += dx
			y += dy
		end
	end
end
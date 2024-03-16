--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-16 12:44:40",revision=37]]

function card_draw(sprite, x, y, width, height, angle)
	local sx, dy = 0, mid(angle, -0.8,0.8)
	y -= dy * width / 2
	if abs(dy*card_width) < 1 then
		sspr(sprite, 0, 0, width, height, x, y)
	else
		for x2 = 0,width - 1 do
			sspr(sprite, sx, 0, 1, height, x, y)
			sx += 1
			x += 1
			y += dy
		end
	end
end
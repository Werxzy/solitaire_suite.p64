--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-18 16:41:42",revision=2972]]

card_width = 45
card_height = 60
card_back = 10 -- can be number or userdata

cards_all = {}

function card_new(sprite, x, y, a)
	x = x or 0
	y = y or 0
	a = a or 0
	return add(cards_all, {
		x = smooth_val(x, 0.7, 0.1), 
		y = smooth_val(y, 0.7, 0.1), 
		a = smooth_angle(a, 0.6, 0.1),
		x_to = x,
		y_to = y,
		a_to = a,
		sprite = sprite
		})
end

function card_draw(c)
	local facing_down = (c.a_to-0.25) % 1 < 0.5
	local sprite, x, y, width, height, angle = facing_down and card_back or c.sprite, c.x(), c.y(), card_width, card_height, c.x"vel" / -60 + c.a()
	local dx, dy = cos(angle), -sin(angle)*0.5
	if dx < 0 then
		sprite = card_back
		dx = -dx
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

function card_update(card)
	card.x(card.x_to)
	card.y(card.y_to)
	card.a(card.a_to)
end

function card_to_top(card)
	add(cards_all, del(cards_all, card))
end

function card_is_top(card)
	return get_top_card(card.stack) == card
end

function get_top_card(stack)
	return stack.cards[#stack.cards]
end
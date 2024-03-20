--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-20 05:12:07",revision=6992]]

card_width = 45
card_height = 60
card_back = 10 -- can be number or userdata

cards_all = {}

-- todo??? make a card metatable with a weak reference to a stack
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

-- drawing function for cards
-- shifts vertical lines of pixels to give the illusion if the card turning
function card_draw(c)
	local facing_down = (c.a()-0.25) % 1 < 0.5
	local sprite, x, y, width, height, angle = facing_down and card_back or c.sprite, c.x(), c.y(), card_width, card_height, c.x"vel" / -60 + c.a()
	local dx, dy = cos(angle), -sin(angle)*0.5
	if dx < 0 then
		sprite = card_back
		dx = -dx
	end
	--[[ as cool as it might be, shadows are expensive and don't add much
	-- plus they're difficult to get right at the moment
	
	--if c.stack.cards[1] == c then
--	if c.stack == held_stack then
		local x1, y1, x2, y2 = x + width*(1-dx), y+7, x+width*dx-1, y+height+6
		poke(0x5508, 0xff) -- read
		poke(0x550a, 0xff) -- target sprite
		poke(0x550b, 0xff) -- target shapes
		poke(0x5509, 0xff)
		
		--fillp(0xa5a5a5a5a5a5a5a5)
		rectfill(x1+2, y1+2, x2-2, y2-2, 32)
		--rectfill(x2+1, y1+1, x2+1, y2-1, 32)
		--rectfill(x1-1, y1+1, x1-1, y2-1, 32)
		fillp(0xa5a5a5a5a5a5a5a5)
		rect(x1, y1, x2, y2, 32)
		rect(x1+1, y1+1, x2-1, y2-1, 32)
		fillp()
		
		-- these migth not be correct
		poke(0x5508, 0x3f) -- read
		poke(0x550a, 0x3f) -- target sprite
		poke(0x550b, 0xff) -- target shapes
		poke(0x5509, 0x3f)
--	end
	--]]

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
				sspr(sprite, x2, 0, 1, height, x, y)
				last_drawn = x\1
			end
			x += dx
			y += dy
		end
	end
end

-- updates cards position and angle
function card_update(card)
	card.x(card.x_to)
	card.y(card.y_to)
	card.a(card.a_to)
end

-- puts the given card above all other cards in drawing order
function card_to_top(card)
	add(cards_all, del(cards_all, card))
end

-- checks if the given card is on top of its stack
function card_is_top(card)
	return get_top_card(card.stack) == card
end

-- returns the top card of a stack
function get_top_card(stack)
	return stack.cards[#stack.cards]
end
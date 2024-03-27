--[[pod_format="raw",created="2024-03-16 12:26:44",modified="2024-03-26 23:43:00",revision=11522]]

card_width = 45
card_height = 60
card_back = {sprite = 10} -- sprite can be number or userdata

cards_all = {}
card_shadows_on = true

function card_new(sprite, x, y, a)
	x = x or 0
	y = y or 0
	a = a or 0
	
-- todo, allow for specifying card back

-- todo??? make a card metatable with a weak reference to a stack
-- sometimes after a lot of testing, picotron runs out of memory
-- stacks/cards might not be garbage collected due to referencing eachother
-- I think this only occurs if exiting in the middle of a game
	return add(cards_all, {
		x = smooth_val(x, 0.7, 0.1), 
		y = smooth_val(y, 0.7, 0.1), 
		a = smooth_angle(a, 0.7, 0.12),
		x_to = x,
		y_to = y,
		a_to = a,
		sprite = sprite,
		shadow = 0
		})
end

-- drawing function for cards
-- shifts vertical lines of pixels to give the illusion if the card turning
function card_draw(c)
	local facing_down = (c.a()-0.45) % 1 < 0.1 -- facing 45 degree limit for facing down
	local sprite = facing_down and card_back.sprite or c.sprite
	
	if(type(sprite) == "table") sprite = sprite.sprite

	local x, y, width, height = c.x(), c.y(), card_width, card_height
	local angle = c.x"vel" / -100 + c.a()
	--local angle =  c.a()
		
	local dx, dy = cos(angle), -sin(angle)*0.5
	if dx < 0 then
		sprite = card_back.sprite
		dx = -dx
		dy = -dy
	end

	if	card_shadows_on then
		card_shadow_draw(c, x, y, width, height, dx, dy)
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
				sspr(sprite, x2, 0, 1, height, x, y)
				last_drawn = x\1
			end
			x += dx
			y += dy
		end
	end
end


function card_shadow_draw(c, x, y, width, height, dx, dy)

	c.shadow = lerp(c.shadow, c.stack == held_stack and 1 or -0.1, 0.2 - mid((abs(c.x"vel") - abs(c.y"vel"))/15, 0.15))
	
	--subtle effect for cards that are moving around
	--local v = c.stack == held_stack and 1 or mid((abs(c.x"vel") + abs(c.y"vel"))/5-0.1, 1, -0.1)
	--c.shadow = lerp(c.shadow or 0, v, 0.2 - mid((abs(c.x"vel") + abs(c.y"vel"))/15, 0.15))		
	
	if c.shadow > 0 then
		
		local xx = x - dx*width/2 + width/2
		local x1, y1, x2, y2 = xx, y+7 + height/3, xx+width*dx-1, y+height+6 + abs(dy)*card_width/3 - (1-c.shadow) * 10
		local xmid = (x1+x2)/2
		x1 = min(x1, xmid-7)
		x2 = max(x2, xmid+7)
		poke(0x5509, 0xff) -- only shadow once on a pixel
		
		fillp(0xa5a5a5a5a5a5a5a5)
	
		local xmid = (x1+x2)/2
		local xc1, xc2 = x1+4,  x2-4
		rectfill(x1, y1, x2, y2-4, 32)
		rectfill(x1+4, y2-8, x2-4, y2)
		circfill(x1+4, y2-4, 4)
		circfill(x2-4, y2-4, 4)
		circfill(xmid, y1, 7)
		fillp()
		
		x1 += 3
		x2 -= 3
		y2 -= 3
		
		rectfill(x1, y1, x2, y2-4)
		rectfill(x1+4, y2-8, x2-4, y2)
		circfill(x1+4,y2-4,4)
		circfill(x2-4,y2-4,4)
		circfill(xmid,y1,4)
		
		poke(0x5509, 0x3f)
	end
end

-- updates cards position and angle
function card_update(card)
	card.x(card.x_to)
	card.y(card.y_to)
	card.a(card.a_to - card.x"vel"/10000)
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

-- makes a card back sprite that can be updated
function card_back_animated(func, data)
	-- this function may need to be changed in the future
	data.update = function(init)
		-- will be true when the card back needs to change resolution or be initilized
		func(init, data)
	end
	
	data.update(true)
	
	return data
end
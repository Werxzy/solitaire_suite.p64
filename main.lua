--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-16 13:58:05",revision=1760]]

include"card_api.lua"

all_suits = {
	--"Spades",
	--"Hearts",
	--"Clubs",
	--"Diamonds"
	"\|f\^:081c3e7f7f36081c",
	"\|g\^:00367f7f3e1c0800",
	"\|f\^:001c1c7f7f77081c",
	"\|g\^:081c3e7f3e1c0800"
}

all_suit_colors = {
	16,
	8,
	27,
	25
	
}

all_ranks = {
	"A",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"J",
	"Q",
	"K"
}

card_width = 45
card_height = 60
card_gap = 4

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

function _init()

	cards = {}
	for suit = 1,4 do
		for rank = 1,13 do
			local c = add(cards, {
				x = smooth_val(240, 0.7, 0.1), 
				y = smooth_val(135, 0.7, 0.1), 
				suit = suit,
				rank = rank,
				x_to = rnd(400)\1,
				y_to = rnd(200)\1,
				sprite = userdata("u8", card_width, card_height)
				})
				
			set_draw_target(c.sprite)
			spr(2)
			print(all_ranks[c.rank] .. all_suits[c.suit], 3, 3, all_suit_colors[c.suit])
			
		end
	end
	
	set_draw_target()

	local unstacked_cards = {}
	for c in all(cards) do
		add(unstacked_cards, c)
	end
	
	stacks = {}

	for i = 1,7 do
		local s = add(stacks, {
			x_to = i*(card_width + card_gap*2) + card_gap,
			y_to = card_gap,
			cards = {},
			perm = true,
			can_stack = stack_can_rule,
			y_delta = 12
			})
			
		for i = 1,8 do
			local c = rnd(unstacked_cards)
			if c then
				add(cards, del(cards, c)).stack = s
				add(s.cards, del(unstacked_cards, c))
			end
			stack_reposition(s)
		end
	end
	
	for i = 0,34 do
		local s = add(stacks, {
			x_to = 8*(card_width + card_gap*2) + card_gap,
			y_to = i*(card_height + card_gap*2) + card_gap,
			cards = {},
			perm = true,
			can_stack = stack_can_goal,
			y_delta = 0
			})
				end
	
	mouse_last = 0
	mouse_lx, mouse_ly = mouse()
	
end

function _update()
	local mx, my, md = mouse()
	
	local mouse_down = md & ~mouse_last
	local mouse_up = ~md & mouse_last
	local mouse_dx, mouse_dy = mx - mouse_lx, my - mouse_ly
	
	if mouse_down&1 == 1 and not held_stack then
		for i = #cards, 1, -1 do
			local c = cards[i]
			local x, y = c.x(), c.y()
			if mx >= x and my >= y and mx < x + card_width and my < y + 70 then
				
				held_stack = unstack_cards(c)
				held_stack.x_to = mx - card_width/2
				held_stack.y_to = my - card_height/2
				break
			end
		end
	end
	if mouse_up&1 == 1 and held_stack then
		for s in all(stacks) do
			local y = stack_y_pos(s)
			if s:can_stack(held_stack) 
			and point_box(held_stack.x_to + card_width/2, 
			held_stack.y_to + card_height/2, s.x_to, y, card_width, card_height) then
			
				stack_cards(s, held_stack)
				held_stack = nil
				break
			end
		end
		if held_stack ~= nil then
			stack_cards(held_stack.old_stack, held_stack)
			held_stack = nil
		end
	end
	
	if held_stack then
		held_stack.x_to += mouse_dx
		held_stack.y_to += mouse_dy
		--stack_reposition(held_stack)
	end
	foreach(stacks, stack_reposition)
	foreach(cards, update_card)
		
	mouse_last, mouse_lx, mouse_ly = md, mx, my
end

function _draw()
	cls(1)
			
	foreach(cards, draw_card)
	
	?stat(1), 0, 0
end

function draw_card(c)
	local x, y = c.x(), c.y()
--	rectfill(x,y,x+card_width-1,y+card_height-1,7)
--	rect(x,y,x+card_width-1,y+card_height-1,6)
--	spr(2,x,y)
--	sspr(2, 0, 0, card_width, card_height, x, y)
--[[
	local sx, dy = 0, mid(c.x("vel")/15, -0.8,0.8)
	if abs(dy*card_width) < 1 then
		sspr(c.sprite, 0, 0, card_width, card_height, x, y)
	else
		for x2 = 0,card_width - 1 do
			sspr(c.sprite, sx, 0, 1, card_height, x, y)
			sx += 1
			x += 1
			y += dy
		end
	end
	]]
	card_draw(c.sprite, c.x(), c.y(), card_width, card_height, c.x"vel" / 20)
	
--	print(all_ranks[c.rank] .. all_suits[c.suit], c.x()+3, c.y()+3, all_suit_colors[c.suit])
end

function update_card(c)
	c.x(c.x_to)
	c.y(c.y_to)
end

function stack_cards(stack, stack2)
	for c in all(stack2.cards) do
		add(stack.cards, del(stack2.cards, c))
		c.stack = stack
	end
	stack_reposition(stack)
	stack2.old_stack = nil
	del(stacks, stack2)
end

function unstack_cards(card)
	local new_stack = add(stacks, {
		x_to = 0, 
		y_to = 0,
		old_stack = card.stack, 
		cards = {},
		can_stack = stack_cant,
		y_delta = 10
		})
	local old_stack = card.stack
	
	local i = has(old_stack.cards, card)
	while #old_stack.cards >= i do
		local c = add(new_stack.cards, deli(old_stack.cards, i))
		add(cards, del(cards, c)) -- puts cards on top of all the others
		c.stack = new_stack
	end
	
	if #old_stack.cards == 0 and not old_stack.perm then
		del(stacks, old_stack)
	else
		stack_reposition(old_stack)
	end
		
	stack_reposition(new_stack)
	
	
	
	return new_stack
end

function stack_reposition(stack)
	local y, yd = stack.y_to, min(stack.y_delta, 220 / #stack.cards)
	local lasty, lastx = y, stack.x_to
	for i, c in pairs(stack.cards) do
		local t = 0.7 / (i+1)
		c.x_to = lerp(lastx, stack.x_to, t)
		c.y_to = lerp(lasty, y, t)
		y += yd
		
		lastx = c.x()
		lasty = c.y() + yd
	end
end

function stack_y_pos(stack)
	local top = stack.cards[#stack.cards]
	return top and top.y_to or stack.y_to
end

-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	if s == held_stack then
		return false
	end
	if #stack.cards == 0 then
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	if c1.rank - 1 == c2.rank 
	and c1.suit ~= c2.suit then
		return true
	end

	--if c1.rank - 1 == c2.rank then
	--	return true
	--end
end

-- expects to be stacked from ace to king with the same suit
function stack_can_goal(stack, stack2)
	if s == held_stack then
		return false
	end
	--
	if #stack2.cards ~= 1 then
		return false
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1] 
	
	if #stack.cards == 0 and c2.rank == 1 then
		return true
	end
	
	if #stack.cards > 0 and c1.rank + 1 == c2.rank then
		return true
	end
end

function stack_cant()
	return false
end

function point_box(x1, y1, x2, y2, w, h)
	x1 -= x2
	y1 -= y2
	return x1 >= 0 and y1 >= 0 and x1 < w and y1 < h 
end

function has(tab, val)
	for k,v in pairs(tab) do
		if v == val then
			return k
		end
	end
end

function lerp(a, b, t)
	return a + (b-a) * t
end
--[[pod_format="raw",created="2024-03-16 15:18:21",modified="2024-03-16 17:12:02",revision=570]]

stacks_all = {}

function stack_new(x, y, perm, on_click, stack_rule)
	return add(stacks_all, {
		x_to = x,
		y_to = y,
		cards = {},
		perm = perm,
		on_click = on_click,
		can_stack = stack_rule,
		y_delta = 12
		})
end

function stack_draw(s)
	if s.perm then
		local x, y = s.x_to, s.y_to
		spr(5, x-3, y-3)
		--rectfill(x - 3, y - 3, x + card_width + 2, y + card_height + 2, 19)
	end
end


function stack_cards(stack, stack2)
	for c in all(stack2.cards) do
		add(stack.cards, del(stack2.cards, c))
		c.stack = stack
	end
	stack_reposition(stack)
	stack2.old_stack = nil
	del(stacks_all, stack2)
end

function stack_on_click_unstack(card, mx, my)
	-- todo, check rule
	-- use currying
	held_stack = unstack_cards(card)
	held_stack.x_to = mx - card_width/2
	held_stack.y_to = my - card_height/2
end

function unstack_cards(card)
	local old_stack = card.stack
	
	local new_stack = stack_new(0, 0, false, stack_cant, stack_cant)
	new_stack.y_delta = 10
	new_stack.old_stack = old_stack

	local i = has(old_stack.cards, card)
	while #old_stack.cards >= i do
		local c = add(new_stack.cards, deli(old_stack.cards, i))
		card_to_top(c) -- puts cards on top of all the others
		c.stack = new_stack
	end
	
	if #old_stack.cards == 0 and not old_stack.perm then
		del(stacks_all, old_stack)
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

function stack_cant()
end
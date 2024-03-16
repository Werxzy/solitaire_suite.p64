--[[pod_format="raw",created="2024-03-16 15:18:21",modified="2024-03-16 15:46:34",revision=157]]

stacks_all = {}

function draw_stack(s)
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


function unstack_cards(card)
	local new_stack = add(stacks_all, {
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
		add(cards_all, del(cards_all, c)) -- puts cards on top of all the others
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
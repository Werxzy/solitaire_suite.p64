--[[pod_format="raw",created="2024-03-16 15:18:21",modified="2024-03-17 02:37:02",revision=1188]]

stacks_all = {}
stack_border = 3

function stack_new(sprites, x, y, perm, stack_rule, on_click, on_double)
	return add(stacks_all, {
		sprites = sprites,
		x_to = x,
		y_to = y,
		cards = {},
		perm = perm,
		can_stack = stack_rule,
		on_click = on_click,
		on_double = on_double,
		y_delta = 12,
		repos_decay = 0.7
		})
end

function stack_draw(s)
	if s.perm then
		local x, y = s.x_to - stack_border, s.y_to - stack_border
		for sp in all(s.sprites) do
			spr(sp, x, y)
		end
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

function stack_on_click_unstack(card)
	-- todo, check rule
	-- use currying
	if card then
		local mx, my = mouse()
		held_stack = unstack_cards(card)
		held_stack.x_to = mx - card_width/2
		held_stack.y_to = my - card_height/2
	end
end

function unstack_cards(card)
	local old_stack = card.stack
	
	local new_stack = stack_new(nil, 0, 0, false, stack_cant, stack_cant)
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
		local t = stack.repos_decay / (i+1)
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

function stack_add_card(stack, card, old_stack)
	if card then
		card_to_top(card)
		if old_stack then
			del(old_stack, card)
		elseif card.stack then
			del(card.stack.cards, card)
		end
		add(stack.cards, card).stack = stack
	end
end
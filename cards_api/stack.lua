--[[pod_format="raw",created="2024-03-16 15:18:21",modified="2024-03-27 02:28:13",revision=11601]]

stacks_all = {}
stack_border = 3

--[[
Stacks are essentially tables containing cards.
Each stack has a set of rules for how cards interact with it.

sprites = table of sprite ids or userdata to be drawn with sspr
x,y = top left position of stack
repos = function called when changing the target position of the cards
perm = if the stack is removed when there is no more cards
stack_rule = function called when another stack of cards is placed on top (with restrictions)
on_click = function called when stack base or card in stack is clicked
on_double = function caled when stack base or card in stack is double clicked
]]

function stack_new(sprites, x, y, repos, perm, stack_rule, on_click, on_double)
	return add(stacks_all, {
		sprites = type(sprites) == "table" and sprites or {sprites},
		x_to = x,
		y_to = y,
		cards = {},
		perm = perm,
		reposition = repos,
		can_stack = stack_rule,
		on_click = on_click,
		on_double = on_double,
		resolve_stack = stack_cards
		})
end

-- drawing function for stacks
-- always drawn below cards
function stack_draw(s)
	if s.perm then
		local x, y = s.x_to - stack_border, s.y_to - stack_border
		for sp in all(s.sprites) do
			spr(sp, x, y)
		end
	end
end

-- Places cards from stack2 to onto stack
function stack_cards(stack, stack2)
	for c in all(stack2.cards) do
		add(stack.cards, del(stack2.cards, c))
		card_to_top(c)
		c.stack = stack
	end
	stack2.old_stack = nil
	if not stack2.perm then
		del(stacks_all, stack2)
	end
end

-- on_click event that unstacks cards starting from the given card
-- if a given rule function returns true
function stack_on_click_unstack(...)
	local rules = {...}
	
	return function(card)
		if card then
			for r in all(rules) do
				if(not r(card))return
			end
			
			held_stack = unstack_cards(card)
		end
	end
end

function unstack_rule_face_up(card)
	return card.a_to == 0
end

-- creates a new stack by taking cards from the given card's stack.
-- cards starting from the given card to the top of the stack (stack[#stack])
function unstack_cards(card)
	local old_stack = card.stack
	
	local new_stack = stack_new(nil, 0, 0, stack_repose_normal(10), false, stack_cant, stack_cant)
	new_stack.old_stack = old_stack

	local i = has(old_stack.cards, card)
	while #old_stack.cards >= i do
		local c = add(new_stack.cards, deli(old_stack.cards, i))
		card_to_top(c) -- puts cards on top of all the others
		c.stack = new_stack
	end
	
	if #old_stack.cards == 0 and not old_stack.perm then
		del(stacks_all, old_stack)
	end	
	
	return new_stack
end

-- reposition calculation for a stack that allows for more floaty cards
function stack_repose_normal(y_delta, decay, limit)
	y_delta = y_delta or 12
	decay = decay or 0.7
	limit = limit or 220
	
	return function(stack)
		local y, yd = stack.y_to, min(y_delta, limit / #stack.cards)
		local lasty, lastx = y, stack.x_to
		for i, c in pairs(stack.cards) do
			local t = decay / (i+1)
			c.x_to = lerp(lastx, stack.x_to, t)
			c.y_to = lerp(lasty, y, t)
			y += yd
			
			lastx = c.x()
			lasty = c.y() + yd
		end
	end
end

-- reposition calculation that has fixed positions
function stack_repose_static(y_delta)
	y_delta = y_delta or 12
	
	return function(stack)
		local y = stack.y_to
		for c in all(stack.cards) do
			c.x_to = stack.x_to
			c.y_to = y
			y += y_delta
		end
	end
end

-- returns the y position of the top of the stack
function stack_y_pos(stack)
	local top = stack.cards[#stack.cards]
	return top and top.y_to or stack.y_to
end

-- basically always returns false for
-- more just for nice naming
-- could still be used for other events like sound effects
function stack_cant()
end

-- adds a card to the top of a stack
-- if an old stack is given, the card is removed from that table/stack instead
function stack_add_card(stack, card, old_stack)
	if card then
		card_to_top(card)
		
		if type(old_stack) == "table" then
			del(old_stack, card)
		elseif card.stack then
			del(card.stack.cards, card)
		end
		
		if type(old_stack) == "number" then
			add(stack.cards, card, old_stack).stack = stack
		else
			add(stack.cards, card).stack = stack
		end
	end
end
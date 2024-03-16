--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-16 15:46:34",revision=2108]]

include"cards_api/cards_base.lua"

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

	for suit = 1,4 do
		for rank = 1,13 do
			local c = add(cards_all, {
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
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	stacks = {}

	for i = 1,7 do
		local s = add(stacks_all, {
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
				add(cards_all, del(cards_all, c)).stack = s
				add(s.cards, del(unstacked_cards, c))
			end
			stack_reposition(s)
		end
	end
	
	for i = 0,3 do
		local s = add(stacks_all, {
			x_to = 8*(card_width + card_gap*2) + card_gap,
			y_to = i*(card_height + card_gap*2-1) + card_gap,
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
		for i = #cards_all, 1, -1 do
			local c = cards_all[i]
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
		for s in all(stacks_all) do
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
	cards_api_update()
		
	mouse_last, mouse_lx, mouse_ly = md, mx, my
end

function _draw()
	cls(3)
	
	cards_api_draw()
	
	?stat(1), 0, 0, 6
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
	
	if #stack.cards > 0 and c1.rank + 1 == c2.rank and c1.suit == c2.suit then
		return true
	end
end

function stack_cant()
	return false
end

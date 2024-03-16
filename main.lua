--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-16 17:12:02",revision=2559]]

include"cards_api/cards_base.lua"


function _init()
	local card_gap = 4
	for suit = 1,4 do
		for rank = 1,13 do
			local new_sprite = userdata("u8", card_width, card_height)
			
			set_draw_target(new_sprite)
			spr(2)
			print(all_ranks[rank] .. all_suits[suit], 3, 3, all_suit_colors[suit])
			
			local c = card_new(new_sprite, 240,100)
			c.suit = suit
			c.rank = rank
		end
	end
	
	set_draw_target()

	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	stacks = {}

	for i = 1,7 do
		local s = stack_new(
			i*(card_width + card_gap*2) + card_gap, 
			card_gap, 
			true, stack_on_click_unstack, stack_can_rule)
			
		for i = 1,8 do
			local c = rnd(unstacked_cards)
			if c then
				card_to_top(c)
				c.stack = s
				add(s.cards, del(unstacked_cards, c))
			end
			stack_reposition(s)
		end
	end
	
	for i = 0,3 do
		local s = stack_new(
			8*(card_width + card_gap*2) + card_gap,
			i*(card_height + card_gap*2-1) + card_gap,
			true, stack_on_click_unstack, stack_can_goal)
			
		s.y_delta = 0
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
			if point_box(mx, my, c.x(), c.y(), card_width, card_height) then
				c.stack.on_click(c, mx, my)
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

function stack_on_click_reveal()
	
end
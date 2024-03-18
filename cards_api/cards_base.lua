--[[pod_format="raw",created="2024-03-16 15:34:19",modified="2024-03-18 01:16:57",revision=1532]]

include"cards_api/stack.lua"
include"cards_api/card.lua"

mouse_last = 0
mouse_lx, mouse_ly = mouse()
mouse_last_click = time() - 100
mouse_last_clicked = nil
	
function cards_api_draw()
	foreach(stacks_all, stack_draw)	
	foreach(cards_all, card_draw)
end

function cards_api_update()
	
	cards_api_mouse_update()

	for s in all(stacks_all) do
		s:reposition()
	end
	foreach(cards_all, card_update)	
end

function cards_api_mouse_update()

	local mx, my, md = mouse()
	
	local mouse_down = md & ~mouse_last
	local mouse_up = ~md & mouse_last
	local mouse_dx, mouse_dy = mx - mouse_lx, my - mouse_ly
	local double_click = time() - mouse_last_click < 0.5	

	if mouse_down&1 == 1 and not held_stack then
		local clicked = false
		
		for i = #cards_all, 1, -1 do
			local c = cards_all[i]
			if point_box(mx, my, c.x(), c.y(), card_width, card_height) then
				
				if double_click 
				and mouse_last_clicked == c
				and c.stack.on_double then
					c.stack.on_double(c)
					mouse_last_clicked = nil
				else
					c.stack.on_click(c)
					mouse_last_clicked = c
				end
				clicked = true
				break
			end
		end
		
		if not clicked then
			for s in all(stacks_all) do
				if point_box(mx, my, s.x_to, s.y_to, card_width, card_height) then
				
					if time() - mouse_last_click < 0.5 
					and mouse_last_clicked == s 
					and s.on_double then
						s.on_double()
						mouse_last_clicked = nil
					else
						s.on_click()
						mouse_last_clicked = s
					end
					break
				end
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
	end

	if mouse_down&1 == 1 then
		mouse_last_click = time()
	end
	mouse_last, mouse_lx, mouse_ly = md, mx, my
end

function cards_api_clear()
	-- removes recursive connection between cards to safely remove them from memory
	-- at least I believe this is needed
	for c in all(cards_all) do
		c.stack = nil
	end
	cards_all = {}
	stacks_all = {}
end

-- maybe stuff these into userdata to evaluate all at once?
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

-- angle might be overkill
function smooth_angle(val, damp, acc)
	local vel = 0
	return function(to)
		if to == "vel" then
			return vel
		end
		if to then
			local dif = ((to - val + 0.5) % 1 - 0.5) * acc
			vel += dif
			vel *= damp
			val += vel
			if abs(vel) < 0.0006 and abs(dif) < 0.007 then
				val, vel = to, 0
			end
		end
		return val
	end
end

function has(tab, val)
	for k,v in pairs(tab) do
		if v == val then
			return k
		end
	end
end

function point_box(x1, y1, x2, y2, w, h)
	x1 -= x2
	y1 -= y2
	return x1 >= 0 and y1 >= 0 and x1 < w and y1 < h 
end 


function lerp(a, b, t)
	return a + (b-a) * t
end
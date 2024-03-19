--[[pod_format="raw",created="2024-03-16 15:34:19",modified="2024-03-19 02:17:59",revision=3597]]

include"cards_api/stack.lua"
include"cards_api/card.lua"
include"cards_api/button.lua"

mouse_last = 0
mouse_lx, mouse_ly = mouse()
mouse_last_click = time() - 100
mouse_last_clicked = nil

cards_coroutine = nil
	
function cards_api_draw()
	if(game_draw) game_draw(0)
	
	foreach(stacks_all, stack_draw)
	
	for b in all(buttons_all) do
		b:draw()
	end
	
	if(game_draw) game_draw(1)
		
	foreach(cards_all, card_draw)
	
	if(game_draw) game_draw(2)
end

function cards_api_update()
	
	-- don't accept mouse input when there is a coroutine
	-- though, coroutines are a bit annoying to debug
	if cards_coroutine then
		coresume(cards_coroutine)
		if costatus(cards_coroutine) == "dead" then
			cards_coroutine = nil
		end
		cards_api_mouse_update(false)
	else
		cards_api_mouse_update(true)
	end

	for s in all(stacks_all) do
		s:reposition()
	end
	foreach(cards_all, card_update)	
	
	if(game_update) game_update()
end

function cards_api_mouse_update(interact)

	local mx, my, md = mouse()
	
	local mouse_down = md & ~mouse_last
	local mouse_up = ~md & mouse_last
	local mouse_dx, mouse_dy = mx - mouse_lx, my - mouse_ly
	local double_click = time() - mouse_last_click < 0.5	
	
	if interact then
		for b in all(buttons_all) do
			b.highlight = not held_stack and point_box(mx, my, b.x, b.y, b.w, b.h)
		end

		if mouse_down&1 == 1 and not held_stack then
			local clicked = false
			
			if not cards_frozen then
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
			end
			
			if not clicked then
				for b in all(buttons_all) do
					if b.highlight then
						b:on_click()
						clicked = true
					end
				end
			end
			
			if not clicked and not cards_frozen then
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
						clicked = true
						break
					end
				end
			end
			
			if clicked then
				cards_api_condition_check()
			end
		end
		
		if mouse_up&1 == 1 and held_stack then
			for s in all(stacks_all) do
				local y = stack_y_pos(s)
				if s ~= held_stack and s:can_stack(held_stack) 
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
			cards_api_condition_check()
		end
		
		if held_stack then
			held_stack.x_to = mx - card_width/2
			held_stack.y_to = my - card_height/2
		end
		
	else
		for b in all(buttons_all) do
			b.highlight = false
		end
	end

	if mouse_down&1 == 1 then
		mouse_last_click = time()
	end
	mouse_last, mouse_lx, mouse_ly = md, mx, my
end

function cards_api_condition_check()
	if not cards_frozen and game_win_condition and game_win_condition() then
		if game_count_win then
			game_count_win()
			cards_frozen = true
		end
	end
end

function cards_api_game_started()
	 cards_frozen = false
end

function cards_api_clear()
	-- removes recursive connection between cards to safely remove them from memory
	-- at least I believe this is needed
	for c in all(cards_all) do
		c.stack = nil
	end
	cards_all = {}
	stacks_all = {}
	buttons_all = {}
end

-- maybe stuff these into userdata to evaluate all at once?
function smooth_val(pos, damp, acc)
	local vel = 0
	return function(to, set)
		if to == "vel" then
			if set then
				vel = set
				return
			end
			return vel
			
		elseif to == "pos" then
			if set then
				pos = set
				return
			end
			return pos -- not necessary, but for consistency
		end
		
		if to then
			local dif = (to - pos) * acc
			vel += dif
			vel *= damp
			pos += vel
			if abs(vel) < 0.1 and abs(dif) < 0.1 then
				pos, vel = to, 0
			end
		end
		return pos
	end
end

function smooth_angle(pos, damp, acc)
	local vel = 0
	return function(to)
		if to == "vel" then
			if set then
				vel = set
				return
			end
			return vel
			
		elseif to == "pos" then
			if set then
				pos = set
				return
			end
			return pos -- not necessary, but for consistency
		end
		
		if to then
			local dif = ((to - pos + 0.5) % 1 - 0.5) * acc
			vel += dif
			vel *= damp
			pos += vel
			if abs(vel) < 0.0006 and abs(dif) < 0.007 then
				pos, vel = to, 0
			end
		end
		return pos
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

function pause_frames(n)
	for i = 1,n do
		yield()
	end
end
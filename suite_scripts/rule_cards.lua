--[[pod_format="raw",created="2024-03-22 04:01:37",modified="2024-03-25 03:04:26",revision=1384]]


function rule_cards_new(x, y, info, side)
	local rc = {
		x = x, y = y, info = info, page = 0,
		draw = rule_cards_draw, 
		update = rule_cards_update
	}
	
	rc.b1 = button_simple_text("\-f\^:181899dbff7e3c18\|j", 3, 227, 
		function()
			if rc.info then
				rc.page += 1
				if rc.page > #rc.info.rules then
					rc.page = 0
				end
			end
		end)
	
	rc.b2 = button_simple_text("\-f\^:183c7effdb991818\|j", 3, 204, 
		function() 
			if rc.info then
				rc.page -= 1
				if rc.page < 0 then
					rc.page = #rc.info.rules
				end
			end
		end)
		
	if not side or side == "left" then
		rc.b1.dx = -19
		rc.b1.dy = 41
		rc.b2.dx = -19
		rc.b2.dy = 18
		
	elseif side == "right" then
		rc.b1.dx = 173
		rc.b1.dy = 41
		rc.b2.dx = 173
		rc.b2.dy = 18
		
	elseif side == "top" then
		-- todo test
		rc.b1.dx = 140
		rc.b1.dy = -19
		rc.b2.dx = 110
		rc.b2.dy = -19
	end
	
	return rc
end

function rule_cards_draw(rc)
	local oldx, oldy = camera()
	camera(oldx-rc.x, oldy-rc.y)
	if rc.y-oldy < 270 then
		-- little inefficient, but eh
		nine_slice(8, 0, 58, 170, 16)
		nine_slice(8, 0, 56, 170, 16)
		
		nine_slice(8, 0, 0, 170, 70)
		
		local s = "Click a deck box to see information about it."
		if rc.info then
			local info = rc.info
			if rc.page == 0 then
				s =  "\n\n" .. info.description
				
				local x = print(info.name, 0, -1000)
				double_print(info.name, 170/2-x/2, 4, 2)
				
				local by = "\nBy " .. info.author
				local x = print(by, 0, -1000)
				double_print(by, 170/2-x/2, 4, 1)
			
			else
				s = info.rules[rc.page]
				
				local num = tostr(rc.page)
				local x = print(num, 0, -1000)
				double_print(num, 170-x-3, 59, 2)
			end
		end
		local lw, lh, loreprint = print_wrap_prep(s, 164)
		double_print(loreprint, 4, 4, 1)
	end
	
	camera(oldx, oldy)
end

function rule_cards_update(rc)
	rc.b1.x = rc.x + rc.b1.dx
	rc.b1.y = rc.y + rc.b1.dy
	
	rc.b2.x = rc.x + rc.b2.dx
	rc.b2.y = rc.y + rc.b2.dy
end

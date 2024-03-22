--[[pod_format="raw",created="2024-03-22 04:01:37",modified="2024-03-22 04:43:11",revision=155]]


function rule_cards_new(x, y, info, on_close)
	local rc = {
		x = x, y = y, info = info, page = 0,
		draw = rule_cards_draw, on_close = on_close
	}
	
	button_simple_text("\-f\^:181899dbff7e3c18\|i", 3, 227, 
		function()
			if rc.info then
				rc.page += 1
				if rc.page > #rc.info.rules then
					notify("b")
					rc.page = 0
				end
			end
		end)
		
	button_simple_text("\-f\^:183c7effdb991818\|i", 3, 204, 
		function() 
			if rc.info then
				rc.page -= 1
				if rc.page < 0 then
					rc.page = #rc.info.rules
				end
			end
		end)
	
	return rc
end

function rule_cards_draw(rc)
	camera(-rc.x, -rc.y)
	
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
	
	camera()
end

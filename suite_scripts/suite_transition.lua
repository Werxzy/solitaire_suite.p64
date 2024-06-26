--[[pod_format="raw",created="2024-06-26 16:05:22",modified="2024-06-26 16:50:53",revision=215]]

local suite_transition_t = 0

function suite_transition_draw()
	if game_transition_draw then
		game_transition_draw()

	elseif suite_transition_t > 0 then
		local t = suite_transition_t
		t *= t * (3 - 2 * t)
		t *= t * (3 - 2 * t)
		
		set_draw_target(suite_transition_screen)
		poke(0x550b, 0x00)
		circfill(480/2, 270/2, (1-t) * 300-1, 0)
		poke(0x550b, 0x3f)
		set_draw_target()
	
		spr(suite_transition_screen, 0, 0)
		
	end
end

function suite_transition_update()
	if game_transition_update then
		game_transition_update()
		
	elseif suite_transition_t > 0 then
		suite_transition_t -= 0.012
	end
end

-- applies the default transition BEFORE game_setup()
-- (if a custom one isn't provided)
function suite_transition_prepare_1()
	if not game_transition_init then
		local d = get_display()
		if d then
			suite_transition_screen = get_display():copy()
			suite_transition_t = 0.9
		end
		
		cards_api_coroutine_add(cocreate(
			function() pause_frames(50) end
		))
		
	end
end

-- applies the custom transition AFTER game_setup()
function suite_transition_prepare_2()
	if game_transition_init then
		game_transition_init()	
		-- ? check if all init, update, and draw are defined.
	end
end


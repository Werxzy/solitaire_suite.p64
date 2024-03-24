--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-24 00:40:05",revision=12325]]

include"cards_api/cards_base.lua"
include"main_menu.lua"

function _init()
	cards_api_load_game"main_menu.lua"
end

function _update()
	cards_api_update()	
--	stat_up = stat(1)
end

function _draw()
	if card_back == 17 then
		camera()
		local mx, my = mouse()
		local disp = get_display()
		mx = mid(mx - card_width\2+1, 480-card_width)
		my = mid(my - card_height\2+1, 270-card_height)
		
		set_draw_target(get_spr(17))

		sspr(disp, mx, my, card_width-4, card_height-4, 2, 2)
		rectfill(2, 2, card_width-3, card_height-3, 32)
		if(time() % 1.5 < 0.75) circfill(7, 7, 2, 8 )circ(7, 7, 2, 32)
		
		fillp(0xf0f0f0f0f0f0f0f0)
		--fillp(0xf0f0f0f0f0f0f0f0 >> (flicker and 4 or 0))
		--flicker = not flicker
		
		rectfill(2, 2, card_width-4, card_height-4, 32)
		fillp()
		nine_slice(25, 0, 0, card_width, card_height, 0)
		set_draw_target()
	end

	cards_api_draw()

--	?stat_up, 111, 220, 6
--	?stat(1)-stat_up
end

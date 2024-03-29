--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-29 02:05:10",revision=13472]]

include"cards_api/cards_base.lua"

function _init()
	cards_api_load_game"suite_scripts/main_menu.lua"
end

function _update()
	cards_api_update()	
--	stat_up = stat(1)
end


function _draw()
	cards_api_draw()

--	?stat_up, 111, 220, 6
--	?stat(1)-stat_up
end

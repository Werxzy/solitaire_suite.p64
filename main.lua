--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-29 05:09:01",revision=13552]]
include"suite_scripts/suite_util.lua"

function _init()
	suite_load_game"suite_scripts/main_menu.lua"
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

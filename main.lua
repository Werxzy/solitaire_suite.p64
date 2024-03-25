--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-25 01:00:35",revision=13019]]

include"cards_api/cards_base.lua"
include"main_menu.lua"

function _init()
	cards_api_save_folder = "/appdata/solitaire_collection"

	cards_api_load_game"main_menu.lua"
end

function _update()
	cards_api_update()	
	stat_up = stat(1)
end


function _draw()
	cards_api_draw()

	?stat_up, 111, 220, 6
	?stat(1)-stat_up
end

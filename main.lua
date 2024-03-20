--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-20 04:31:40",revision=8282]]

include"cards_api/cards_base.lua"
include"cards_api/main_menu.lua"

game_list = {
	"cards_api/solitaire_basic.lua",
	"cards_api/solitaire_basic.lua",
	"cards_api/solitaire_basic.lua",
}

-- other solitaire games to add
-- golf solitaire

function _init()
	--include"cards_api/solitaire_basic.lua"
	main_menu_load()
	--game_setup()
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

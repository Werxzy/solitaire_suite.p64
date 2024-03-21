--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-21 03:49:35",revision=10259]]

include"cards_api/cards_base.lua"
include"cards_api/main_menu.lua"

game_list = {
	"cards_api/solitaire_too.lua",
	"cards_api/golf_solitaire.lua",
}

-- other solitaire games to add
-- golf solitaire

function _init()
	--include"cards_api/solitaire_basic.lua"
	cards_api_load_game"cards_api/main_menu.lua"
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

--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-19 01:35:04",revision=5690]]

include"cards_api/cards_base.lua"

function _init()
	include"cards_api/solitaire_basic.lua"
	game_setup()
end

function _update()
	cards_api_update()	
end


function _draw()
	cls(3)
	cards_api_draw()

--	?stat(1), 1, 262, 6
end

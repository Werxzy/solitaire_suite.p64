--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-18 19:24:34",revision=5084]]

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
	local tt = time()/5
	nine_slice(55, 150,150, sin(tt)*50+53, cos(tt)*25+28, 19)
	?stat(1), 1, 262, 6
end

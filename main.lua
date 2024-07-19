--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-07-19 19:06:57",revision=23815]]
include"suite_scripts/suite_util.lua"

function _init()
-- I think this is okay? (still doesn't close workspace on exit though)
--[=[
	window{
		fullscreen = 1,
		width = 480, 
		height = 270,
		autoclose = true,
		pauseable = false,
		icon = 
--[[pod,pod_type="image"]]unpod("b64:bHo0ABwAAAAaAAAA8AtweHUAQyAICAQgF0A3IFcAdwAXEBcwF0A3kA==")
}
	
-- ]=]

	suite_load_game"suite_scripts/main_menu.lua"
end

function _update()
--	stat_up = stat(1)
	cards_api_update()	
--	stat_up = stat(1) - stat_up
end


function _draw()
--	stat_up2 = stat(1)
	cards_api_draw()
--	stat_up2 = stat(1) - stat_up2
	
--	?stat_up, 111, 220, 8
--	?stat_up2
--	set_clipboard(tostr(stat_up2) .. " / " .. tostr(stat_up + stat_up2))
--	?stat(7)
end

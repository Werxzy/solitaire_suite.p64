--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-31 21:32:31",revision=13945]]
include"suite_scripts/suite_util.lua"

function _init()
-- I think this is okay? (still doesn't close workspace on exit though)
--[=[
	window{
		fullscreen = 1,
		width = 480, 
		height = 270,
		icon = 
--[[pod,pod_type="image"]]unpod("b64:bHo0ABwAAAAaAAAA8AtweHUAQyAICAQgF0A3IFcAdwAXEBcwF0A3kA==")
}
-- ]=]
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

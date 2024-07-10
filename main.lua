--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-07-08 00:13:25",revision=20257]]
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

--[[ performance measurements for card occlusion

before : 
main menu : 0.27928975037551 / 0.33896359344825
normal : 0.40319361991274 / 0.52898576639725
spider : 0.44932765896574 / 0.60144839424934

after (full occlusion only) :
main menu : 0.29728560188828 / 0.35700951291038
normal  :0.37964022602103 / 0.50543237250554
spider : 0.410603676418 / 0.56269580144482 

after (remove draw only) :
main menu : 0.29679922752307 / 0.35648022316
normal : 0.29320864029755 / 0.41899363421787
spider : 0.30183105643373 / 0.45371575709892
]]

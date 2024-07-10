--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-07-10 09:33:48",revision=1893]]

function game_info()
	return {
--		sprite = can be userdata
		name = "Falling Cards",
		author = "Werxzy",
		description = "Example project to be used as a base.",
		rules = {
			"Rules Text",
			"Page 2 test"
		},
		desc_score = {
			format = "Highscore : %i",
			param = {"highscore"}
		},
		api_version = 2,
		order = 1
	}
end

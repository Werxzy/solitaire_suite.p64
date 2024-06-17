--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-06-17 10:09:48",revision=432]]

function game_info()
	return {
		sprite = 32,
		name = "Example Project",
		author = "Your Name Here",
		description = "Example project to be used as a base.",
		rules = {
			"Rules Text"
		},
		desc_score = {
			format = "Wins : %i",
			param = {"wins"}
		},
		api_version = 2,
		order = 1
	}
end

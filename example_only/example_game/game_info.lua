--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-06-29 20:43:30",revision=1339]]

function game_info()
	return {
--		sprite = userdata
			-- sprite used to represent the game on the main menu.
			-- defaults to sprite 0 in the neighboring file, 1.gfx
		name = "Example Project",
		author = "Your Name Here",
		description = "Example project to be used as a base.",
		rules = {
			"Rules Text",
			"Page 2 test"
		},
		desc_score = {-- extra information about the player's save
			format = "Wins : %i", -- ran through string.format
			param = {"wins"} -- keys indexing the game save
		},
		api_version = 2, -- must match the current api version to ensure compatability, there could be breaking changes in the future
		-- order = 1 -- display order of games in the mod
	}
end

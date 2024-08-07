--[[pod_format="raw",created="2024-03-25 02:11:53",modified="2024-07-17 07:07:44",revision=375]]

function game_info()
	return {
		name = "Golf Solitaire",
		author = "Werxzy",
		description = "Return all cards to the goal stack. Neighboring ranks only.",
		rules = {
			"\tTo win, place all cards on the goal stack at the bottom, which starts empty",
			"\tCards can only be moved to the goal stack, The goal stack can have any card placed on it while empty.",
			"\tWhen cards occupy the goal stack, only cards 1 rank higher or lower can be placed on top.",
			"\tKings and Aces can be placed on top of each other on the goal stack.",
			"\tClick the supply stack on the left to replace the top card.",
			"\tIf you cannot place a card from anywhere onto the goal stack, you cannot win and must start a new game."
		},
		desc_score = {
			format = "Wins : %i",
			param = {"wins"}
		},
		api_version = 2,
		order = 3
	}
end

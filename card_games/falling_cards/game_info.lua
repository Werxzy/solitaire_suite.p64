--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-07-20 15:02:44",revision=5160]]

function game_info()
	return {
--		sprite = can be userdata
		name = "Falling Solitaire",
		author = "Werxzy",
		description = "A point based solitaire game, where if a stack gets too tall, it's gameover",
		rules = {
			"Score points by creating stacks of cards going from 5 to 1. Build your combo meter to score more points.",
			"Cards can only be placed on an empty space or another card that's 1 rank higher. Up to 3 individual cards can be placed in storage on ther right side.",
			"Moving a card or pressing the 'DROP' button will reveal a card on the top row. When a card is moved while all 5 cards are revealed, all cards will drop to the stacks below them and 5 new cards will be dealt.",
			"Every 4 stacks will increase the level and will reveal a number of cards equal to the current level plus 1, rounded down.",
			"If a card is placed on a stack, during a card reveal, when there are 10 or more cards on that stack, then it will be gameover.",
			"Three bonus cards can be placed onto another stack to activate their ability or placed in storage to use later. Every level, one of the next cards will be replaced with a bonus card.",
			"Bomb - Clears an entire stack.\nWild - Acts as any number card.\nShuffle - Shuffles and evenly distributes all cards, then hides all revealed cards."
		},
		desc_score = {
			format = "Highscore : %i",
			param = {"highscore"}
		},
		api_version = 2,
		order = 9999
	}
end

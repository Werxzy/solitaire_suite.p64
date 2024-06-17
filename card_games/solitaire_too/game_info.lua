--[[pod_format="raw",created="2024-03-25 02:13:51",modified="2024-06-17 10:00:05",revision=72]]

function game_info()
	return {
		sprite = 40,
		name = "Solitaire Too",
		author = "Werxzy",
		description = "Similar to standard solitaire, but can alternate between any suit.",
		rules = {
			"\tStack cards of the same suit, from Ace to King, in the card slots to the right",
			"\tCards can be stacked in the 7 middle slots if they don't match in suit and are 1 rank lower than the card below.\n\tAce is rank 1. Jack, Queen, King are rank 11, 12, 13.",
			"\tClick the deck to reveal a new card. Revealed cards can be moved one at a time and can't be stacked on.",
			"\tWhen the deck is out of cards, click the refresh button in the top left to move all the revealed cards back.",
			"\tIf you believe you have reached a state in which you cannot progress further, you will have to start a new game."
		},
		desc_score = {
			format = "Wins : %i",
			param = {"wins"}
		},
		api_version = 2,
		order = 2
	}
end

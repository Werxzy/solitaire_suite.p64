--[[pod_format="raw",created="2024-03-25 02:13:51",modified="2024-03-25 02:17:14",revision=25]]

function game_info()
	return {
		sprite = 40,
		name = "Solitaire Too",
		author = "Werxzy",
		description = "Similar to standard solitaire, but can alternate between any suit.",
		rules = {
			"\tStack cards of the same suit, from Ace to King, in the card slots on the right",
			"\tCards can be stacked in the 7 middle slots if they don't match in suit and are 1 rank lower than the card below.\n\tAce is rank 1. Jack, Queen, King are rank 10, 11, 12.",
			"\tClick the deck to draw a reveal a card. Revealed cards can be moved noramlly one at a time, but can't be stacked on.",
			"\tWhen the deck is out of cards, click the its deck slot to move all the cards back.",
			"\tIf you believe you have reached a state in which you cannot move any cards, you will have to start a new game."
		},
		api_version = 1,
		order = 2
	}
end

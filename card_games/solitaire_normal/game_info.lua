--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-03-25 02:13:15",revision=6]]

function game_info()
	return {
		sprite = 24,
		name = "Solitaire",
		author = "Werxzy",
		description = "The game you know and love/hate.",
		rules = {
			"\tStack cards of the same suit, from Ace to King, in the card slots on the right",
			"\tCards can be stacked in the 7 middle slots if alternate between red and black suits (hearts/diamonds and spades/clubs) and are 1 rank lower than the card below.",
			"\tAce is rank 1. Jack, Queen, King are rank 10, 11, 12.",
			"\tClick the deck to draw a reveal the next 3 cards. You can play the top revealed card, but can't stack on top of it.",
			"\tWhen the deck is out of cards, click the its deck slot to move all the cards back.",
			"\tIf you believe you have reached a state in which you cannot move any cards, you will have to start a new game."
		},
		api_version = 1,
		order = 1
	}
end

--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-06-24 19:55:31",revision=224]]

function game_info()
	return {
		name = "Solitaire",
		author = "Werxzy",
		description = "The game you know and love/hate.",
		rules = {
			"\tStack cards of the same suit, from Ace to King, in the card slots on the right",
			"\tCards can be stacked in the 7 middle slots if alternate between red and black suits (hearts/diamonds and spades/clubs) and are 1 rank lower than the card below.",
			"\tAce is rank 1. Jack, Queen, King are rank 11, 12, 13.",
			"\tClick the deck to draw a reveal the next 3 cards. You can play the top revealed card, but can't stack on top of it.",
			"\tWhen the deck is out of cards, click the refresh button in the top left to move all the revealed cards back.",
			"\tIf you believe you have reached a state in which you cannot progress further, you will have to start a new game."
		},
		desc_score = {
			format = "Wins : %i",
			param = {"wins"}
		},
		api_version = 2,
		order = 1
	}
end

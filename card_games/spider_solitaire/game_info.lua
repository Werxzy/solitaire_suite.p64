--[[pod_format="raw",created="2024-03-25 02:14:11",modified="2024-03-29 04:02:49",revision=616]]

function game_info()
	return {
		sprite = 56,
		name = "Spider Solitaire",
		author = "Werxzy",
		description = "Create stacks from King to Ace.",
		rules = {
			"\tCards may be placed onto another card of one rank higher\n\tMultiple cards can be picked up as long as each are one rank lower than the card on top of them.",
			"\tFace down cards cannot be picked up and will turn face up when there is no card on top of them.",
			"\tClick on the deck to place a card on top of each stack of the 8 stacks.",
			"\tStack cards from ranks King to Ace to transfer them to the goal stack.\n\tWin by transfering all cards to the goal stack."
		},
		api_version = 1
	}
end

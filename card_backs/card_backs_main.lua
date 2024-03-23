--[[pod_format="raw",created="2024-03-20 14:39:52",modified="2024-03-23 04:28:27",revision=1352]]


-- todo, fetch cards in folder in appdata

-- sprite can be a number or userdata
--[[ !!! warning !!! 
While sprite card backs are usually 45x60,
They will likely become 100x100 sprites without the card boarder.
This is so that a card back can be generated for most card sizes
]]

-- id can be a number or string, just make sure it doesn't match any other card's
-- used to save card back selected
function get_info()
	return {
		{ 
			-- either a number for the sprite id in the spritesheet, or userdata
			sprite = 10, 
			-- obviously the artist
			artist = "Werxzy",
			-- unique identifier, should not match any other card
			id = 1,
			-- extra info about the card art
			lore = "Picotron Icon"
		},
		{ 
			sprite = 18, artist = "Werxzy", id = 2,
			lore = "(And technically Zep) \nZep's Jelpi from Pico-8"
		},
		{ 
			sprite = 19, artist = "Werxzy", id = 3,
			lore = "Box from SokoCode by Werxzy"
		},
		{ 
			sprite = 1, artist = "Werxzy", id = 4,
			lore = "The first card back!"
		},
		{ 
			sprite = 35, artist = "Werxzy", id = 5,
			lore = "Card back created from there being too many blue card backs."
		},
		{ 
			sprite = 36, artist = "Werxzy", id = 6,
			lore = "Referenced from Window's original solitaire card back."
		},
		{ 
			sprite = 21, artist = "Werxzy", id = 7,
			lore = "Referenced from Window's original solitaire card back."
		},
		{ 
			sprite = 26, artist = "Werxzy", id = 8,
			lore = "Pico-8 Icon"
		},
		{
			sprite = 17, artist = "You", id = 9,
			lore = "Ever feel like you're being watched?"
		}
	}
end


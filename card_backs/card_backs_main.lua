--[[pod_format="raw",created="2024-03-20 14:39:52",modified="2024-03-25 01:00:35",revision=1807]]


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
		card_back_animated(camera_card_back, {
			artist = "You", id = 9,
			lore = "Ever feel like you're being watched?"
		})
	}
end

function camera_card_back(init, data)
	if init or not data.sprite then
		data.sprite = userdata("u8", card_width, card_height)
	end

	camera()
	local mx, my = mouse()
	local disp = get_display()
	mx = mid(mx - card_width\2+1, 480-card_width)
	my = mid(my - card_height\2+1, 270-card_height)
	
	set_draw_target(data.sprite)
	rectfill(2, 2, card_width-3, card_height-3,1)
	sspr(disp, mx, my, card_width-4, card_height-4, 2, 2)
	rectfill(2, 2, card_width-3, card_height-3, 32)
	if(time() % 1.5 < 0.75) circfill(7, 7, 2, 8 )circ(7, 7, 2, 32)
	
	fillp(0xf0f0f0f0f0f0f0f0)
	--fillp(0xf0f0f0f0f0f0f0f0 >> (flicker and 4 or 0))
	--flicker = not flicker
	
	rectfill(2, 2, card_width-4, card_height-4, 32)
	fillp()
	nine_slice(25, 0, 0, card_width, card_height, 0)
	set_draw_target()
end


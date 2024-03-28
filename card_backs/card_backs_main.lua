--[[pod_format="raw",created="2024-03-20 14:39:52",modified="2024-03-28 03:40:41",revision=2450]]


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
			sprite = camera_card_back, artist = "You", id = 9,
			lore = "Ever feel like you're being watched?"
		}
	}
end

-- when init is true, the card art will need to be recreated reguardless
-- card_art_width and card_art_height are given to help know the art's bounds
-- camera and clip are used around this function, so be careful
-- data is the card back sprite info
function camera_card_back(init, data)
	-- get mouse position
	local mx, my = mouse()
	mx = mid(mx - card_art_width\2+1, 480-card_art_height)
	my = mid(my - card_art_width\2+1, 270-card_art_height)
	
	rectfill(0, 0, card_art_width-1, card_art_height-1, 1) -- base (prevent transparent pixels
	sspr(get_display(), mx, my, card_art_width, card_art_height, 0, 0) -- screen
	rectfill(0, 0, card_art_width-1, card_art_height-1, 32) -- darken
	if(time() % 1.5 < 0.75) circfill(5, 5, 2, 8) circ(5, 5, 2, 32) -- red dot
	
	-- scanlines
	fillp(0xf0f0f0f0f0f0f0f0)	
	rectfill(0, 0, card_art_width-1, card_art_height-1, 32)
	fillp()
	
	-- returns if the art has been updated (here is always true)
	return true
end

function random_card_back(init, data)
	if init then
		rectfill(0, 0, card_art_width-1, card_art_height-1, 5)
		color(32)
	--[[
		for i = 1,40 do
			line(rnd(card_art_width)/2, rnd(card_art_height)/2)
		end
		local w, h = card_art_width\2, card_art_height\2
		sspr(data.sprite, 0, 0, w, h+3, w-1, -2, w, h+3, true, false)
		sspr(data.sprite, 0, 0, card_width, h, -2, h-1, card_width, h, false, true)
	]]
		local w, h = card_art_width/2, card_art_height/2
		local r = w * 0.6
		local ph = rnd(10)+2
		for i = 1,140 do
			local r2 = sin(i/ph)*6
			line(sin(i/20) * (r + r2) + w, cos(i/20) * (r+r2) + h)
		end

		return true	
	end
end


--[[

function get_info()
    return {
        {
            sprite = card_back_art, -- sprite_id, userdata, or function
            artist = "Artist", -- who made the art
            id = 14141414232, -- consistent, but unique id
            lore = "info about the art or whatever you want"
        }
    }
end

function card_back_art(init, data)
  -- if you only need to generate the art once, use init
  -- data has the table returned by get_info(), just in case you need to get the sprite itself or if you want to store extra data
  
  -- camera, clip, and set_render_target() are used outside of this function to help simplify the process
  
  -- card_art_width and _height are created to help you know the exact size of your art
  -- this is different from card_width/height
  circfill(card_art_width/2, card_art_height/2, card_art_width/2, 10)
  
  -- color 32 is special, and can be used for darkening colors (for stuff like shadows)

  -- return true if the card art has been updated (this adds the card border or makes cuts to the art)
  return true
end

]]

--[[pod_format="raw",created="2024-03-20 14:39:52",modified="2024-07-02 18:26:11",revision=3235]]


-- NOTE, make your own .lua file along side this one instead of modifying this one.
-- this file is ignored when loading it as a Mod inside Picotron Solitaire Suite

-- sprite can be a number or userdata

-- id can be a number or string, just make sure it doesn't match any other card's
-- used to save card back selected
function get_info()
	return {
		{ 
			-- either a number for the sprite id in the spritesheet, or userdata
			sprite = 113, 
			-- obviously the artist
			artist = "Werxzy",
			-- unique identifier, should not match any other card
			id = 1,
			-- extra info about the card art
			lore = "Picotron Icon"
		},
		{ 
			sprite = 119, artist = "Werxzy", id = 2,
			lore = "(And technically Zep) \nZep's Jelpi from Pico-8"
		},
		{ 
			sprite = 114, artist = "Werxzy", id = 3,
			lore = "Box from SokoCode by Werxzy"
		},
		{ 
			sprite = 112, artist = "Werxzy", id = 4,
			lore = "The first card back!"
		},
		{ 
			sprite = 116, artist = "Werxzy", id = 5,
			lore = "Card back created from there being too many blue card backs."
		},
		{ 
			sprite = 120, artist = "Werxzy", id = 6,
			lore = "Referenced from Window's original solitaire card back."
		},
		{ 
			sprite = 118, artist = "Werxzy", id = 7,
			lore = "Referenced from Window's original solitaire card back."
		},
		{ 
			sprite = 115, artist = "Werxzy", id = 8,
			lore = "Pico-8 Icon"
		},
		{
			sprite = camera_card_back, artist = "You", id = 9,
			lore = "Ever feel like you're being watched?"
		},
		{ 
			sprite = 117, artist = "Werxzy", id = "vox",
			lore = "Voxatron Icon"
		},
	}
end

-- when init is true, the card art will need to be recreated reguardless
-- card_art_width and card_art_height are given to help know the art's bounds
-- camera and clip are used around this function, so be careful
-- data is the card back sprite info
function camera_card_back(data, width, height)
	-- get mouse position
	local mx, my = mouse()
	mx = mid(mx - width\2+1, 480-width) -- technically also use - left or -top
	my = mid(my - height\2+2, 270-height)
	
	rectfill(0, 0, width-1, height-1, 1) -- base (prevent transparent pixels
	sspr(get_display(), mx, my, width, height, 0, 0) -- screen
	rectfill(0, 0, width-1, height-1, 32) -- darken
	if(time() % 1.5 < 0.75) circfill(5, 5, 2, 8) circ(5, 5, 2, 32) -- red dot
	
	-- scanlines
	fillp(0xf0f0f0f0f0f0f0f0)	
	rectfill(0, 0, width-1, height-1, 32)
	fillp()
	
	-- returns if the art has been updated (here is always true)
	return true
end

function random_card_back(data, width, height)
	if init then
		rectfill(0, 0, width-1, height-1, 5)
		color(32)
	--[[
		for i = 1,40 do
			line(rnd(width)/2, rnd(height)/2)
		end
		local w, h = width\2, height\2
		sspr(data.sprite, 0, 0, w, h+3, w-1, -2, w, h+3, true, false)
		sspr(data.sprite, 0, 0, width, h, -2, h-1, height, h, false, true)
	]]
		local w, h = width/2, height/2
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

function card_back_art(data, width, height)
  -- if you only need to generate the art once, use init
  -- data has the table returned by get_info(), just in case you need to get the sprite itself or if you want to store extra data
  
  -- camera, clip, and set_render_target() are used outside of this function to help simplify the process
  
  -- width and height are created to help you know the exact size of your art
  circfill(width/2, height/2, width/2, 10)
  
  -- color 32 is special, and can be used for darkening colors (for stuff like shadows)

  -- return true if the card art has been updated (this adds the card border or makes cuts to the art)
  return true
end

]]

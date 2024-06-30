--[[pod_format="raw",created="2024-06-29 22:17:29",modified="2024-06-29 22:45:52",revision=117]]
# Picotron Solitaire Suite

Here I'm only showing Picotron Solitaire Suite specific functions. To see the main list, check out the api readme (https://github.com/Werxzy/cards_api/blob/main/README.md).
A lot of this is subject to change, so I'll try to keep incremental changes from breaking any main versions. While having major changes require a version check for each game.

It would be a good idea to look at some of the games inside the folder `solitaire_suite.p64/card_games/` or https://github.com/Werxzy/solitaire_suite.p64/tree/main/card_games to get an idea of how they are formatted. 
LouieChapm also has his games up at https://github.com/LouieChapm/picotronSolitaireSuite_Variants.

## Setup

Game files can either be placed inside `appdata/solitaire_suite/card_games/`.
To ensure that the right information is being loaded, have your file structure look like this

```
/appdata/solitaire_suite/card_games/GAMENAME/game_info.lua
/appdata/solitaire_suite/card_games/GAMENAME/GAMENAME.lua
/appdata/solitaire_suite/card_games/GAMENAME/...
```

The suite will look for files named `game_info.lua` and their parent folder to determine what `GAMENAME` is.
Any other files can be included inside `/GAMENAME/`

When using `include` or `fetch`, start your path with `/game/` in order to get the files relative to `game_info.lua` and `GAMENAME.lua`.
This will help the Suite in fetching the right files, even if they are loaded into `/appdata/`

### game_info.lua

This file just contains a single function that returns a table containing information for the game

```lua
function game_info()
	return {
		sprite = 32, -- generally, you will want to put userdata here instead of a sprite id
		name = "name of the game", -- does not have to match the file name
		author = "YOU!",
		description = "Quick description of the game",
		rules = {
			"table of rules to help the player"
		},
		api_version = 1, -- must match the current api version to ensure compatability, there could be breaking changes in the future
		-- order = 3, -- placement inside the list of cards, best to leave nil for now
	}
end
```

### GAMENAME.lua

Inside the primary lua file, you should have something similar to this.

```lua
-- mostly for ease of use like _init() 
function game_setup()
	-- create any stacks, cards, or other objects here
end

-- called when the game is about to exit a game variant
function game_on_exit()
end

-- functions detailed in the Card API
function game_update() end
function game_draw() end
function game_win_condition() end
function game_count_win() end

end -- end of game_load
```

### Custom Card Backs

by putting a lua file inside `/appdata/solitaire_suite/card_backs/` you can create your own card backs

```lua
function get_info()
	return {
		--each entry is a card back
		{
			sprite = card_back_art, -- sprite_id, userdata, or function
			
			artist = "Artist", -- who made the art
			
			id = 14141414232, -- consistent, but unique id
			
			lore = "info about the art or whatever you want"
		}
	}
end

-- if you're using a function try to follow this format
function card_back_art(init, data)
	-- if you only need to generate the art once, use init
	-- init is true whenever the card back needs to be fully updated from stuff like size changes

	-- data has the table returned by get_info(), just in case you need to get the sprite itself or if you want to store extra data
	
	-- camera, clip, and set_render_target() are used outside of this function to help simplify the process
	-- !!! do NOT use the functions or cls !!!
	
	-- card_art_width and _height are created to help you know the exact size of your art
	-- this is different from card_width/height
	rectfill(0, 0, card_art_width, card_art_height, 2)
	circfill(card_art_width/2, card_art_height/2, card_art_width/2 + sin(time()/5) * 5 , 10)
	
	-- color 32 is special, and can be used for darkening colors (for stuff like shadows)
	
	-- return true if the card art has been updated (this adds the card border or makes cuts to the art)
	return true
end
```

## Suite Functions

```lua
-- called to exit a game
-- currently doesn't do much, but will be important later
suite_exit_game()

-- gets save data as a table (with "or defaults" if one doesn't exits)
-- automatically manage save location
local save_info = suite_load_save() or { wins = 0 }

-- stores save data
suit_store_save(save_info)
```

There's also other lua files inside `/solitaire_suite.p64/suite_scripts/` that can help.


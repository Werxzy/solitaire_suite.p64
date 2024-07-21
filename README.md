--[[pod_format="raw",created="2024-06-29 22:17:29",modified="2024-06-29 22:45:52",revision=117]]
# Picotron Solitaire Suite

Here I'm only showing Picotron Solitaire Suite specific functions. To see the main list, check out the api readme (https://github.com/Werxzy/cards_api/blob/main/README.md).
A lot of this is subject to change, so I'll try to keep incremental changes from breaking any main versions. While having major changes require a version check for each game.

It would be a good idea to look at some of the games inside the folder `solitaire_suite.p64/card_games/` or https://github.com/Werxzy/solitaire_suite.p64/tree/main/card_games to get an idea of how they are formatted. 
LouieChapm also has his games up at https://github.com/LouieChapm/picotronSolitaireSuite_Variants.

**ALSO, I would highly recommend starting from the example project instead of working from the main cart or the git repository. As it is more designed for modding.**

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

```lua
include"/game/stack_rules.lua"

file = fetch"/game/extra.pod"
```

By naming a graphics file "`1.gfx`", it will be automatically set the sprites into ids 256 to 512 when the games is loaded.
This will also work with file names 2 and above.
More importantly, sprite 0, or 256 here, will be used for the card box sprite that will be displayed on the main menu.

### game_info.lua

This file just contains a single function that returns a table containing information for the game

```lua
function game_info()
	return {
		--sprite = 32, -- sprite used to represent the game on the main menu.
			-- can be userdata
			-- will default to sprite 0 in 1.gfx if one isn't provided
		name = "name of the game", -- does not have to match the file name
		author = "YOU!",
		description = "Quick description of the game",
		rules = {
			"table of rules to help the player"
		},
		desc_score = { -- extra information about the player's save
			format = "Wins : %i", -- ran through string.format
			param = {"wins"} -- keys indexing the game save
		},
		api_version = 2, -- must match the current api version to ensure compatability, there could be breaking changes in the future
		-- order = 3, -- placement inside the list of games, grouped up by mod
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
function game_on_exit() end

-- functions called for when the game settings are opened or closed
function game_settings_opened() end
function game_settings_closed() end

-- functions for a custom transition
-- can be left undefined, and a default transition will take place
function game_transition_init() end
function game_transition_draw() end
function game_transition_update() end

-- functions detailed in the Card API
function game_update() end
function game_draw() end
function game_win_condition() end
function game_count_win() end
function game_action_resolved() end

-- function that will be called when an error occurs in game
-- if an error occurs, the game will be booted back to the main menu
-- this can be used to save the state of the game, to be returned to later
function subgame_on_error() end
```

### Custom Card Backs

By putting a lua file inside `/appdata/solitaire_suite/card_backs/` you can create your own card backs.
These can also be included in your mods under `solitaire_suite.p64/card_backs/` to be sharable with others.

```lua
function get_info()
	return {
		--each entry is a card back
		{
			sprite = card_back_art, -- userdata or function. sprite ids will only pull from 0.gfx
			
			artist = "Artist", -- who made the art
			
			lore = "info about the art or whatever you want"
		}
	}
end

-- if you're using a function try to follow this format
function card_back_art(data, width, height)
	-- data has the table returned by get_info(), just in case you need to get the sprite itself or if you want to store extra data
	-- width and height are the size of the drawable area
	-- these are different from the actual card sprite's size
	
	-- camera, clip, and set_render_target() are used outside of this function to help simplify the process
	-- !!! do NOT use the functions clip or cls !!!
	
	rectfill(0, 0, width, height, 2)
	circfill(width/2, height/2, width/2 + sin(time()/5) * 5 , 10)
	
	-- color 32 is special, and can be used for darkening colors (for stuff like shadows)
end
```

### Enclosed ENV

Loaded games have their own ENV table to prevent cross contamination and inappropriate access to functions and variables from other games and the suite itself.
Only functions are copied over to the new ENV.
This is also to prevent malicious mods, though if there is something missing, please let me know

```lua
-- at the moment, the following is prevented access
-- this can be found near the start of suite_util.lua, assigned to banned_env

banned_env = split([[

cp
rm
mk_dir
mv
create_process
env
window

store
include
fetch

...

]], "\n", false)


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
suite_store_save(save_info)

-- creates most of the menu bar at the bottom of the screen. Very important to call or add something similar
suite_menuitem_init()

--creates a button for the menu bar
suite_menuitem(param)
--[[
param is a table with the following possible values

text = text displayed on the button
on_click = function called when the button is clicked
value = extra info displayed next to the text that can be updated, like a win counter
	can be left nil
pages = table of strings or userdata that be displayed on a seperate window when the button is clicked
	note that this will replace the on_click call
colors = table of color values to draw the button with
]]

-- creates a button for the menu bar for displaying the game's rules
-- the width and height of the window can be adjusted
suite_menuitem_rules(width, height)

--creates a simple button
suite_button_simple(param)
--[[
param is a table with the following possible values

x, y = position of the button
text = text displayed on the button, also controlling the size
on_click = function called when the button is clicked
group = drawing group the button belongs to, defaults to 1
always_active = if true, then the button can be clicked even if an animation is playing
colors = table of colors that the button is drawn with

]]
```

There's also other lua files inside `/solitaire_suite.p64/suite_scripts/` that can help.

## Cart Metadata

You can edit the cart's metadata to display information inside the mod manager.
Title, version, author, notes and the icon will show when the mod is installed and selected.

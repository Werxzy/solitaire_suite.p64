# Picotron Solitaire Suite

Here I'm only showing Picotron Solitaire Suite specific functions. To see the main list, check out the api readme : https://github.com/Werxzy/cards_api/blob/main/README.md

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

## Suite Functions
```

-- called 
function game_on_exit()
end

suite_load_save()

```


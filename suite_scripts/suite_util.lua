--[[pod_format="raw",created="2024-03-29 03:13:35",modified="2024-03-29 09:24:15",revision=230]]
include"cards_api/cards_base.lua"

suite_save_folder = "/appdata/solitaire_suite"
game_version = "0.1.0"
api_version_expected = 1

mkdir(suite_save_folder)
mkdir(suite_save_folder .. "/card_games")
mkdir(suite_save_folder .. "/card_backs")
mkdir(suite_save_folder .. "/saves")

function suite_load_game(game_path)
	-- example "card_games/solitaire_basic.lua"
	local path = split(game_path, "/")
	path = path[#path]
	path = split(path, ".")
	
	assert(path[2] == "lua")
	
	suite_game_name = path[1]
	
	include(game_path)
	
	game_load()
	game_setup()
end

function suite_exit_game()
	-- for that specific game
	if(game_on_exit) game_on_exit()
	
	-- where to go next
	if cards_game_exiting then
		cards_game_exiting()
	else
		exit()
	end
end

-- grabs the requested save file
-- ensures that the proper folder exists
-- returns nil if save does not exist
function suite_load_save(extra_folder)
	assert(suite_save_folder, "Save location must be specified.")
	
	suite_saveloc = suite_save_folder .. "/saves/"
		.. suite_game_name .. ".pod"
		
	return fetch(suite_saveloc)
end

-- saves a table of data at established location
function suite_store_save(data)
	store(suite_saveloc, data)
end
--[[pod_format="raw",created="2024-03-29 03:13:35",modified="2024-06-04 05:29:45",revision=1420]]
include"cards_api/cards_base.lua"

suite_save_folder = "/appdata/solitaire_suite"
game_version = "0.2.0 DEV"
api_version_expected = 2

mkdir(suite_save_folder)
mkdir(suite_save_folder .. "/card_games")
mkdir(suite_save_folder .. "/card_backs")
mkdir(suite_save_folder .. "/saves")

clean_env = split([[
game_setup
game_update
game_draw
game_on_exit
game_count_win
game_win_condition
game_win_anim
]], "\n", false)
old_env = {}

function suite_load_game(game_path)
	-- example "card_games/solitaire_basic.lua"
	local path = split(game_path, "/")
	path = path[#path]
	path = split(path, ".")
	
	assert(path[2] == "lua")
	
	suite_game_name = path[1]

-- [[
-- slight cleanup step
	for c in all(clean_env) do
		_ENV[c] = nil
	end
	for c in all(old_env) do
		_ENV[c] = nil
	end
	local _e = {}
	for k,v in pairs(_ENV) do
		_e[k] = v
	end

-- prepare the game
	include(game_path)
	game_setup()
	
-- prepares cleanup for next phase if there is anything left over
-- done by looking for new values that were created during include and setup
	if game_path != "suite_scripts/main_menu.lua" then
		old_env = {}
		for k,v in pairs(_ENV) do
			if _e[k] == nil then
				add(old_env, k)
			end
		end
	end
--]]

	
--[[ attempt at encapsulating the game environment

	if game_path ~= "suite_scripts/main_menu.lua" then
		
		game_env = {}
		for k,v in pairs(_ENV) do
			game_env[k] = v
		end
	
		for b in all(banned_env) do
		--	game_env[b] = nil
		end
		game_env.include = cap_include(game_env)
		--local func,err = load(src, "@"..filename, "t", _ENV)
		local func, err = load(fetch(game_path), "@".. fullpath(game_path), "t", game_env)
		--local ok = pcall(func)
		func()

	--	if(not ok) stop()
		for c in all(copied_env) do
			_ENV[c] = game_env[c]
		end
		
		game_setup()
		
		--get_held_stack()
	else
		
		include(game_path)
		game_setup()
	end
--]]
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
function suite_load_save()
	assert(suite_save_folder, "Save location must be specified.")
	
	suite_saveloc = suite_save_folder .. "/saves/"
		.. suite_game_name .. ".pod"
		
	return fetch(suite_saveloc)
end

-- saves a table of data at established location
function suite_store_save(data)
	store(suite_saveloc, data)
end



--[=[
banned_env =	split([[
banned_env
game_env
store
fetch
]], "\n", false)

copied_env = split([[
game_on_exit

game_load
game_setup

game_draw
game_update
cards_game_exiting

]], "\n", false)
]=]

--[[
function cap_include(new_env)
	return function(filename)
		local filename = fullpath(filename)
		local src = fetch(filename)
	
		if (type(src) ~= "string") then 
			notify("could not include "..filename)
			stop()
			return
		end
	
		local pwd0 = pwd()
		
		-- https://www.lua.org/manual/5.4/manual.html#pdf-load
		-- chunk name (for error reporting), mode ("t" for text only -- no binary chunk loading), _ENV upvalue
		-- @ is a special character that tells debugger the string is a filename
		local func,err = load(src, "@"..filename, "t", new_env)
	
		-- syntax error while loading
		if (not func) then 
			-- printh("** syntax error in "..filename..": "..tostr(err))
			--notify("syntax error in "..filename.."\n"..tostr(err))
			send_message(3, {event="report_error", content = "*syntax error"})
			send_message(3, {event="report_error", content = tostr(err)})
	
			stop()
			return
		end
		func()
	
		return true -- ok, no error including
	end
end
]]
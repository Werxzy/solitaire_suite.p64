--[[pod_format="raw",created="2024-03-29 03:13:35",modified="2024-06-26 15:55:31",revision=8151]]
include"cards_api/cards_base.lua"
include"suite_scripts/suite_buttons.lua"
include"suite_scripts/suite_extra_window.lua"

suite_save_folder = "/appdata/solitaire_suite"
game_version = "0.2.0 DEV"
api_version_expected = 2

mkdir(suite_save_folder)
mkdir(suite_save_folder .. "/card_games")
mkdir(suite_save_folder .. "/card_backs")
mkdir(suite_save_folder .. "/saves")

banned_env =	split([[
store
fetch
]], "\n", false)

copied_env = split([[
game_setup
game_draw
game_update
game_action_resolved
game_on_exit

game_settings_opened

game_count_win
game_win_condition
game_win_anim

]], "\n", false)

suite_transition_t = 0
first_load = true

function suite_get_game_name(game_path)
	local path = split(game_path, "/")
	path = path[#path]
	path = split(path, ".")
	
	assert(path[2] == "lua")
	
	return path[1]
end


local function suite_draw_wrapper()
	local old_draw = game_draw
	function game_draw(layer)
		old_draw(layer)
		
		suite_window_draw(layer)
		
		if layer == 2 then
			suite_menuitem_draw_pages()
			
		elseif layer == 3 then -- reserved for menus like settings
		
		
		elseif layer == 4 then
			if suite_transition_t > 0 then
				
				suite_transition_t -= 0.012
				local t = suite_transition_t
				t *= t * (3 - 2 * t)
				t *= t * (3 - 2 * t)
				
				set_draw_target(suite_transition_screen)
				poke(0x550b, 0x00)
				circfill(480/2, 270/2, (1-t) * 300-1, 0)
				poke(0x550b, 0x3f)
				set_draw_target()
			
				spr(suite_transition_screen, 0, 0)
				
			end
		end	
	end
end

function suite_load_game(game_path)
	cards_api_clear()
	
	cards_api_coroutine_add(cocreate(function()
	-- example "card_games/solitaire_basic.lua"
	suite_game_name = suite_get_game_name(game_path)
	
	yield()
	local file_n = 1 
	local start = stat(1)
	while true do
		local extra_sprites = fetch(game_path:dirname() .. "/" .. tostr(file_n) .. ".gfx")
		
		if extra_sprites then
			local j = file_n * 256
			for i = 0,#extra_sprites do
				set_spr(j+i, extra_sprites[i].bmp, extra_sprites[i].flags or 0)
			end
			file_n += 1
			
		else
			break
		end
	end
	yield()	

-- attempt at encapsulating the game environment

	if game_path ~= "suite_scripts/main_menu.lua" then
		game_env = {}
		for k,v in pairs(_ENV) do
			if type(v) == "function" then
				game_env[k] = v
			end
		end
		
		for c in all(copied_env) do
			game_env[c] = nil
		end
		for b in all(banned_env) do
			game_env[b] = nil
		end
		
		game_env.include = cap_include(game_path:dirname(), game_env)
		game_env.fetch = cap_fetch(game_path:dirname())
		
		--local func,err = load(src, "@"..filename, "t", _ENV)
		local func, err = load(fetch(game_path), "@".. fullpath(game_path), "t", game_env)
		--local ok = pcall(func)
		assert(func, err)
		func()
		
	--	if(not ok) stop()
		for c in all(copied_env) do
			_ENV[c] = game_env[c]
		end
		
		game_setup()
		
	else	
		include(game_path)
		game_setup()
	end
	
	suite_draw_wrapper()
	if not first_load then
		suite_prepare_transition()
	end
	first_load = false
	end))
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
	
	suite_menuitem_remove_pages()
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

local card_back_sprites = {}

-- gets the currently selected card back of a given size
-- uses a simple border style
-- ensures that card backs that are already generated will be returned
function suite_card_back(width, height)
	width = width or 45
	height = height or 60
	
	local key = tostr(width) .. "," .. tostr(height)
	
	local cb = card_back_sprites[key]

	if not cb then
		camera()
	
		if card_back_sprite.gen then
			-- initializes card back and adds it to the list
			cb = card_back_sprite.gen(width, height)	
			
		else
			cb = card_gen_back{
				sprite = card_back.sprite, 
				width = width,
				height = height
			}
		end
		
		card_back_sprites[key] = cb
	end
	
	return cb
end

function suite_card_back_set(sprite)
	card_back_sprite = sprite
	for c in all(card_back_sprites) do
		if c.destroy then
			c:destroy()
		end
	end
	card_back_sprites = {}
end

function suite_prepare_transition()
	local d = get_display()
	if d then
		suite_transition_screen = get_display():copy()
		suite_transition_t = 0.9
	end
end


-- copied from include
function cap_include(base, new_env)
	return function(filename)
		local filename = fullpath(correct_path(base, filename))
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

function cap_fetch(base)
	return function(str)
		return fetch(fullpath(correct_path(base, str)))
	end
end

function correct_path(base, path)
	local cut = sub(path, 1, 6) == "/game/" and 6 
		or sub(path, 1, 5) == "game/" and 5 
		or 0
		
	if cut ~= 0 then
		path = base .. sub(path, cut)
	end

	return path
end

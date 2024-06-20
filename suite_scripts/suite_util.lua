--[[pod_format="raw",created="2024-03-29 03:13:35",modified="2024-06-20 15:50:58",revision=4978]]
include"cards_api/cards_base.lua"
include"suite_scripts/suite_buttons.lua"

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

suite_transition_t = 0

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
		
		if layer == 2 then
			suite_menuitem_draw_pages()
		
		elseif layer == 3 then
			if suite_transition_t > 0 then
			
				--[[
				if suite_transition_t > 0.5 then
					spr(suite_transition_screen)
				end
				suite_transition_t -= 0.01
				local r = sin(suite_transition_t/2) * 8
				for d in all(suite_transition_dots) do
					rectfill(d[1]-r, d[2]-r, d[1]+r, d[2]+r, d[3])
				end
				]]
				
				--[[ attempt 1
				suite_transition_t -= 0.012
				local t = suite_transition_t
				t *= t * (3 - 2 * t)
				t *= t * (3 - 2 * t)
				local w, h = suite_transition_screen:width(), suite_transition_screen:height()
				w *= t
				w = (w - 30) / 480 * (480 + 60)
				
				--[=[
				set_draw_target(suite_transition_screen)
				for i = 1,1000 do
					local x, y = rnd(w), rnd(h)
					circfill(x, y, 2, pget(x, y))
				end
				set_draw_target()	
				--]=]
				
				--[=[
				set_draw_target(suite_transition_screen)
				for i = 1,100 do
					local x, y = w - rnd(40)-1, rnd(h)
					--circfill(x, y, 4, pget(x, y))
					rectfill(x-4, y-4, x+4, y+4, pget(x,y))
				end
				set_draw_target()	
				--]=]
				
			
		
				
				sspr(suite_transition_screen, 0, 0, 
					w, h, 
					0, 0)
					
				rectfill(w-2, 0, w+2, h, 32)
				rectfill(w-5, 0, w+5, h, 32)
				rectfill(w-9, 0, w+9, h, 32)
				rectfill(w-15, 0, w+15, h, 32)
				rectfill(w-23, 0, w+23, h, 32)
				--]]
				
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
	-- example "card_games/solitaire_basic.lua"
	suite_game_name = suite_get_game_name(game_path)

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
	suite_draw_wrapper()
	suite_prepare_transition()
	
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
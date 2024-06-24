--[[pod_format="raw",created="2024-03-29 03:13:35",modified="2024-06-24 16:21:08",revision=5984]]
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
suite_settings_to = -0.1
suite_settings_t = smooth_val(0, 0.87, 0.02, 0.00003)
suite_settings_buttons = {}
suite_settings_width, suite_settings_height = 300, 200

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
		
		local sett_x, sett_y = (480 - suite_settings_width) / 2, (270 - suite_settings_height) / 2

		if layer == 2 then
			suite_menuitem_draw_pages()
			
			local y = (1 - suite_settings_t(suite_settings_to)) * 270 + sett_y
			y \= 1
			for b in all(suite_settings_buttons) do
				b.x = b.base_x + sett_x
				b.y = b.base_y + y
			end
			
			
		elseif layer == 3 then -- reserved for menus like settings
			local y = suite_settings_t"pos"
			if y > 0 then
				y = (1-y)*270 + sett_y
				y \= 1
				
				--rectfill(0,0,480*x,270,32)
				--[[
				local sx = x * 300
				rectfill(240-sx, 135-sx, 241+sx, 136+sx, 32)
				
				local sx = x * 150 \ 1
				local sy = (x - suite_settings_t"vel" * 6) * 100 \ 1
				
				if sx > 0 and sy > 0 then
					rectfill(240-sx, 136+sy, 241+sx, 136+sy + 15, 32)
					
					rectfill(240-sx, 135-sy, 241+sx, 136+sy, 7)
				end
				]]
				
				local cx, cy = camera(-sett_x, -y)
				rectfill(0,suite_settings_height,
					suite_settings_width-1,suite_settings_height+10, 32)
				rectfill(0,0,
					suite_settings_width-1,suite_settings_height-1, 7)
				camera(cx, cy)
			end
			
		
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



-- settings functions

local suite_setting_layout_y = 10

function suite_open_settings()
	-- clear old buttons
	for b in all(suite_settings_buttons) do
		b:destroy()
	end
	suite_settings_buttons = {}
	suite_setting_layout_y = 10
	suite_settings_to = 1
	
	-- interaction blocker
	suite_settings_blocker = button_new({
		x = -1000, y = -1000, 
		w = 3000, h = 3000, 
		draw = function() end, 
		group = 3
	})
	
	-- TODO fill with more things
	-- allow for the base to be used by other menus
	
	if(game_settings_opened) game_settings_opened()
	
	suite_settings_add_button("Exit Settings", suite_close_settings, true)

	-- change height of settings menu to fit the buttons
	suite_settings_height = suite_setting_layout_y + 10
end

function suite_close_settings()
	suite_settings_to = -0.1
	suite_settings_blocker:destroy()
	suite_settings_blocker = nil
	
	if(game_settings_closed) game_settings_closed()
end

function suite_settings_button_add(button)
	add(suite_settings_buttons, button)
	button.on_click = suite_settings_button_check(button.on_click)
	button.base_x = button.base_x or button.x
	button.base_y = button.base_y or button.y
end

-- prevents button from being pressed unless the menu is open
function suite_settings_button_check(func)
	return function(button)
		if suite_settings_to >= 1 then
			func(button)
		end
	end
end


-- available button types to add to the settings menu

function suite_settings_add_button(name, func, right_side)
	local b = suite_button_simple(name, 10, suite_setting_layout_y, func, nil, 3)
	if right_side then
		b.x = suite_settings_width - b.w - 10
	end
			
	suite_settings_button_add(b)
	
	suite_setting_layout_y += 20
end

function suite_settings_add_options(name, func, ops, current)
	
	-- TODO

	suite_setting_layout_y += 20
end

function suite_settings_add_range(name, func, min, max, current)
	
	

	suite_setting_layout_y += 20
end

-- TODO other potential ui elements for the settings menu

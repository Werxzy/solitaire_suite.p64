--[[pod_format="raw",created="2024-07-01 20:21:05",modified="2024-07-03 04:41:34",revision=1824]]

local game_list_buttons = {}
local game_list_y_start = 0
local game_list_width = 150
local game_sel_buttons = {}
local game_sel_desc = ""
local game_sel_current = nil

local game_list_all = {}

local update_game_list = nil

local function save_game_list()
	store("/appdata/solitaire_suite/mod_list.pod", game_list_all)
end

local function cull_version(id)
	return split(id, "-")[1]
end

local function find_game_by_id(id)
	id = cull_version(id)
	
	for g in all(game_list_all) do
		if cull_version(g.id) == id then
			return g
		end
	end
end

local function rmcp(from, to)
	-- makes sure to remove full folder and contents
	-- not sure if this is already done
	rm(to)
	cp(from, to)
end

-- many lines of this function are from system/lib/load.lua
local function attempt_add_game(id)
	local c1 = id:sub(1,1)
	if c1 == "#" then
		id = id:sub(2)
	end
	
	local orig_id = id

	if c1 == "/" then
		id = id:sub(2)
	end
		
	local filename = id
	local true_name = split(id:basename(), ".")[1]
	
	-- download the cart if from the bbs
	if c1 ~= "/" then	
		-- ***** this is not a public api! [yet?] *****
		local cart_png, err = fetch("https://www.lexaloffle.com/bbs/get_cart.php?cat=8&lid="..id) 
		if err then
			notify(tostr(err))
			return
		end
	
		if (type(cart_png) == "string" and #cart_png > 0) then
			mkdir"/ram/mod_cart/"
			
			filename = "/ram/mod_cart/".. true_name ..".p64.png"
			rm(filename) -- unmount. deleteme -- should be unnecessary
			store(filename, cart_png)
	
		else
			notify"download failed"
			return
		end	
	end	


	local attrib = fstat(filename)
	if (attrib ~= "folder") then
		-- doesn't exist or a file --> try with .p64 extension
		filename = filename..".p64"
		if (fstat(filename) ~= "folder") then
			notify"could not load"
			return
		end
	end
	
	-- TODO check game is valid
	-- be careful of loading own games from #solitaire_suite
	
	

	-- TODO only add folder if the game has those things
	-- reverse /card_games/true_name/ to /true_name/card_games/ ?
	--mkdir(suite_save_folder .. "/card_games/" .. true_name)
	--mkdir(suite_save_folder .. "/card_backs/" .. true_name)
	
	rmcp(filename .. "/card_games", suite_save_folder .. "/card_games/" .. true_name)
	rmcp(filename .. "/card_backs", suite_save_folder .. "/card_backs/" .. true_name)
	
	-- remove base cardback
	rm(suite_save_folder .. "/card_backs/" .. true_name .. "/card_backs_main.lua")
	
	
	local md = fetch_metadata(filename)

	-- remove old definition
	del(game_list_all, find_game_by_id(id))

	-- can't do individual games since there are card backs that can be added
	add(game_list_all, {
		id = orig_id, -- id cart is loaded
		name = md.title or true_name, -- name of game?
		author = md.author or "???", -- author(s) of game
		version = md.version or "???",
		notes = md.notes or "",
		from = c1 ~= "/" and "#" .. orig_id or "local file",
		icon = md.icon,
	})
	
	-- clean up bbs cart
	if c1 ~= "/" then
		rm(filename)
	end
	
	save_game_list()
	update_game_list()
	
	notify("'" .. true_name .. "' added successfully")
	return true -- successful
end

local function remove_game(id)
	local c1 = id:sub(1,1)
	if c1 == "#" then
		id = id:sub(2)
	end
	
	local orig_id = id

	if c1 == "/" then
		id = id:sub(2)
	end
		
	local filename = id
	local true_name = split(id:basename(), ".")[1]
		
	rm(suite_save_folder .. "/card_games/" .. true_name)
	rm(suite_save_folder .. "/card_backs/" .. true_name)	
end


function suite_open_mod_manager()
	game_list_all = fetch("/appdata/solitaire_suite/mod_list.pod") or {}
	save_game_list()

	suite_window_init("Mod Manager")
	
	game_sel_desc = ""
	game_list_buttons = {}
	game_sel_buttons = {}
	game_sel_current = nil
	
	add_games_list()

	add_text_field()

	suite_window_footer("Exit Mod Manager")
end

	
local function destroy_button_list(list)
	for b in all(list) do
		b:destroy()
		del(list, b)
		del(suite_window_buttons)
	end
end

local function game_list_button_draw(b)
	b.t = max(b.t - 0.1)
	local x2, y2 = b.x + b.width-1, b.y + b.height-1
	local yt = b.t > 0 and 1 or 0
	
	rectfill(b.x, y2, x2, y2, 20)
	rectfill(b.x, b.y+yt, x2, y2+yt-1, (b.highlight or b.text == game_sel_current) and 31 or 4)
		
	print(b.text, b.x+5+17, b.y+6+yt, 20)
	print(b.text, b.x+5+17, b.y+5+yt, 7)
	
	spr(b.info.icon, b.x+1, b.y+1+yt)
end

local function game_list_button_on_click(b)
	b.t = 1
	local _, _, name = print_wrap_prep(b.info.name, 131)
	local _, _, author = print_wrap_prep("By:" .. b.info.author, 131)
	local _, _, notes = print_wrap_prep(b.info.notes, 131)
	
	local l = "\|c\fw"
	for i = 1,30 do
		l ..= "-\-f"
	end
	l ..= "\fl\|d"

	game_sel_desc = name .. "\n" .. author .. "\n"..l.."\n" .. notes
	game_sel_desc ..= "\n" .. l .. "\n" .. b.info.from
	if #b.info.version > 0 then
		game_sel_desc ..=  "\nVersion:" .. b.info.version
	end
	

	game_sel_current = b.text
	game_sel_info = b.info
	
	destroy_button_list(game_sel_buttons)
	
	set_suite_window_layout_y(game_list_y_start + 141)
	
	local buttons = suite_window_add_buttons({
			{"Update", function(b)
				if attempt_add_game(game_sel_info.id) then
					save_game_list()
					update_game_list()
					notify("successfully updated " .. game_sel_current)
				end
			end},
			{"Remove", function(b)
				remove_game(game_sel_info.id)
				del(game_list_all, game_sel_info)
				save_game_list()
				update_game_list()
				
				notify("removed " .. game_sel_current)
				
				game_sel_desc = nil
				game_sel_info = nil
				game_sel_current = nil
			end}
		}, true)
		
	for b in all(buttons) do
		add(game_sel_buttons, b)
	end
end

function update_game_list()
	destroy_button_list(game_list_buttons)
	
	local y = game_list_y_start+1
	local h = 19	

	for i = 1,#game_list_all do
		local g = game_list_all[i]
		
		local b = button_new({
			x = 10,
			y = y,
			width = game_list_width, height = h,
			draw = game_list_button_draw,
			on_click = game_list_button_on_click,
			group = 3,
			always_active = true
		})
		
		b.text = g.name
		b.info = g
		b.t = 0
		y += h
		
		suite_window_button_add(b)
		add(game_list_buttons, b)
	end
end
	
function add_games_list()
	local y = get_suite_window_layout_y()

	game_list_width = 150
	game_list_y_start = y
	
	update_game_list()
	
	add(suite_window_elements, function()
		
	--	rect(10, 10, 9+game_list_width, 140, 6)
		-- inside
		rectfill(9, 9, 10+game_list_width, 141, 21)
		rect(9, 9, 10+game_list_width, 9, 20)	
	
		-- border
		rect(8, 8, 11+game_list_width, 142, 4)
		rect(7, 7, 12+game_list_width, 143, 4)
		rect(6, 6, 13+game_list_width, 144, 4)
		
		-- outline
		rect(5, 6, 5, 145, 20)
		rect(14+game_list_width, 6, 14+game_list_width, 145, 20)
		rect(6, 5, 13+game_list_width, 5, 20)
		
		-- bottom
		rect(6, 145, 13+game_list_width, 145, 20)
		rect(6, 146, 13+game_list_width, 146, 21)
		
		print(game_sel_desc, game_list_width + 20, game_list_y_start + 5)
	
	end)
	
	y += 140
	set_suite_window_layout_y(y)
end

function add_text_field()

	local y = get_suite_window_layout_y()
	
	local g = create_gui()
	local w, h = 117, 13
	local nav_text = g:attach_text_editor{
		x=10,y=4+y,
		width=w,
		height=h,
		max_lines = 1,	
		key_callback = { 
			enter = function()end,
			tab = function()end
		},
		bgcol = 21,
		fgcol = 6,
	}
			
	add(suite_window_elements, function()	

		rectfill(9, 3+y, 10+w, 3+y, 20)
		rect(9, 2+y, 10+w, 4+y+h, 4)
		rect(8, 1+y, 11+w, 5+y+h, 20)
		rectfill(8, 6+y+h, 11+w, 6+y+h, 21)

		-- due to the text field not being affected by camera()
		local cx, cy = camera()
		g.x, g.y = -cx, -cy
		camera(cx, cy)	

		g:update_all()
		g:draw_all()
		
		if #nav_text.get_text()[1] == 0 then
			print("Input cart ID...", 14, y+7, 4)
		end
	end)

	local b = suite_window_add_buttons({{"Add", function()
			if (attempt_add_game(tostr(nav_text.get_text()[1]))) then
				nav_text.get_text()[1] = ""
			end
		end}}, true)
	
	b[1].base_x -= 131
	b[1].base_y += 1

	set_suite_window_layout_y(y+21)
end

--[[pod_format="raw",created="2024-07-01 20:21:05",modified="2024-07-17 08:02:54",revision=3243]]

local game_list_buttons = {}
local game_list_scroll_buttons = {}
local game_list_y_start = 0
local game_list_width = 150
local game_list_scroll = 0
local game_sel_buttons = {}
local game_sel_desc = ""
local game_sel_desc_shadow = ""
local game_sel_current = nil

local game_list_all = {}

local update_game_list = nil
local scroll_game_list = nil

local function save_game_list()
	store("/appdata/solitaire_suite/mod_list.pod", game_list_all)
end

local function cull_version(id)
	return split(id, "-")[1]
end

local function find_game_by_id(id)
	id = cull_version(id)
	
	for g in all(game_list_all) do
		if g.id and cull_version(g.id) == id then
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
		-- TODO !!!!!!!!!!!! when zep adds "bbs://", use that instead
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

local function destroy_button_list(list)
	for b in all(list) do
		b:destroy()
		del(list, b)
		del(suite_window_buttons)
	end
end

function suite_open_mod_manager()
	game_list_all = fetch("/appdata/solitaire_suite/mod_list.pod") or {}
	save_game_list()
	
	suite_window_init("Mod Manager")
	
	game_sel_desc = ""
	game_sel_desc_shadow = ""
	
	destroy_button_list(game_list_buttons)
	destroy_button_list(game_list_scroll_buttons)
	
	game_list_buttons = {}
	game_list_scroll_buttons = {}
	game_sel_buttons = {}
	game_sel_current = nil
	
	add_games_list()

	add_text_field()

	suite_window_footer("Exit Mod Manager")
end


local function game_list_button_draw(b)
	b.t = max(b.t - 0.1)
	local x2, y2 = b.x + b.width-1, b.y + b.height-1
	local yt = b.t > 0 and 1 or 0
	
	rectfill(b.x, y2, x2, y2, 20)
	rectfill(b.x, b.y+yt, x2, y2+yt-1, (b.highlight or b.text == game_sel_current) and 31 or 4)
		
	local xd = b.info and 17 or 0	

	print(b.text, b.x+5+xd, b.y+6+yt, 20)
	print(b.text, b.x+5+xd, b.y+5+yt, 7)
	
	if b.info then
		spr(b.info.icon, b.x+1, b.y+1+yt)
	end
end

local function game_list_button_on_click(b)
	b.t = 1
	local name = print_wrap_prep(b.info.name, 131)
	local author = print_wrap_prep("By:" .. b.info.author, 131)
	local notes = print_wrap_prep(b.info.notes, 131)
	
	local l = "\|c\fw"
	for i = 1,30 do
		l ..= "-\-f"
	end
	l ..= "\fl\|d"

	game_sel_desc = "\f2".. name .. "\fl\n" .. author .. "\n"..l.."\n" .. notes .. "\n" .. l
	if b.info.from == "local file" then
		game_sel_desc ..=  "\n" .. print_cutoff(b.info.from, 131)
	end
	if #b.info.version > 0 then
		game_sel_desc ..=  "\nVersion:" .. print_cutoff(b.info.version, 131)
	end


	
	game_sel_current = b.text
	game_sel_info = b.info
	
	destroy_button_list(game_sel_buttons)
	
	if b.info.from ~= "local file" then
		local _, h = print_size(game_sel_desc)
		local from = b.info.from
		
		local b2 = button_new({
			x = game_list_width + 20,
			y = h + game_list_y_start + 5,
			width = 120, height = 15,
			draw = game_list_button_draw,
			on_click = function(b)
				b.t = 1 
				set_clipboard(from) 
				notify("copied to clipboard: " .. from) 
			end,
			group = 3,
			always_active = true,
			
			text = "\-9\|e".. print_cutoff(from, 105),
			info = {icon = 26},
			t = 0,
		})
		
		suite_window_button_add(b2)
		add(game_sel_buttons, b2)
	end
	
	-- add a shadow layer to the text by extracting the color settings
	local sp = split(game_sel_desc, "\f")
	game_sel_desc_shadow = sp[1]
	for i = 2, #sp do
		local s = sp[i]
		local c1 = sub(s,1,1)
		if c1 == "w" then
			s = "0" .. sub(s, 2)
		else
			s = "w" .. sub(s, 2)
		end
		game_sel_desc_shadow ..= "\f" .. s
	end
	
	

	
	set_suite_window_layout_y(game_list_y_start + 141)
	
	local buttons = suite_window_add_buttons({
			{"Update", function(b)
				if attempt_add_game(game_sel_info.id) then
					local name = game_sel_info.name
					save_game_list()
					update_game_list()
					update_all_assets()
					notify("Successfully updated " .. name)
				end
			end},
			{"Remove", function(b)
				local name = game_sel_info.name
				remove_game(game_sel_info.id)
				
				del(game_list_all, find_game_by_id(game_sel_info.id))
				save_game_list()
				update_game_list()
				
				game_sel_desc = ""
				game_sel_desc_shadow = ""
				game_sel_info = nil
				destroy_button_list(game_sel_buttons)
				
				update_all_assets()
				
				notify("Removed " .. name)
				game_sel_current = nil
			end}
		}, true)
		
	for b in all(buttons) do
		add(game_sel_buttons, b)
	end
end

--local
local scroll_amount = 3
function scroll_game_list(n)
	game_list_scroll = min(max(game_list_scroll\scroll_amount + n), max((#game_list_all - 1)\scroll_amount)) * scroll_amount	
end

-- local
function update_game_list()
	destroy_button_list(game_list_buttons)
	scroll_game_list(0) -- clamp scrolling if an element is removed
	
	quicksort(game_list_all, "name")
	
	local y = game_list_y_start+1
	local h = 19	
	
	if #game_list_all > 0 then
		for i = game_list_scroll + 1, min(game_list_scroll + 6, #game_list_all) do
			local g = game_list_all[i]
			
			local b = button_new({
				x = 10,
				y = y,
				width = game_list_width, height = h,
				draw = game_list_button_draw,
				on_click = game_list_button_on_click,
				group = 3,
				always_active = true,
				
				text = print_cutoff(g.name, game_list_width - 22),
				info = g,
				t = 0,
			})
			
			y += h
			
			suite_window_button_add(b)
			add(game_list_buttons, b)
		end
	end
	
	update_game_list_scroll_buttons(y, h)
end

function update_game_list_scroll_buttons(y, h)
	if #game_list_scroll_buttons == 0 then
		local x = 10
		local y = game_list_y_start + 1 + h * 6

		for b2 in all({
			{"<-", 20, function(b) b.t = 1 scroll_game_list(-1) 	update_game_list() end},
			{"->", 20, function(b) b.t = 1 scroll_game_list(1) update_game_list() end},
			{(game_list_scroll + 1) .. " / " .. #game_list_all, game_list_width - 42},
		}) do
			local b = button_new({
				x = x,
				y = y,
				width = b2[2], height = 18,
				draw = game_list_button_draw,
				on_click = b2[3],
				group = 3,
				always_active = true,
				
				text = b2[1],
				t = 0,
			})
			
			x += b.width+1
		
			suite_window_button_add(b)
			add(game_list_scroll_buttons, b)
		end
		
	else
		local b = game_list_scroll_buttons[3]
		b.text = (game_list_scroll + 1) .. " / " .. #game_list_all
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
		
		print(game_sel_desc_shadow, game_list_width + 21, game_list_y_start + 6)
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
				update_all_assets()
			end
		end}}, true)
	
	b[1].base_x -= 131
	b[1].base_y += 1

	set_suite_window_layout_y(y+21)
end

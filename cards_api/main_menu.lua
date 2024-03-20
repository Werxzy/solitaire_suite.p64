--[[pod_format="raw",created="2024-03-19 15:14:10",modified="2024-03-20 03:19:13",revision=2212]]

game_version = "0.1.0"

-- this isn't actually a game, but still uses the cards api, but instead a menu for all the game modes and options

function main_menu_load() -- similar to game_load, but we always want this available
	
cards_api_clear()
cards_api_shadows_enable(true)
main_menu_selected = nil

local x_offset = smooth_val(0, 0.5, 0.1)

function button_deckbox_draw(b)
	
	-- draw shadows, based on the the boxes size
	-- 32 is the shadow applying color
	local x1, y1, x2, y2 = b.x-3, b.y+10, b.x+b.w+2, b.y+b.h+2
	fillp(0xa5a5a5a5)
	rect(x1,y1,x2,y2, 32)
	rect(x1+1,y1+1,x2-1,y2-1, 32)
	rectfill(x1+4,y1+4,x2-4,y2-4, 32)
	fillp()
	rectfill(x1+2,y1+2,x2-2,y2-2, 32)
	
	-- interpolates the draw position
	b.y2 = lerp(b.y2 or 0, (b.highlight and 3 or 0) + (b == main_menu_selected and 8 or 0), 0.15)
	-- didn't want to do lerp, but it's simpler here >:(
	spr(b.sprite, b.x, b.y - (b.y2 + 0.5)\1)
end

function button_deckbox_click(b)
	main_menu_selected = b
end

-- creates buttons for each game mode
game_mode_buttons = {}
local bx = 2

for game in all(game_list) do

	-- game exists
	if include(game) then 
	
		-- get info provided by game
		info = game_info()
		
		if type(info.sprite) == "number" then
			info.sprite = get_spr(info.sprite)
		end
		
		local b = add(game_mode_buttons, 
			button_new(bx, 100, 
				info.sprite:width(), info.sprite:height(), 
				button_deckbox_draw, 
				button_deckbox_click)
			)
			
		b.sprite = info.sprite
		b.game = game
		b.info = info
		b.x_old = bx
		
		bx += info.sprite:width() + 10
	end
end

local first = game_mode_buttons[1]
x_offset("pos", 240 - first.sprite:width()/2 - first.x_old)

set_draw_target(userdata("u8", 1, 1)) -- TEMP : draw target isn't initialized? print doesn't return any values
button_play = button_simple_text("Start Game", 200, 200, 
	function() 
		if main_menu_selected then
			cards_api_load_game(main_menu_selected.game)
		end
	end)

button_play.x = 240 - button_play.w / 2
set_draw_target()

function game_update()
	local x = main_menu_selected 
		and x_offset(240 - main_menu_selected.sprite:width()/2 - main_menu_selected.x_old)
		or x_offset(x_offset())
		
	for b in all(game_mode_buttons) do
		b.x = x + b.x_old
	end
end

function game_draw(layer)
	if layer == 0 then
		cls(3)
		print("Version " .. game_version, 1, 262, 19)
		print("Mostly by Werxzy", 399, 261)
	end
end

function cards_game_exiting()
	main_menu_load()
end

end -- end of load

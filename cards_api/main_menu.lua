--[[pod_format="raw",created="2024-03-19 15:14:10",modified="2024-03-19 17:41:43",revision=253]]


-- this isn't actually a game, but instead a menu for all the game modes and options

function main_menu_load() -- similar to game_load, but we always want this available
	
cards_api_clear()
cards_api_shadows_enable(true)

function button_deckbox_draw(b)
	rectfill(b.x-1, b.y+10, b.x+b.w, b.y+b.h, 32)
	spr(b.sprite, b.x, b.y - (b.highlight and 10 or 0))
end

function button_deckbox_click(b)
	include(b.game)
	game_load()
	game_setup()
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
		
		bx += info.sprite:width() + 2
	end
end

end -- end of load

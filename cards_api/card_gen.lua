--[[pod_format="raw",created="2024-03-23 23:52:47",modified="2024-03-24 00:40:05",revision=185]]


function card_gen_standard(suits, ranks, 
	suit_chars, rank_chars, suit_colors, face_sprites,
	icon_pos)
	
	local card_sprites = {}

	for suit = 1,suits do
		local card_set = add(card_sprites, {})
		local col = suit_colors[suit]
		local suit_char = suit_chars[suit]
		
		for rank = 1,ranks do
			local rank_char = rank_chars[rank]
			
			-- prepare render
			local new_sprite = userdata("u8", card_width, card_height)
			set_draw_target(new_sprite)
			
			-- draw card base
			nine_slice(8, 0, 0, card_width, card_height)
			
			-- draw rank/suit
			print(rank_char .. suit_char, 3, 3, col[1])
			
			local sp = face_sprites[rank]
			local pos = icon_pos[rank]
			
			if sp then -- draw sprite if it calls for it
				pal(24, col[2], 0)
				pal(8, col[3], 0)
				pal(14, col[4], 0)
				spr(type(sp) == "table" and sp[suit] or sp)
				pal(24,24,0)
				pal(8,8,0)
				pal(14,14,0)
			
			elseif pos then -- draws the icons at given positions
				for p in all(pos) do
					print(suit_char, p[1]+1, p[2]+2, 32)
				end
				color(col[1])
				for p in all(pos) do
					print(suit_char, p[1], p[2])
				end	
			end
			
			add(card_set, new_sprite)
		end
	end
	
	set_draw_target()
	
	return card_sprites
end
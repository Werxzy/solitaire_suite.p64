--[[pod_format="raw",created="2024-03-23 23:52:47",modified="2024-03-25 01:46:37",revision=632]]

local default_suits = {
	--"Spades",
	--"Hearts",
	--"Clubs",
	--"Diamonds",
	--"Stars"
	"\|g\^:081c3e7f7f36081c",
	"\|g\^:00367f7f3e1c0800",
	"\|f\^:001c1c7f7f77081c",
	"\|g\^:081c3e7f3e1c0800",
	"\|g\^:081c7f7f3e362200"
}

local default_ranks = {
	"A",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"J",
	"Q",
	"K",
	
-- just extra to reach rank 16, no reason for these
	"X",
	"Y",
	"Z",
}

-- text, dark, medium, light
local default_suit_colors = {
	{16, 1,16,12},
	{8, 24,8,14},
	{27, 19,3,27},
	{25, 4,25,9},
--	{13, 12,26,10}
	{13, 18,13,29}
}

-- x left, middle, right = {9, 19, 29}
local default_icon_pos = {
	{{19, 28}},
	{{19, 17}, {19, 39}},
	{{19, 17}, {19, 28}, {19, 39}},
	{{9, 17}, {9, 39}, {29, 17}, {29, 39}},
	{{9, 17}, {9, 39}, {29, 17}, {29, 39}, {19, 28}},
	{{9, 17}, {9, 39}, {9, 28}, {29, 17}, {29, 39}, {29, 28}},
	{{19, 17},{19, 39},{19, 28}, {9, 23},{9, 34}, {29, 23},{29, 34}},
	{{9, 17},{9, 39},{9, 28}, {19, 23},{19, 34}, {29, 17},{29, 39},{29, 28}},
	{{19, 17},{19, 39},{19, 28}, {9, 23},{9, 34},{9, 45}, {29, 12},{29, 23},{29, 34}},
	{{9, 18},{9, 29},{9, 40}, {19, 13},{19, 24},{19, 35},{19, 46}, {29, 18},{29, 29},{29, 40}},	
}

local default_face_sprites = {
	[1] = {67,68,69,70,71},
	[11] = 66,
	[12] = 65,
	[13] = 64
}

function card_gen_standard(suits, ranks, 
	suit_chars, rank_chars, suit_colors, face_sprites,
	icon_pos)
	
	-- default values
	suits = suits or 4
	ranks = ranks or 13
	suit_chars = suit_chars or default_suits
	rank_chars = rank_chars or default_ranks
	suit_colors = suit_colors or default_suit_colors
	face_sprites = face_sprites or default_face_sprites
	icon_pos = icon_pos or default_icon_pos
	
	local card_sprites = {}
	
	-- for each suit and rank
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
			
			-- draw sprite if it calls for it
			if sp then 
				pal(24, col[2], 0)
				pal(8, col[3], 0)
				pal(14, col[4], 0)
				spr(type(sp) == "table" and sp[suit] or sp)
				pal(24,24,0)
				pal(8,8,0)
				pal(14,14,0)
			
			 -- draws the icons at given positions
			elseif pos then
				 -- shadows
				for p in all(pos) do
					print(suit_char, p[1]+1, p[2]+2, 32)
				end
				-- base
				color(col[1])
				for p in all(pos) do
					print(suit_char, p[1], p[2])
				end	
			end
			
			add(card_set, new_sprite)
		end
	end
	
	-- important to reset the draw target for future draw operations.
	set_draw_target()
	
	return card_sprites
end


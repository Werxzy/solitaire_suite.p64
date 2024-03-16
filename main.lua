--[[pod_format="raw",created="2024-03-14 21:14:09",modified="2024-03-16 19:09:23",revision=2859]]

include"cards_api/cards_base.lua"

all_suits = {
	--"Spades",
	--"Hearts",
	--"Clubs",
	--"Diamonds"
	"\|f\^:081c3e7f7f36081c",
	"\|g\^:00367f7f3e1c0800",
	"\|f\^:001c1c7f7f77081c",
	"\|g\^:081c3e7f3e1c0800"
}

all_suit_colors = {
	16,
	8,
	27,
	25
	
}

all_ranks = {
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
	"K"
}

function _init()
	local card_gap = 4
	for suit = 1,4 do
		for rank = 1,13 do
			local new_sprite = userdata("u8", card_width, card_height)
			
			set_draw_target(new_sprite)
			spr(2)
			print(all_ranks[rank] .. all_suits[suit], 3, 3, all_suit_colors[suit])
			
			local c = card_new(new_sprite, 240,100)
			c.suit = suit
			c.rank = rank
		end
	end
	
	set_draw_target()

	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	stacks = {}

	for i = 1,7 do
		local s = stack_new(
			i*(card_width + card_gap*2) + card_gap, 
			card_gap, 
			true, stack_on_click_unstack, stack_can_rule)
			
		for i = 1,5 do
			stack_add_card(s, rnd(unstacked_cards), unstacked_cards)
			stack_reposition(s)
		end
	end
	
	for i = 0,3 do
		local s = stack_new(
			8*(card_width + card_gap*2) + card_gap,
			i*(card_height + card_gap*2-1) + card_gap,
			true, stack_on_click_unstack, stack_can_goal)
			
		s.y_delta = 0
	end
	
	
	deck_stack = stack_new(
		card_gap, card_gap,
		true, stack_on_click_reveal, stack_cant)
	deck_stack.y_delta = 0
	
	deck_playable = stack_new(
		card_gap, card_height + card_gap*3,
		true, stack_on_click_unstack, stack_cant)
	deck_playable.y_delta = 0
	
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
end

function _update()
	
	cards_api_update()
		
end

function _draw()
	cls(3)
	
	cards_api_draw()
	
	--?stat(1), 0, 0, 6
end



-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	if s == held_stack then
		return false
	end
	if #stack.cards == 0 then
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	if c1.rank - 1 == c2.rank 
	and c1.suit ~= c2.suit then
		return true
	end

	--if c1.rank - 1 == c2.rank then
	--	return true
	--end
end

-- expects to be stacked from ace to king with the same suit
function stack_can_goal(stack, stack2)
	if s == held_stack then
		return false
	end
	--
	if #stack2.cards ~= 1 then
		return false
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1] 
	
	if #stack.cards == 0 and c2.rank == 1 then
		return true
	end
	
	if #stack.cards > 0 and c1.rank + 1 == c2.rank and c1.suit == c2.suit then
		return true
	end
end

function stack_on_click_reveal()
	local s = deck_stack.cards
	
	if #s > 0 then
		local c = s[#s]
		stack_add_card(deck_playable, c)
		c.a_to = 0
				
	else
		local s = deck_playable.cards
		while #s > 0 do
			local c = s[#s]
			stack_add_card(deck_stack, c)
			c.a_to = 0.5
		end
	end
end
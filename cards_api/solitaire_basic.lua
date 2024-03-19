--[[pod_format="raw",created="2024-03-17 19:21:13",modified="2024-03-19 00:02:42",revision=2494]]

include "cards_api/rolling_score.lua"

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


function game_setup()
	
	win_count = 0

	cards_api_clear()
	poke(0x5508, 0xff) -- read
	poke(0x550a, 0xff) -- target
	
	-- shadow mask color
	for i, b in pairs{0,0,21,19,20,21,22,6,24,25,9,27,17,18,13,31,1,16,2,1,21,0,5,14,2,4,11,3,12,13,2,4} do
		-- bit 0x40 is to change the table color to prevent writing onto shaded areas
		-- kinda like some of the old shadow techniques in 3d games
		poke(0x8000 + 32*64 + i-1, 0x40|b)
	end
	-- poke(0x5509, 0xff) -- enable writing new color table
	-- draw shadow
	-- poke(0x5509, 0x3f) -- disable
	
	-- can apply write 

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
	
	
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			stack_repose_normal(),
			true, stack_can_rule, 
			stack_on_click_unstack(unstack_rule_decending), stack_on_double_goal))
			
	end
	
	stack_goals = {}
	for i = 0,3 do
		add(stack_goals, stack_new(
			{5},
			8*(card_width + card_gap*2) + card_gap,
			i*(card_height + card_gap*2-1) + card_gap,
			stack_repose_normal(0),
			true, stack_can_goal, stack_on_click_unstack(card_is_top)))
	end
	
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		stack_repose_static(-0.16),
		true, stack_cant, stack_on_click_reveal)
	
	deck_playable = stack_new(
		{5,7},
		card_gap, card_height + card_gap*3,
		stack_repose_static(2),
		true, stack_cant, stack_on_click_unstack(card_is_top), stack_on_double_goal)
	
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, function()
		-- todo
		-- cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Auto Place ->", 340, 248, function()
		cards_coroutine = cocreate(game_auto_place_anim)
	end)

	cards_coroutine = cocreate(game_setup_anim)
	
	game_score = rolling_score_new(6, 220, 3, 3, 21, 16, 16, 4, 49, function(s, x, y)
			-- shadows
			spr(52, x, y)
			spr(51, x, y) -- a bit overkill, could use sspr or rectfill
			-- case
			spr(50, x, y)
	end)
end

-- deals the cards out
function game_setup_anim()
	pause_frames(30)
	for i = 1,5 do	
		for s in all(stacks_supply) do
			local c = get_top_card(deck_stack)
			stack_add_card(s, c)
			c.a_to = 0
			pause_frames(3)
		end
		pause_frames(5)
	end
end

-- places all the cards back onto the main deck
function game_reset_anim()
	for a in all{stacks_supply, stack_goals, {deck_playable}} do
		for s in all(a) do
			while #s.cards > 0 do
				local c = get_top_card(s)
				stack_add_card(deck_stack, c)
				c.a_to = 0.5
				pause_frames(3)
			end
		end
	end
	
	pause_frames(35)
	
	game_shuffle_anim()
	game_shuffle_anim()
	game_shuffle_anim()
	
	game_setup_anim()
end

-- physically shuffle the cards
function game_shuffle_anim()
	local temp_stack = stack_new(
		nil, deck_stack.x_to + card_width + 4, deck_stack.y_to, 
		stack_repose_static(-0.16), 
		false, stack_cant, stack_cant)
		
	for i = 1, rnd(10)-5 + #deck_stack.cards/2 do
		stack_add_card(temp_stack, get_top_card(deck_stack))
	end
	
	pause_frames(30)
	
	for c in all(temp_stack.cards) do
		stack_add_card(deck_stack, c, rnd(#deck_stack.cards+1)\1+1)
	end
	for c in all(deck_stack.cards) do
		card_to_top(c)
	end
	del(stacks_all, temp_stack)
	
	pause_frames(20)
end

-- goes through each card and plays a card where it expects
-- easier than double clicking each card
function game_auto_place_anim()
	local found = true
	
	local function find_placement(stack)
		-- create temp stack with top card
		local card = get_top_card(stack)
		if not card then
			return
		end
		local temp_stack = unstack_cards(card)
	
		-- check with each goal stack if card can be placed
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				found = true
				stack_cards(g, temp_stack)
				break
			end
		end
		
		-- return card to original stack
		if not found then
			stack_cards(stack, temp_stack)
		end
	end
	
	while found do
		found = false
		for i = #stacks_supply, 1, -1 do
			find_placement(stacks_supply[i])
			if found then
				break
			end
		end
		if not found then
			find_placement(deck_playable)
		end
		pause_frames(6)
	end
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
	
	if stack == held_stack then
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

function stack_on_double_goal(card)
	-- only accept top card (though could work with multiple cards
	if card and card_is_top(card) then 
		local old_stack = card.stack
		-- create a temporary stack
		local temp_stack = unstack_cards(card)
		
		-- attempt to place on each of the goal stacks
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				stack_cards(g, temp_stack)
				temp_stack = nil
				break
			end
		end
			
		-- if temp stack still exists, then return card to original stack
		if temp_stack then
			stack_cards(old_stack, temp_stack)
		end
	end
end

function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		-- either rank matches, not decending by 1
		if next_card.suit == card.suit or next_card.rank+1 ~= card.rank then
			return false
		end
	
		card = next_card -- current card becomes previous card
	end
	
	return true
end

function game_draw(layer)
	if layer == 1 then
		spr(58, 7, 207) -- wins label
		local n = time()
		game_score:draw()
	end
end

function game_update()
	game_score:update()
end
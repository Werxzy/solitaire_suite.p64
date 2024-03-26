--[[pod_format="raw",created="2024-03-17 19:21:13",modified="2024-03-26 01:49:23",revision=3014]]

function game_load() -- !!! start of game load function
	-- this is to prevent overwriting of game modes

include "cards_api/rolling_score.lua"
include "cards_api/confetti.lua"
include "cards_api/card_gen.lua"

-- updates card size if it changed
card_width = 45
card_height = 60

available_suits = 4
available_decks = 1

available_rows = 6

all_ranks = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"",
	"",
	"",
}

all_face_sprites = {
	[10] = {67,68,69,70,71}
}
	
cards_api_clear()
cards_api_shadows_enable(true)

function game_setup()
	
	game_save = cards_api_load() or {
		wins = 0
	}	
	
	local card_sprites = card_gen_standard(4, 10, nil, all_ranks, nil, all_face_sprites)
	
	for suit = 1,available_suits do
		for rank = 1,#all_ranks do		
			local c = card_new(card_sprites[suit][min(rank, 10)], 240,100)
			c.suit = suit
			c.rank = rank
		end
	end
	
	local card_gap = 4
	
	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	
	stacks_supply = {}
	for i = 1,available_rows do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap + 40, card_gap + 10, 
			stack_repose_normal(),
			true, stack_can_rule, 
			stack_on_click_unstack(unstack_rule_decending), stack_on_double_goal))	
	end
	
	
	deck_stack = stack_new(
		{5},
		card_gap+10, card_gap + 10,
		stack_repose_static(-0.16),
		true, stack_can_on_deck, stack_on_click_reveal)
	
	--[[
	deck_playable = stack_new(
		{5},
		card_gap + 10, card_height + card_gap*3 + 10,
		stack_repose_static(2),
		true, stack_can_on_deck, stack_on_click_unstack(card_is_top), stack_on_double_goal)
	]]--
	

	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, cards_api_exit)

	-- rules cards 
	rule_cards = rule_cards_new(135, 192, game_info(), "right")
	rule_cards.y_smooth = smooth_val(270, 0.8, 0.09, 0.0001)
	rule_cards.on_off = false
	local old_update = rule_cards.update
	rule_cards.update = function(rc)
		rc.y = rc.y_smooth(rc.on_off and 192.5 or 280.5)
		old_update(rc)
	end
	
	button_simple_text("Rules", 97, 248, function()
		rule_cards.on_off = not rule_cards.on_off
	end).always_active = true
	cards_coroutine = cocreate(game_setup_anim)

	game_score = rolling_score_new(6, 220, 3, 3, 21, 16, 16, 4, 49, function(s, x, y)
			-- shadows
			spr(52, x, y)
			spr(51, x, y) -- a bit overkill, could use sspr or rectfill
			-- case
			spr(50, x, y)
	end)
	game_score.value = game_save.wins
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

	cards_api_game_started()
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

function stack_can_on_deck(stack, stack2)
	if #stack.cards>=1 then 
		return false
	end

	if #stack2.cards>1 then 
		return false
	end

	return true
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
	
	if c1.suit == c2.suit then
		if c1.rank - 1 == c2.rank or c1.rank>9 or c2.rank>9 then
			return true
		end
	end	
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
	
	if #stack.cards ~= 0 and c2.rank == 1 then
		return true
	end
	
	
	if #stack.cards > 0 and c1.suit == c2.suit then
		if c1.rank + 1 == c2.rank then
			return true
		end
	end		
end

function stack_on_click_reveal(card)
    if #deck_stack.cards>1 then
        cards_coroutine = cocreate(deck_draw_anim)
    elseif card then
      held_stack = unstack_cards(card)
    end
end

function deck_draw_anim()
	local s = deck_stack.cards

	for i=1,#stacks_supply do
		if #s > 0 then
			local c = s[#s]
			stack_add_card(stacks_supply[i], c)
			c.a_to = 0

			pause_frames(3)
		end
	end
end

--[[
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
]]

function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	local current_rank = card.rank

	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		-- either rank matches, not decending by 1
		if next_card.suit ~= card.suit then 
			return false
		end	
	
		if next_card.rank<=9 then
			if next_card.rank+1 ~= current_rank and current_rank<=9 then
				return false
			end
		else
			
		end
	
		card = next_card -- current card becomes previous card
		
		if next_card.rank<=9 then
			current_rank = card.rank
		end
	end
	
	return true
end

function game_draw(layer)
	if layer == 0 then
		cls(3)
	elseif layer == 1 then
		spr(58, 7, 207) -- wins label
		game_score:draw()
		rule_cards:draw()
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	game_score:update()
	rule_cards:update()
	confetti_update()
end




-- winning things
function game_win_anim()
	confetti_new(130,135, 100, 10)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
end

function game_win_condition()
	local stack_count = 0

	for stack in all(stacks_supply) do
		local i, len = 1, #stack.cards
		while i <= len do
			local card = stack.cards[i]
			i += 1 -- prepare next card

			-- for every 9 found
			if card.rank == 9 then
				local suit = card.suit
				local r = 8 -- start by searching for 8
				
				while i <= len -- haven't reached end of stack
				and stack.cards[i].rank == r -- card has expected rank
				and stack.cards[i].suit == suit -- card has same suit
				and r > 0 do -- haven't haven't checked rank 1 yet
					r -= 1 -- 1 rank lower
					i += 1 -- next card
				end
				
				-- failed to find all the ranks
				if(r > 0) return false
				
				-- increase found count
				stack_count += 1
			end
		end
	end
	
	-- if count is at (or somehow above) the expected value
	return stack_count >= available_suits * available_decks
end

function game_count_win()
	game_score.value += 1
	game_save.wins += 1
	cards_api_save(game_save)
	cards_coroutine = cocreate(game_win_anim)
end

end
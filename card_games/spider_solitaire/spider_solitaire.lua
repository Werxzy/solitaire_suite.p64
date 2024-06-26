--[[pod_format="raw",created="2024-03-17 19:21:13",modified="2024-03-31 23:07:38",revision=3814]]

function game_load() -- !!! start of game load function
	-- this is to prevent overwriting of game modes

include "suite_scripts/rolling_score.lua"
include "suite_scripts/confetti.lua"
include "cards_api/card_gen.lua"

-- updates card size if it changed
card_width = 45
card_height = 60

total_sets = 5
available_decks = 1
total_ranks = 13 -- king

available_columns = 8

	
cards_api_clear()
cards_api_shadows_enable(true)

function game_setup()
	
	game_save = suite_load_save() or {
		wins = 0
	}	
	
	-- just one suit for now
	current_card_sprites = card_gen_standard(5)
	local s = rnd(5)\1 + 1
	for sets = 1,total_sets do
		for rank = 1,total_ranks do		
			local c = card_new(current_card_sprites[s][rank], 240,100)
			c.suit = 1
			c.rank = rank
		end
	end
	
	local card_gap = 4
	
	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	
	stacks_supply = {}
	for i = 1,available_columns do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			stack_repose_normal(),
			true, stack_can_rule, 
			stack_on_click_unstack(unstack_rule_decending)))	
	end
	
	
	deck_stack = stack_new(
		{5,31},
		card_gap, card_gap,
		stack_repose_static(-0.16),
		true, stack_cant, stack_on_click_reveal)
		
	stack_goal = stack_new(
		{5,31},
		card_gap, card_gap * 3 + card_height,
		stack_repose_static(-0.16),
		true, stack_cant, stack_cant
		)

	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, suite_exit_game).always_active = true

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
			-- ensure that the last click on the deck of cards places a card on each middle stack
			if i ~= 5 or #deck_stack.cards % #stacks_supply ~= 0 then
				local c = get_top_card(deck_stack)
				stack_add_card(s, c)
				c.a_to = 0.5
				pause_frames(3)
			end
		end
		pause_frames(5)
	end

	cards_api_game_started()
end

-- places all the cards back onto the main deck
function game_reset_anim()
	stack_collecting_anim(deck_stack, stacks_supply, stack_goal)
	
	game_setup_anim()
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
		if c1.rank - 1 == c2.rank then
			return true
		end
	end	
end

function stack_on_click_reveal(card)
	if #deck_stack.cards>0 then
		cards_coroutine = cocreate(deck_draw_anim)
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
	
	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		if next_card.a_to == 0.5 -- must face up
		or next_card.suit ~= card.suit -- must match suit
		or next_card.rank+1 ~= card.rank then -- must decrease in rank
			return false
		end
				
		card = next_card -- current card becomes previous card
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



function game_action_resolved()
	for stack in all(stacks_supply) do
		local i = #stack.cards
		local card = stack.cards[i]
		i -= 1 -- prepare next card

		-- for every king found
		if card and card.rank == 1 then
			local suit = card.suit
			local r = card.rank+1 -- start by searching for queen
			
			while i > 0 -- haven't reached end of stack
			and stack.cards[i].rank == r -- card has expected rank
			and stack.cards[i].suit == suit -- card has same suit
			and r <= total_ranks do -- haven't haven't checked rank 1 yet
				r += 1 -- 1 rank lower, ignore Aces
				i -= 1 -- next card
			end
			
			-- if all the ranks found
			if r > total_ranks then
				i += 1
				cards_coroutine = cocreate(function()
					pause_frames(15)
					while stack.cards[i] do
						stack_cards(stack_goal, unstack_cards(stack.cards[#stack.cards]))
						pause_frames(3)
					end
				end)
				
			end
		end
		if card and not held_stack then
			card.a_to = 0
		end
	end
end

-- winning things
function game_win_anim()
	confetti_new(130,135, 100, 10)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
end

function game_win_condition()
	return #cards_all == #stack_goal.cards
end

function game_count_win()
	game_score.value += 1
	game_save.wins += 1
	suite_store_save(game_save)
	cards_coroutine = cocreate(game_win_anim)
end

end
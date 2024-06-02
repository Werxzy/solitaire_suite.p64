--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-06-02 01:32:29",revision=2935]]

function game_load() -- !!! start of game load function
-- this is to prevent overwriting of game modes

include "suite_scripts/rolling_score.lua"
include "suite_scripts/confetti.lua"
include "cards_api/card_gen.lua"

-- updates card size if it changed
card_width = 45
card_height = 60

all_suit_colors = {
	{1, 1,16,12},
	{8, 24,8,14},
	{21, 21,18,13},
	{25, 4,25,9}
}

rank_count = 13 -- adjustable

cards_api_clear()
cards_api_shadows_enable(true)

function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		wins = 0
	}	
	
	local card_sprites = card_gen_standard(4, rank_count, nil, nil, all_suit_colors)

	local card_gap = 4
	for suit = 1,4 do
		for rank = 1,rank_count do		
			local c = card_new(card_sprites[suit][rank], 240,100)
			c.suit = suit
			c.rank = rank
		end
	end
	
	local unstacked_cards = {}
	for c in all(cards_all) do
		add(unstacked_cards, c)
	end
	
	
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			{5},
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			{
				reposition = stack_repose_normal(),
				can_stack = stack_can_rule, 
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up), 
			}))
			
	end
		
	
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		{
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal, -- todo replace with drawing a card
		})
		
	hand_stack = stack_new(
		{},
		150, 180,
		{
			reposition = stack_repose_hand(),
			--on_click = stack_on_click_unstack(), 
			on_click = unstack_hand_card,
			
			-- TODO?, these may be a part of stack_repose_hand
			on_hover = hand_on_hover,
			off_hover = hand_off_hover,
			unresolved_stack = stack_unresolved_return_rel_x
		})
	-- TODO: inserting cards will require adding card specifically above another card in draw order
		
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		stack_add_card(deck_stack, c, unstacked_cards)
		c.a_to = 0.5
	end
	
	button_simple_text("New Game", 40, 248, function()
		cards_coroutine = cocreate(game_reset_anim)
	end)
	
	button_simple_text("Exit", 6, 248, function()
		rule_cards = nil
		suite_exit_game()
	end).always_active = true
	
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

	for i = 1,7 do	
		for j, s in pairs(stacks_supply) do
			if j >= i then
				local c = get_top_card(deck_stack)
				if(not c) break
				
				c.a_to = j == i and 0 or 0.5
				stack_add_card(s, c)
				--sfx(3)
				pause_frames(3)
			end
		end
		pause_frames(5)
	end

	cards_api_game_started()
end

-- places all the cards back onto the main deck
function game_reset_anim()
	stack_collecting_anim(deck_stack, stacks_supply, stack_goals, deck_playable)
	
	game_setup_anim()
end



function game_action_resolved()
	if not held_stack then
		for s in all(stacks_supply) do
			local c = get_top_card(s)
			if(c) c.a_to = 0
		end
	end
end

function game_win_anim()
end

function game_win_condition()
	return false
end

function game_count_win()
	game_score.value += 1
	game_save.wins += 1
	suite_store_save(game_save)
	cards_coroutine = cocreate(game_win_anim)
end

-- reposition calculation that has fixed positions
function stack_repose_top_three(stack)
	local y = stack.y_to
	local len = #stack.cards - 3
	for i, c in pairs(stack.cards) do
		c.x_to = stack.x_to
		c.y_to = y
		y += i <= len and 2 or 12
	end
end

-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	if #stack.cards == 0 then
		return true
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	if c1.rank - 1 == c2.rank 
	and (c1.suit + c2.suit) % 2 == 1 then -- alternating suits (b,r,b,r) (0,1,2,3)
		return true
	end

	--if c1.rank - 1 == c2.rank then
	--	return true
	--end
end

-- expects to be stacked from ace to king with the same suit
function stack_can_goal(stack, stack2)
	
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
		stack_add_card(hand_stack, c)
		c.a_to = 0
	end
end

function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if it fits the rule
	for j = i+1, #s do
		local next_card = s[j]
		
		-- not decending by 1
		if next_card.rank+1 ~= card.rank then
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
		if(rule_cards) rule_cards:draw()
		
	elseif layer == 2 then
		confetti_draw()
	end
end

function game_update()
	game_score:update()
	confetti_update()
	if(rule_cards) rule_cards:update()
end



-- new hand event functions
-- may move to stack.lua

function stack_repose_hand(x_delta, limit)
	x_delta = x_delta or 25
	limit = limit or 140
	
	return function(stack, dx)
		local x, xd = stack.x_to, min(x_delta, limit / #stack.cards)
		for i, c in pairs(stack.cards) do
			c.x_to = x
			c.x_offset_to = stack.ins_offset and stack.ins_offset <= i and x_delta/2 or 0
			
			c.y_to = stack.y_to
			c.y_offset_to = c.hovered and -15 or 0
			x += xd
		end
	end
end

-- designed to pick up a single card
function unstack_hand_card(card)
	if not card then
		return
	end
	
	-- TODO? would rather not have to do this
	card.x_offset_to = 0
	card.y_offset_to = 0
	card.hovered = false
	
	local old_stack = card.stack
	
	-- TODO: general creation function for held stack
	local new_stack = stack_new(
		nil, 0, 0, 
		{
			reposition = stack_repose_normal(10), 
			perm = false,
			old_stack = old_stack,
			old_pos = has(old_stack.cards, card)
		})
		
	new_stack._unresolved = old_stack:unresolved_stack(new_stack, has(old_stack.cards, card))
	
	-- moves card to new stack
	-- TODO: is this a function? (could be)
	add(new_stack.cards, del(old_stack.cards, card))
	card_to_top(card) -- puts cards on top of all the others
	card.stack = new_stack
	
	-- TODO: turn empty stack deletion check into function
	if #old_stack.cards == 0 and not old_stack.perm then
		del(stacks_all, old_stack)
	end	
	
	held_stack = new_stack
	--return new_stack
end

function hand_on_hover(self, card, held)
	
	if held then
		-- shift cards and insert held stack into cards_all order
		self.ins_offset = hand_find_insert_x(self, held)
		cards_into_stack_order(self, held, self.ins_offset)

	else
		self.ins_offset = nil
		if card then
			card.hovered = true
		end
	end
	
end

function hand_off_hover(self, card, held)
	if held then
		-- shift cards and back and put held cards back on top
		self.ins_offset = nil
		stack_update_card_order(held)
	end
	
	if card then
		card.hovered = nil
	end
end


end -- !!! end of game load function
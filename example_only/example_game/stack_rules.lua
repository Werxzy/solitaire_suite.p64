--[[pod_format="raw",created="2024-06-28 02:31:21",modified="2025-02-19 04:55:07",revision=585]]


-- determines if stack2 can be placed on stack
-- for solitaire rules like decending ranks and alternating suits
function stack_can_rule(stack, stack2)
	-- empty stack can always have cards placed on it
	if #stack.cards == 0 then
		return true
	end
	
	-- get's the top card of stack and bottom/first card of stack2
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	-- 1 rank below, and is alternating suit
	if c1.rank - 1 == c2.rank 
	and c1.suit ~= c2.suit then
		return true
	end
end

-- expects to be stacked from ace to king with the same suit
function stack_can_goal(stack, stack2)
	
	-- only one card at a time
	if #stack2.cards ~= 1 then
		return false
	end
	
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1] 
	
	-- if there's no cards, then expect and ace card
	if #stack.cards == 0 and c2.rank == 1 then
		return true
	end
	
	-- need to be one rank above and the same suit
	if #stack.cards > 0 and c1.rank + 1 == c2.rank and c1.suit == c2.suit then
		return true
	end
end

-- used when the deck is clicked on
function stack_on_click_reveal()
	local s = deck_stack.cards
	
	-- move top card to the hand_stack and turn it face up
	-- only if there are cards available and there are less than 5 in the hand
	if #s > 0 and #hand_stack.cards < 5 then
		local c = s[#s]
		stack_add_card(hand_stack, c)
		c.a_to = 0
	end
end

-- checks if the cards are decending in rank
function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if the rank decends
	-- assumes that the suit alternates
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

-- the number of cards in the hand cannot go above 5
function hand_can_stack(stack, stack2) 
	return #stack.cards + #stack2.cards <= 5 
end


-- attempts to place the card onto any of the goal stacks
-- returns true if successful
function stack_on_double_goal(card, from_hand)
	-- only accept top card (though could work with multiple cards
	if card and (from_hand or card_is_top(card)) then 
		local old_stack = card.stack
		-- create a temporary stack containing the card
		local temp_stack = from_hand and unstack_hand_card(card) or unstack_cards(card)
		
		-- attempt to place on each of the goal stacks
		for g in all(stack_goals) do
			if g:can_stack(temp_stack) then
				stack_cards(g, temp_stack)
				card.a_to = 0 -- turn face up
				return true
			end
		end
			
		-- if temp stack still exists, then return card to original stack
		if temp_stack then
			stack_apply_unresolved(temp_stack)
		end
	end
end

-- goes through each card and plays a card where it expects
-- easier than double clicking each card
function game_auto_place_anim()
	::again::
	pause_frames(6) -- delay between cards
	
	-- checks each of the supply stacks, starting from the closest to the goal stacks
	for i = #stacks_supply, 1, -1 do
		if stack_on_double_goal(get_top_card(stacks_supply[i])) then
			-- if found, find the next card the can be stacked on the goal
			goto again
		end
	end
	
	-- each card in hand will be checked by themselves
	for c in all(hand_stack.cards) do
		if stack_on_double_goal(c, true) then
			goto again
		end
	end
end
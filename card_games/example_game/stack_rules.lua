--[[pod_format="raw",created="2024-06-28 02:31:21",modified="2024-06-28 02:57:17",revision=31]]


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
	if #s > 0 then
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


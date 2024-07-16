--[[pod_format="raw",created="2024-06-28 02:31:21",modified="2024-07-16 06:37:29",revision=4076]]

-- if the cards are connected by rank or one is wild
-- r1 on top of r2
local function is_stackable_rank(r1, r2)
	return r1 == "wild" 
		or r2 == "wild" 
		or type(r1) == "number" and type(r2) == "number" and r1 - 1 == r2
end

-- for solitaire rules like decending ranks
function stack_can_rule(stack, stack2)
	-- empty stack can always have cards placed on it
	if #stack.cards == 0 then
		return true
	end
	
	-- get's the top card of stack and bottom/first card of stack2
	local c1 = stack.cards[#stack.cards].rank
	local c2 = stack2.cards[1].rank
	
	-- 1 rank below or wild, or placed card is bomb
	return is_stackable_rank(c1, c2) or c2 == "bomb" or c2 == "shuffle"
end


-- checks if the cards are decending in rank
function unstack_rule_decending(card)
	local s = card.stack.cards
	local i = has(s, card)
	
	-- goes through each card above clicked card to see if the rank decends
	-- assumes that the suit alternates
	for j = i+1, #s do
		local next_card = s[j]
		
		-- not decending by 1 or connected by wild
		if not is_stackable_rank(card.rank, next_card.rank) then
			return false
		end
	
		card = next_card -- current card becomes previous card
	end
	
	return true
end

-- wraps the resolve function
function wrap_stack_resolve(stack, check_effect)
	local old_resolve_stack = stack.resolve_stack
	
	stack.resolve_stack = function(s, held)
		local changed = s ~= held.old_stack
		
		old_resolve_stack(s, held)
		
		if changed then
			if check_effect then
				action_effect_check = s
			end
	
			action_count_up = true
		end
	end
end

-- checks if the card placement has changed

function can_stack_only_one(stack, held)
	return #stack.cards == 0 and #held.cards == 1
end


function count_cards()
	local cards = {0,0,0,0,0}
	-- cards.wild = 0
	-- cards.bomb = 0
	-- ...
	
	for s in all(stack_storage) do
		for c in all(s.cards) do
			local n = cards[c.rank]
			cards[c.rank] += 1
		end
	end
	
	for s in all(stacks_supply) do
		for c in all(s.cards) do
			local n = cards[c.rank]
			if n then
				cards[c.rank] += 1
			end
		end
	end
	return cards
end

-- TODO determine ranks and bonus cards
function random_least(n)
	local counts = count_cards()
	local added = {}
	
	for _ = 1,n do
		-- finds the lowest current value
		local lowest = 999
		for i = 1,5 do
			lowest = min(lowest, counts[i])
		end
		
		-- if there's a card that doesn't exist, then require it to be added
		lowest += lowest == 0 and 1 or 2	
	
		-- accumulate cards below a threshold
		local lt2 = {}
		for i = 1,5 do
			if counts[i] < lowest then
				add(lt2, i)
			end
		end
		
		-- pick a random one
		local c = rnd(lt2)
		counts[c] += 1
		add(added, c)
	end
	
	return added
end

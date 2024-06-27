--[[pod_format="raw",created="2024-03-22 19:08:40",modified="2024-06-27 00:50:28",revision=9655]]

-- built-in confetti script
include "suite_scripts/confetti.lua"
-- built-in card sprite generation script
include "cards_api/card_gen.lua"

include "game/test_include.lua"
-- including or fetching files next to the main file should include
-- "/game/" or "game/" at the start of the path

-- some variables used for consistency
card_width = 45
card_height = 60
card_gap = 4

suit_count = 4
rank_count = 13

cards_api_shadows_enable(true)

-- function called after the game is selected and started from the main menu
-- name must match
function game_setup()

	-- save data is based on lua file's name
	game_save = suite_load_save() or {
		wins = 0 -- default save data, can store game settings here
	}	
	
	-- get the card back sprite that the player wants to use
	local card_back = suite_card_back()

	-- generates sprites with given parameters
	local card_sprites = card_gen_standard{
		suits = suit_count, 
		ranks = rank_count
	}

	-- generates cards with the given suits and ranks
	for suit = 1,suit_count do
		for rank = 1,rank_count do		
			local c = card_new({
				 -- front sprite
				sprite = card_sprites[suit][rank],
				-- backs sprite
				back_sprite = card_back
			})
			
			-- assigns the card it's suit and rank
			c.suit = suit
			c.rank = rank
		end
	end
	
	-- creates a table of all the unstacked cards
	local unstacked_cards = {}
	for c in all(get_all_cards()) do
		add(unstacked_cards, c)
	end
	
	
	-- creates 7 stacks evenly spaced out 
	-- stacks are places for cards to be held, while having rules for how cards can be taken
	stacks_supply = {}
	for i = 1,7 do
		add(stacks_supply, stack_new(
			-- sprites that the stack will use when being drawn
			-- can be integers or userdata
			{5},
			-- position of the stack (x, y)
			i*(card_width + card_gap*2) + card_gap, card_gap, 
			{
				-- function for how cards are to update thier positioned
				-- stack_repose_normal: each card is spaced downward
				reposition = stack_repose_normal(),
				
				-- function for if a card can be stacked on top of the stack of cards
				-- stack_can_rule : custom stacking rule (see definition way below)
				can_stack = stack_can_rule, 
				
				-- event for when a card in the stack is clicked, 
				-- stack_on_click_unstack : 	unstack it and all cards on top of it if those cards follow a given set of rules
				-- unstack_rule_decending : 	the cards must be decending in suit
				-- unstack_rule_face_up : 	clicked card must be face up
				on_click = stack_on_click_unstack(unstack_rule_decending, unstack_rule_face_up), 
			}))
			
	end
		
	-- stack that will contain all the cards
	deck_stack = stack_new(
		{5,6},
		card_gap, card_gap,
		{
			-- stack_repose_static: much more stiff in the card repositioning
			-- -0.16 packs the cards more tightly like a normal stack of cards
			reposition = stack_repose_static(-0.16),
			on_click = stack_on_click_reveal,
		})
	
	-- speical stack that will lay out the cards like a hand
	-- cards can be added/removed in any order, or even be reordered
	hand_stack = stack_hand_new(
		{},
		150, 180,
		{
			hand_width = 200,
			hand_max_delta = 30,
			-- any card can be stacked here
			-- TODO, have a hand limit of 5
			can_stack = function() return true end,
		})
		
	-- goes through all the cards and puts them into the deck stack in a random order
	while #unstacked_cards > 0 do
		local c = rnd(unstacked_cards)
		-- add card "c" to "deck_stack" and remove it from table "unstacked_cards"
		stack_add_card(deck_stack, c, unstacked_cards)
		-- turn card face down
		c.a_to = 0.5
	end
	
	-- initializes the menu bar
	-- will currently contain the click, exit game, and settings buttons
	suite_menuitem_init()
	
	-- new game button the resets how the game plays
	suite_menuitem({
		text = "New Game",
		colors = {12, 16, 1}, 
		on_click = function()
			-- when clicked, create a new coroutine that will control the game
			cards_api_coroutine_add(cocreate(game_reset_anim))
		end
	})
	
	-- adds a button for the built in rules text box
	suite_menuitem_rules()
	
	-- adds a label for the number of wins in the game
	wins_button = suite_menuitem({
		text = "Wins", -- name
		value = "0000" -- default value
		-- no on_click attribute means it will not do anything when clicked
	})
	
	-- function used to update the text value
	wins_button.update_val = function(b)
		local s = "\fc"..tostr(game_save.wins)
		while(#s < 6) s = "0".. s
		b:set_value(s)
	end	
	-- updates the value on setup
	wins_button:update_val()
	
	-- example of a button
	suite_button_simple("Test Button", 300, 200, function() --[[do things here]] end)
	
	-- adds a coroutine that sets up the game and prevents interaction with any of the cards
	cards_api_coroutine_add(cocreate(game_setup_anim))
	
	-- resets the position of all cards
	card_position_reset_all()
end

-- deals the cards out
function game_setup_anim()
	-- wait for a bit
	pause_frames(30)

	-- deal 7 cards out
	for i = 1,7 do	
		-- for each stack
		for j, s in pairs(stacks_supply) do
			if j >= i then
				-- take the top card
				local c = get_top_card(deck_stack)
				if(not c) break
				
				-- turn if face down unless, it's going to be the top card
				c.a_to = j == i and 0 or 0.5
				-- moves the card "c" to the top of stack "s"
				stack_add_card(s, c)
				-- pause for 3 framesto allow the game to animate individual cards dealt
				pause_frames(3)
			end
		end
		-- extra pause between every row of cards dealt
		pause_frames(5)
	end

	-- notify the api that a new game has started
	-- this is important for re-enabling card interaction
	cards_api_game_started()
end

-- coroutine that places all the cards back onto the main deck
function game_reset_anim()
	-- takes cards from stack_supply and hand_stack into deck_stack 
	stack_collecting_anim(deck_stack, stacks_supply, hand_stack)
	
	-- plays the setup coroutine
	game_setup_anim()
end

-- called any time a game action is done
function game_action_resolved()
	-- if no cards are being held
	if not get_held_stack() then
		-- check all stacks
		for s in all(stacks_supply) do
			-- turn the top card face up
			local c = get_top_card(s)
			if(c) c.a_to = 0
		end
	end
end


-- returns true when the game's win condition is fulfilled
function game_win_condition()
	return false
end

-- called when the game's win condition is fulfilled
-- (yes, it's important that this is separate)
function game_count_win()
	-- increase the win count
	game_save.wins += 1
	-- update the value displayed by wins_button
	wins_button:update_val()
	-- save the game data
	suite_store_save(game_save)
	
	-- play the win animation
	cards_api_coroutine_add(cocreate(game_win_anim))
end

-- coroutine for when the game is won
function game_win_anim()
	-- creates 100 confetti particles at (130, 135) with velocity 10
	confetti_new(130,135, 100, 10)
	-- wait 25 frames (for effect)
	pause_frames(25)
	confetti_new(350,135, 100, 10)
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
	-- empty stack can always have cards placed on it
	if #stack.cards == 0 then
		return true
	end
	
	-- get's the top card of stack and bottom/first card of stack2
	local c1 = stack.cards[#stack.cards]
	local c2 = stack2.cards[1]
	
	-- 1 rank below, and is alternating suit
	if c1.rank - 1 == c2.rank 
	and (c1.suit + c2.suit) % 2 == 1 then -- alternating suits (b,r,b,r) (0,1,2,3)
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

-- primary draw function, called multiple times with layers being from 0 to 3
-- don't forget to check layer number
-- name must match
function game_draw(layer)
	-- layer 0 is below everything, screen needs to be reset here
	if layer == 0 then
		-- clear function needs to be called during layer 0
		-- or at least drawing over the entire screen
		cls(3)
	
	-- layer 1 is above all layer 1 buttons and stack sprites
	
	-- layer 2 is drawn above all cards
	elseif layer == 2 then
		confetti_draw()
	end
	
	-- layer 3 and 4 are mostly reserved and are drawn above everything else 
end

-- primay update function
-- name must match
function game_update()
	confetti_update()
end


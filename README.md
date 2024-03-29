

## Defineable Game Functions
```lua
-- caled every _draw, giving control when to draw with layer
function game_draw(layer)
  if layer == 0 then
    -- before anything else is drawn
    -- make sure to call cls

  elseif layer == 1 then
    -- after stack sprites and buttons are drawn, before cards

  elseif layer == 2 then
    -- after cards are drawn, currently last layer
    
  end
end

-- called every _update, after card and mouse updates
function game_update()
end

-- called after any action is taken
-- clicking, picking up a stack, letting go of a stack, animation finished, etc
function game_action_resolved()
  if not held_stack then
    -- it's sometimes a good idea to not update an object when the player is holding a stack of cards
  end
end

-- returns true when the game has reached a winning state
-- called right after game_action_resolved
-- when returning true, will set cards_frozen = true
function game_win_condition()
  return false
end

-- cards_frozen will prevent any mouse interaction with cards

-- called when game_win_condition returns true
function game_count_win()
  -- count score and/or play events
end

```

## API Functions to call
```lua

-- called when a game has started and mouse interaction should be allowed
cards_api_game_started()

-- clears the stacks, buttons, and cards from the tables and resets values of the api
-- when keep_func is falsey, game_draw, game_update, game_action_resolved, and game_win_condition will be set to nil
-- cards_api_clear(keep_func)

-- enabling will make color 32 draw shadows
cards_api_shadows_enable(enable)
```

## Card Functions

A card is just a table containing position information, a sprite, and the stack it belongs to.
You can assign other values like suit and rank to affect behaviours using the card.

```lua
-- returns a table that is added to the 
-- sprite can be an id or userdata
local card = card_new(sprite, x, y, a)

-- can assign values to cards
card.suit = 1
card.rank = 1

card.x, card.y -- are set managed automatically by the stack they are in
card.a_to = 0 -- card facing angle, 0 = face up, 0.5 = face down

-- puts the card at the end of the cards table to draw the card on top of everything else
card_to_top(card)

-- returns true if the card iss the top card of the stack it is in
card_is_top(card)
```

## Stack Functions

Most of the mouse interactions with cards are automatically handled through stacks.

```lua
-- shifts the stack's draw position up and left by a given value, defaults to 3
stack_border = 3

-- returns the top card of the stack
get_top_card(stack)

-- returns a new stack and adds it to the main stack table
local stack = stack_new(sprites, x, y, repos, perm, stack_rule, on_click, on_double)
--[[
sprites = table of sprite ids or userdata
x,y = the top left position of the stack (minus the stack border value)
repos = function called when setting the position of the cards
perm = when false, the stack is removed when it has no cards
stack_rule = returns true if a second stack is allowed to be placed on this stack
on_click = function called when the stack base or card in stack is clicked, can be nil, primarily used for unstacking
on_double = function called when the stack base or card in stack is double clicked, can be nil
resolve_stack = called when the stack_rule returns true, defaults to stack_cards
]]

-- stack.cards[1] is the bottom card
-- stack.cards[#stack.cards] is the top card
-- literal stack

-- puts all cards from stack2 on top of stack1
-- ignores stack rule
stack_cards(stack1, stack2)

-- unstacks a card and any cards on top of it when clicked (if all rules return true)
-- one of the functions assigned to on_click in stack
-- can take any number of rule functions
stack_on_click_unstack(...)
-- rule functions take in a single parameter (card) and return true if the card can be unstacked
-- possible to give no parameters to always allow unstacking

-- unstack rule example (exists in stack.lua)
-- card must be face up to be picked up
function unstack_rule_face_up(card)
	return card.a_to == 0
end

-- creates a temporary stack starting from a given card
local temp_stack = unstack_cards(card)

-- returns a card repositioning function (for repos)
-- used to give cards a more floaty feel
stack_repose_normal(y_delta, decay, limit) -- defaults (12, 0.7, 220)

-- returns a card repositioning function
-- stiffer than the version above
stack_repose_static(y_delta) -- defaults (12)

-- example of a card repositioning function
function stack_repose_simple(stack)
  local y = stack.y_to
  for c in all(stack.cards) do
    c.x_to = stack.x_to
    c.y_to = y
    y += 12
  end
end

-- moves a card from it's old stack or table to a new one
function stack_add_card(stack, card, old_stack)
-- if old_stack is not nil and a table, card will be removed from that stack
-- if old_stack is a number, the card will instead be inserted into that position in the new stack
-- (this should probably be more refined)
```




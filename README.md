

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

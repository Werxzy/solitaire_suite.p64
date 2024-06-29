--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-06-29 21:02:19",revision=15795]]
--[[

== ANY update before release ==	

update label with new solitaire variants (credit pixelDub)
	specifically when a 0.X.0 version is released
	
update .p64 version number
force update for all subrepository files
create pull request for main branches
make release with new version tag
post

== 0.2.0 ==
	

card box sprite size calculation for shadows? (main menu)
	I think they're currently constant

use pepper to create the example cart
	remove check for other games in appdata
	allow for custom card backs (and eventually music)


manage mods list
	use new custom window system
	upload example game to see if the right game can be pulled
	store metadata for what games were loaded
		cart name
		games detected
		author?
		version number?
		api version
	button to copy link to original page

	add update button so that all games can get updated to the newest version (unless dash is provided)


!prepare for example project 
	
	better game mode sharing support
		look at load.lua to be able to load in game modes from bbs carts and add them to appdata
		maybe use game info to double check file
		probably copy the contents of the bbs_card.p64.png/card_games into it's own folder
			if the folder already exists, clear it
			
		add an example game that can easily be copied and 
		add update button that looks at the original cart
			similar to the load idea, just replacing files
			
		wait, some way to update the base cart's scripts?

message zep about using fetch to gather carts






last played card game is automatically selected on the main menu
	only when exiting from that game
		
overlap optmization
	when cards are not moving, render only part of the card that would be visible
	
	function update_placement(stack)
		for i,c in all(stack.cards) do
			c.placement = i
		end
	end

custom games
	card falling game
		5-7 columns
		moving a card from one stack to another will increase a counter
			after a counter is maxxed, it resets and every column gets a new card on bottom
				cards can be face down
			(or maybe when getting a new card from the deck)

		create straights of (5?) cards to remove them
			probably allow king to go to ace

	
== 0.?.0 ==

hand_unstack currently (ignoring the not_held parameter) move the card to held
	this is a bit inconsistent with the function stack_on_click_unstack function
	maybe have a function hand_on_click_unstack which removes only one card
		and then have hand_unstack only return the new stack
		
	assign the unstack action to the stack?

tutorial
	some clicking and dragging of cards
	teach ranks 
		first go 5 to ace
		then king to ace
		
page control or scrolling for the suite_window
	
?switch to userdata for some of the structures (it's much faster)
		
credits section
	list contributions when there are enough people contributing

visual tutorial sequence for a each game
	walk though different steps and display speech bubbles pointing a different game elements
	if a sequence isn't provided for game, don't display the option to view a tutorial
	

== maybe ?? ==

? better error handling for solitaire variants

include 1.map or 1.sfx in the future

transition draw mode?
	(probably more named a disable drawing mode or something)
	prevents drawing or updating elements like the cards or stack sprites
	then when the transition is happening, store the first frame when drawing the new level
		and draw the transition using only the 2 stored screen sprites
	would require disabling input during the transition

change button control of cards api to instead check for any interaction
	maybe have a clickable priority
	clickables = {
		[0] = {first / topmost}
		[1] = {default / before stacks, after cards}
		[2] = {last / after everything else}
	}
	return true if click is consumed
	if true, call the on_click function
	
? add bool to enable shadows for cards in hand

??? better variable encapsulation
	(attempted this, but it doesn't work out that well due to not planning for it from the start)

	essentially, when including a new game, it should not have access to some functions, like fetch or store
		this is more to prevent malicious code
		but this would require some large refactoring

	clean up env
		probably will need to have functions for getting tables that could change outside of the scope
		like held_stack would change, but it wouldn't be communicated to the game env

double click for instantly starting the game.
	
				
]]
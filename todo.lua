--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-06-24 19:36:17",revision=13364]]
--[[

before release

update .p64 version number
create pull request for main branches
make release with new version tag
post

== 0.2.0 ==

clean up env		
	move card box to 1.gfx
		
update settings menu
	finish other buttons
	adjust look of settings
	allow for custom menu

consistent naming
	always use .width and not .w
	double check .x_to
	.text vs .str?	
	bn vs b in buttons	
	
change transition to be controllable by the game
	if no transition is started, then apply the default one and add an coroutine for delay

!prepare for example project 

	coroutine queue instead of single instance
	
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

manage mods list

remove card_shadow enable/disable on variants, force shadows to be on?

enforce cards to always have a stack?
	inside init
double check trapdoor solitaire the stored card gets properly flipped faced downs

tutorial
	some clicking and dragging of cards
	teach ranks 
		first go 5 to ace
		then king to ace
		
last played card game is automatically selected on the main menu
	only when exiting from that game
		
update label with new solitaire variants (credit pixelDub)
	specifically when a 0.X.0 version is released
	

== 0.?.0 ==
	
?switch to userdata for some of the structures (it's much faster)
		
credits section
	list contributions when there are enough people contributing

== maybe ?? ==

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
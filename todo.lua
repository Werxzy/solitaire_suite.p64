--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-06-02 00:30:58",revision=6129]]
--[[

before release

update .p64 version number
create pull request for main branches
make release with new version tag
post

0.2.0

!rework stack/card scripting

	stack on_highlight rule function
		hover is a shorter name
		per card and per 
		or
		essentially determines if the stack triggers the highlight rule
		should be able to handle a held stack
		
		(highlight rule and check are going to be used for managing a hand)
		
	make a test game for the new hover and unresolved rules

? full clean of stacks
	assign .ty = "stack"
	and then go through all global variables to clear out anything in memory

!adjuste menu/drawing
	double click for instantly starting the game.
	
	scrolling through card backs
		currently it is a fixed size
		this will be a problem when someone adds too many card backs
	
	Add script dedicated to card sprite generation.
		use nine_slice to generate base
		make a cut out of the card backs
			they should be 100x100 pixels each
			focusing on 41x56 pixels in the center being the normal sprite
			
	transition
		use pget to sample colors and then use circfill to grow and fill the screen
		
	?switch to userdata for some of the structures (it's much faster)

!prepare for example project 
	clean up env
	
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

tutorial
	some clicking and dragging of cards
	teach ranks 
		first go 5 to ace
		then king to ace
		
update label with new solitaire variants (credit pixelDub)
	specifically when a 0.X.0 version is released


0.?.0

credits section
	list contributions when there are enough people contributing


]]
--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-06-04 05:29:45",revision=7118]]
--[[

before release

update .p64 version number
create pull request for main branches
make release with new version tag
post

0.2.0

!adjuste menu/drawing
	new look for the menus and buttons
	
	Add script dedicated to card sprite generation.
		use nine_slice to generate base
		make a cut out of the card backs
			they should be 100x100 pixels each
			focusing on 41x56 pixels in the center being the normal sprite
			
	scrolling through card backs
		currently it is a fixed size
		this will be a problem when someone adds too many card backs
	
	transition
		use pget to sample colors and then use circfill to grow and fill the screen
		
	?switch to userdata for some of the structures (it's much faster)

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

maybe ??
	
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
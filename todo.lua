--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-06-17 11:35:56",revision=10129]]
--[[

before release

update .p64 version number
create pull request for main branches
make release with new version tag
post

0.2.0
			
!adjust menu/drawing
	update user interface
		buttons are a bit plain
		
		fix card back moving on loading solitaire suite
		
		in example game
			add new rules card system
				some options can have a small window pop up
		
		update other games to use the same system
			also the new button ( suite_button_simple() )
							
		new frame for the card back description
					
	functions for cocreate animations

	transition
		use pget to sample colors and then use circfill to grow and fill the screen
		
	?switch to userdata for some of the structures (it's much faster)
			
	setting menu?
		probably a menu that pops up
		maybe save display and then prevent interaction with anything else
		maybe have button priorities
		maybe have a button priority limit to prevent interacting with buttons or cards outisde of the settings menu
	
	button disable for a half second when clicking the return button on card back selection
		able to click exit game button by accident				

clean up env
	(will want to move card_width and card_height first)

	copy only functions
	tables or important variables need get/set functions 
		currently it's probably just 
			held_stack
			cards_all
			stacks_all
			
	add graphics from 1.gfx in game folder	
	maybe 1.sfx and 1.map as well?	

consistent naming
	always use .width and not .w
	double check .x_to
	.text vs .str?			

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
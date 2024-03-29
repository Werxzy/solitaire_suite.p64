--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-03-29 07:31:42",revision=3950]]
--[[

0.1.0	

prepare comment for post
	explaining 0.2 and how to add new game types
	also allow collaboration for music
add a readme to cards api explaining
determine and add license to cards api
	remember .txt

0.1.?

? rect to rect collision instead of point to rect

switch to userdata for some of the structures (it's much faster)

0.2.0?

rather than a held stack containing old_stack, it contains a function for undoing the unstacking operation
	this is for returning a card to the middle of a stack
	or if an undo action cannot take place?

double click for instantly starting the game.

transition
	use pget to sample colors and then use circfill to grow and fill the screen

Add script dedicated to card sprite generation.
	use nine_slice to generate base
	make a cut out of the card backs
		they should be 100x100 pixels each
		focusing on 41x56 pixels in the center being the normal sprite
		
stack on_highlight rule function
	hover is a shorter name
	per card and per 
	
stack highlight_check function
	essentially determines if the stack triggers the highlight rule
	should be able to handle a held stack

(highlight rule and check are going to be used for managing a hand)

coroutine queue instead of single instance


update label with new solitaire variants (credit pixelDub)




]]
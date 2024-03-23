--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-03-23 04:28:27",revision=1769]]
--[[

0.1.0
fix solitaire a bit
	cards go 1,2,3,4,5,6,7 instead of all 5s
	only top cards are face up
		turn top card face up
			probably do this on resolve?
	face down cards cannot be picked up
	
symbol count on cards
title image
function card backs?
	if a card has a function, then call that function instead of just 

0.2.0?
transition
	use pget to sample colors and then use circfill to grow and fill the screen

Add script dedicated to card sprite generation.
	use nine_slice to generate base
	make a cut out of the card backs
		they should be 100x100 pixels each
		focusing on 41x56 pixels in the center being the normal sprite
		
Add face card sprites

stack on_highlight rule function
	per card and per 
	
stack highlight_check function
	essentially determines if the stack triggers the highlight rule
	should be able to handle a held stack

(highlight rule and check are going to be used for managing a hand)








]]
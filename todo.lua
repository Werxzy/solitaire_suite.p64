--[[pod_format="raw",created="2024-03-21 03:40:46",modified="2024-07-17 08:05:03",revision=23705]]
--[[

== ANY update before release ==	

update label with new solitaire variants (credit pixelDub)
	specifically when a 0.X.0 version is released
	
update .p64 version number
force update for all subrepository files
create pull request for main branches
make release with new version tag
post

== !!! ==

message zep about using fetch to gather carts
	done!
	responded saying that it should work fine for now
	"bbs://" with be a separate protocol for handles caching and sandboxing etc.
	change will be inside suite_mod_window.lua

== 0.2.0 ==
	
add consistency in param for stuff like stack, cards, etc
	take in single table parameter and loop through keys to set properties
	
adjust how card boxes are ordered
figure out a better way to save cardback ids
fix menubar to have an adjustable size (mostly for the scores)

second custom game?
	roguelite of some sort?
	
double check and fill out documentation for 
	the example game
	suite
	cards api
	
== 0.3.0 ==	

better custom shadow for custom sprites?
	define a number/sprite inside game_info() to give a shadow
	
add proper sound effects and music manager

pull sound effects from pull request
	https://github.com/Werxzy/solitaire_suite.p64/pull/3
	
allow for recursive menuing?
	would require a bit of work to make it easy to work with
	
	or just make a menuing system that allows unpacking subsets of games
	
more functionality for card_gen
	
== 0.?.0 ==

generate once card back sprites
	sprites that change a bit based on their size, but only need to be generated once

extra mod list metadata for what games were loaded
	games detected?
		or card backs?
	api version?

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
	
double check card backs on mod load, update, or deletion

drag and drop cart and add it to the mods while the manager is open
	remember to check it is valid

== maybe ?? ==

stack sprite optimization???
	when a card is on top of a stack and isn't moving
	cut out the center rectangle of the stack
		would need to be split into 4 sspr calls, which might be a bit much?
		though if pixels are that expensive to draw, it might be worth it
	this MIGHT have a tiny bit of performance boost
	

more control for the card box sprites
	currently just shifts the position a bit based on the height
	also the shadow is always rectangular

include 1.map or 1.sfx in the future

transition draw mode?
	(probably more named a disable drawing mode or something)
	prevents drawing or updating elements like the cards or stack sprites
	then when the transition is happening, store the first frame when drawing the new level
		and draw the transition using only the 2 stored screen sprites
	would require disabling input during the transition
	
? add bool to enable shadows for cards in hand

double click for instantly starting the game.
	
better clearing of some objects
	stack:destroy()
	card:destroy()
	something for clearing unused animated card backs from the main list
				
update the list of games only when exiting the mod manager			

]]
--[[pod_format="raw",created="2024-06-29 22:17:58",modified="2024-07-20 17:52:25",revision=177]]


IN YOUR VERSIONS
ONLY MAKE CHANGES TO THE FOLLOWING:

- anything inside `card_games/`
- extra .lua files inside `card_backs/`
- `main_menu.lua` is fine, but try to only make visual changes

I labeled some things in `main_menu.lua` that you would might like to change with `EDIT THIS`.
Due to how mods are added to the main cart, changes outside of the card_games and card_backs will not transfer over.
The file pss_mod.pod is required to identify mod carts.
Without it, the main cart doesn't accept the mod carts.

While using `include` or `fetch` are fine, you will need to start the path with exactly `/game/` in order to fetch you're game's files.
This is because your game will either be accessed while being stored in either `/appdata/...` or `/card_games/...`

Make sure when you're done with the game, edit the file info of the cart.
This information (including the icon) will be displayed in the mod manager.
Also don't forget to make a fancy new label, no need to keep the style of the old one or even mention Picotron Solitaire Suite there.
Though please keep the sprite of Picotron Solitaire Suite mod somewhere in the main menu.

When you upload your mod to the bbs, make sure to add the tag #solitaire_suite_mod to the post and link the cart as a fork of the example cart #pss_example_project. These will be help people find mods for the game and be useful in the future when splore is released.

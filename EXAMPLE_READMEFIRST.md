--[[pod_format="raw",created="2024-06-29 22:17:58",modified="2024-06-30 00:07:37",revision=132]]

IN YOUR VERSIONS
ONLY MAKE CHANGES TO THE FOLLOWING:

- anything inside `card_games/`
- extra .lua files inside card_backs
- `main_menu.lua` is fine, but try to only make visual changes

I labeled some things in `main_menu.lua` that you would might like to change with `EDIT THIS`.

While using `include` or `fetch` are fine, you will need to start the path with exactly `/game/` in order to fetch you're game's files.
This is because your game will either be accessed while being stored in either `/appdata/...` or `/card_games/...`



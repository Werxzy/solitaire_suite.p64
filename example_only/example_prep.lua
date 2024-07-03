--[[pod_format="raw",created="2024-07-03 01:21:08",modified="2024-07-03 04:41:34",revision=247]]


-- alters the metadata of the example game
md = fetch_metadata("/ram/pepper")

md.title = "Example Project"
md.author = "Your Username Here"
md.version = ""
md.notes = "Example cart to help you start your own solitaire variants."

store_metadata("/ram/pepper", md)

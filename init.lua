
cave_explorer = {}

cave_explorer.translator = minetest.get_translator("cave_explorer")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/setting.lua")

dofile(modpath.."/functions.lua")

dofile(modpath.."/hammer.lua")

dofile(modpath.."/crafting.lua")


cave_explorer.settings = {}

cave_explorer.settings.deaf_amateur = minetest.settings:get_bool("cave_explorer_deaf_amateur", false)

cave_explorer.settings.max_reflections = tonumber(minetest.settings:get("cave_explorer_max_reflections_sounds") or "50")

cave_explorer.settings.hammer_steel_max_distance = tonumber(minetest.settings:get("cave_explorer_hammer_steel_max_distance") or "30")

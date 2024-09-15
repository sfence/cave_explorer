
cave_exploring.settings = {}

cave_exploring.settings.deaf_amateur = minetest.settings:get_bool("cave_exploring_deaf_amateur", false)

cave_exploring.settings.max_reflections = tonumber(minetest.settings:get("cave_exploring_max_reflections_sounds") or "50")

cave_exploring.settings.hammer_steel_max_distance = tonumber(minetest.settings:get("cave_exploring_hammer_steel_max_distance") or "30")

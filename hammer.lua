
local S = cave_exploring.translator

local settings = cave_exploring.settings

local HUMAN_DIST = settings.hammer_steel_max_distance
local max_reflections = settings.max_reflections

local get_node_echo = cave_exploring.get_node_echo

if settings.deaf_amateur then
	-- check just one dirrection
	function cave_exploring.get_human_reflections(pos_src, dir)
		local area_end = vector.multiply(dir, HUMAN_DIST)
		local p1 = vector.new(pos_src)
		local p2 = vector.add(pos_src, area_end)
		--print(dump({pos_src, dir}))
		--print(dump({p1, p2}))
		local manip = minetest.get_voxel_manip(p1, p2)
		local l1, l2 = manip:read_from_map(p1, p2)
		local area = VoxelArea(l1, l2)
		local data = manip:get_data()
		local pos = vector.new(pos_src)
		local index = area:indexp(pos)
		local p_id = data[index]
		--print("p_id: "..p_id.." name: "..minetest.get_name_from_content_id(p_id))
		local refs = {}
		local parent = {
				gain = 1.0,
				echo = get_node_echo(p_id)
			}
		for r=1,HUMAN_DIST do
			pos = vector.add(pos, dir)
			i = area:indexp(pos)
			local echo, gain, ref = get_node_echo(data[i])
			--print("echo; "..echo.." gain: "..gain.." ref: "..ref)
			gain = gain * parent.gain
			ref = gain * ref
			if echo <= 0 then
				-- emulate total reflection
				ref = parent.gain
			elseif echo ~= parent.echo then
				ref = ref + gain * math.abs(echo - parent.echo) * 0.1
			end
			if ref > 0 then
				gain = gain - ref
				table.insert(refs, {
					gain = ref,
					dist = dist,
					-- id can be later used for some extra effect?
					--id = data[index],
					--name = minetest.get_name_from_content_id(data[index])
				})
			end
			if echo > 0 and gain > 0.001 then
				-- new parent also
				parent = {
					gain = gain,
					echo = echo
				}
			else
				parent = nil
			end
			if not parent or #refs >= max_reflections then
				break
			end
		end
		return refs
	end
else
	-- emulate sound spreading
	function cave_exploring.get_human_reflections(pos_src, dir)
		local area_begin, area_end, iterate = cave_exploring.get_areas(dir, HUMAN_DIST)
		local p1 = vector.add(pos_src, area_begin)
		local p2 = vector.add(pos_src, area_end)
		--print(dump({pos_src, dir}))
		--print(dump({p1, p2}))
		local manip = minetest.get_voxel_manip(p1, p2)
		local l1, l2 = manip:read_from_map(p1, p2)
		local area = VoxelArea(l1, l2)
		local data = manip:get_data()
		local p = vector.new(pos_src)
		local index = area:indexp(p)
		local p_id = data[index]
		--print("p_id: "..p_id.." name: "..minetest.get_name_from_content_id(p_id))
		local refs = {}
		local parents = {
				[index] = {
					gain = 1.0,
					echo = get_node_echo(p_id)
				}
			}
		for r=1,HUMAN_DIST do
			--print("range: "..r.." parents: "..dump(parents))
			local ab, ae, iterate = cave_exploring.get_areas(dir, r)
			ab = vector.add(pos_src, ab)
			ae = vector.add(pos_src, ae)
			--print(minetest.pos_to_string(pos_src)..":")
			--print("  from: "..minetest.pos_to_string(ab))
			--print("  to: "..minetest.pos_to_string(ae))
			local nparents = {}
			local cont = false
			iterate(ab, ae, function(pos)
				--print("pos; "..minetest.pos_to_string(pos))
				local dist = vector.distance(pos_src, pos)
				-- parent pos 
				local ppos = vector.divide(vector.subtract(pos, pos_src), dist)
				--print("ppos; "..minetest.pos_to_string(ppos).." dist: "..dist)
				ppos = vector.round(vector.subtract(pos, ppos))
				--print("ppos; "..minetest.pos_to_string(ppos))
				local pi = area:indexp(ppos)
				--print("ppos; "..minetest.pos_to_string(ppos).." pi: "..pi)
				local parent = parents[pi]
				if parent then
					--print("Have parent for: "..minetest.pos_to_string(pos))
					local i = area:indexp(pos)
					local echo, gain, ref = get_node_echo(data[i])
					--print("echo; "..echo.." gain: "..gain.." ref: "..ref)
					gain = gain * parent.gain
					ref = gain * ref
					if echo <= 0 then
						-- emulate total reflection
						ref = parent.gain
					elseif echo ~= parent.echo then
						ref = ref + gain * math.abs(echo - parent.echo) * 0.1
					end
					if ref > 0 then
						gain = gain - ref
						table.insert(refs, {
							gain = ref,
							dist = dist,
							-- id can be later used for some extra effect?
							--id = data[index],
							--name = minetest.get_name_from_content_id(data[index])
						})
					end
					if echo > 0 and gain > 0.001 then
						-- new parent also
						nparents[i] = {
							gain = gain,
							echo = echo
						}
						cont = true
					end
				end
			end)
			if not cont or #refs >= max_reflections then 
				break
			end
			parents = nparents
		end
		return refs
	end
end

minetest.register_tool("cave_exploring:hammer_steel", {
	description = S("Geologist's hammer"),
	inventory_image = "cave_exploring_hammer_steel.png",
	on_use = function (itemstack, user, pointed_thing)
		--print("use")
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			if get_node_echo(minetest.get_content_id(node.name)) > 0 then
				local refs = cave_exploring.get_human_reflections(pointed_thing.under,
						vector.subtract(pointed_thing.under, pointed_thing.above))
				--print(dump(refs))
				local pos = vector.multiply(
						vector.add(pointed_thing.under, pointed_thing.above), 0.5)
				--print(pos)
				minetest.sound_play("cave_exploring_tap_stone", {pos = pos, gain = 1}, true)
				for _, ref in pairs(refs) do
					minetest.sound_play("cave_exploring_tap_stone_echo", {pos = pos, gain = ref.gain, pitch = ref.dist}, true)
				end
				itemstack:add_wear(10)
				return itemstack
			end
		end
	end
})
minetest.register_alias("cave_explorer:hammer_steel", "cave_exploring:hammer_steel")

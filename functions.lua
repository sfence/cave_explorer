
function cave_exploring.get_node_echo(n_id)
	local name = minetest.get_name_from_content_id(n_id)
	local echo = minetest.get_item_group(name, "stone")
	local gain = 1.0 - 0.09/echo
	-- ore can reflect?
	local ref = minetest.registered_nodes[name]._echo_reflection or 0
	return echo, gain, ref
end

local function iterate_area_surface_1(ab, ae, callback)
	for x = ab.x, ae.x do
		for y = ab.y, ae.y do
			callback(vector.new(x, y, ab.z))
			callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x, ae.x do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(x, ab.y, z))
			callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y+1, ae.y-1 do
		for z = ab.z+1, ae.z-1 do
			--callback(vector.new(ab.x, y, z))
			callback(vector.new(ae.x, y, z))
		end
	end
end
local function iterate_area_surface_2(ab, ae, callback)
	for x = ab.x, ae.x do
		for y = ab.y, ae.y do
			callback(vector.new(x, y, ab.z))
			callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x, ae.x do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(x, ab.y, z))
			callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y+1, ae.y-1 do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(ab.x, y, z))
			--callback(vector.new(ae.x, y, z))
		end
	end
end
local function iterate_area_surface_3(ab, ae, callback)
	for x = ab.x, ae.x do
		for y = ab.y, ae.y do
			callback(vector.new(x, y, ab.z))
			callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x+1, ae.x-1 do
		for z = ab.z+1, ae.z-1 do
			--callback(vector.new(x, ab.y, z))
			callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y, ae.y do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(ab.x, y, z))
			callback(vector.new(ae.x, y, z))
		end
	end
end
local function iterate_area_surface_4(ab, ae, callback)
	for x = ab.x, ae.x do
		for y = ab.y, ae.y do
			callback(vector.new(x, y, ab.z))
			callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x+1, ae.x-1 do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(x, ab.y, z))
			--callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y, ae.y do
		for z = ab.z+1, ae.z-1 do
			callback(vector.new(ab.x, y, z))
			callback(vector.new(ae.x, y, z))
		end
	end
end
local function iterate_area_surface_5(ab, ae, callback)
	for x = ab.x+1, ae.x-1 do
		for y = ab.y+1, ae.y-1 do
			--callback(vector.new(x, y, ab.z))
			callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x, ae.x do
		for z = ab.z, ae.z do
			callback(vector.new(x, ab.y, z))
			callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y+1, ae.y-1 do
		for z = ab.z, ae.z do
			callback(vector.new(ab.x, y, z))
			callback(vector.new(ae.x, y, z))
		end
	end
end
local function iterate_area_surface_6(ab, ae, callback)
	for x = ab.x+1, ae.x-1 do
		for y = ab.y+1, ae.y-1 do
			callback(vector.new(x, y, ab.z))
			--callback(vector.new(x, y, ae.z))
		end
	end
	for x = ab.x, ae.x do
		for z = ab.z, ae.z do
			callback(vector.new(x, ab.y, z))
			callback(vector.new(x, ae.y, z))
		end
	end
	for y = ab.y+1, ae.y-1 do
		for z = ab.z, ae.z do
			callback(vector.new(ab.x, y, z))
			callback(vector.new(ae.x, y, z))
		end
	end
end

function cave_exploring.get_areas(dir, range)
	local area_begin, area_end, iterate
	if dir.x ~= 0 then
		if dir.x > 0 then
			area_begin = vector.new(0, -range, -range)
			area_end = vector.new(range, range, range)
			iterate = iterate_area_surface_1
		else
			area_begin = vector.new(-range, -range, -range)
			area_end = vector.new(0, range, range)
			iterate = iterate_area_surface_2
		end
	elseif dir.y ~= 0 then
		if dir.y > 0 then
			area_begin = vector.new(-range, 0, -range)
			area_end = vector.new(range, range, range)
			iterate = iterate_area_surface_3
		else
			area_begin = vector.new(-range, -range, -range)
			area_end = vector.new(range, 0, range)
			iterate = iterate_area_surface_4
		end
	elseif dir.z ~= 0 then
		if dir.z > 0 then
			area_begin = vector.new(-range, -range, 0)
			area_end = vector.new(range, range, range)
			iterate = iterate_area_surface_5
		else
			area_begin = vector.new(-range, -range, -range)
			area_end = vector.new(range, range, 0)
			iterate = iterate_area_surface_6
		end
	end
	return area_begin, area_end, iterate
end

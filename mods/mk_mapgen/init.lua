minetest.register_node("mk_mapgen:bedrock", {
    description = "bedrock",
    tiles = {"mk_bedrock.png"}
})

minetest.register_node("mk_mapgen:dirt", {
    description = "bedrock",
    tiles = {"mk_dirt.png"},
    groups = {oddly_breakable_by_hand = 3}
})

minetest.register_node("mk_mapgen:dirt_with_grass", {
    description = "bedrock",
    tiles = {"mk_grass.png"},
    groups = {oddly_breakable_by_hand = 3}
})

local layers = {
    [0] = minetest.get_content_id("mk_mapgen:bedrock"),
    [1] = minetest.get_content_id("mk_mapgen:dirt"),
    [2] = minetest.get_content_id("mk_mapgen:dirt"),
    [3] = minetest.get_content_id("mk_mapgen:dirt_with_grass"),
}

local gminy, gmaxy = 0, 0

for key, _ in pairs(layers) do
    if gminy > key then gminy = key end
    if gmaxy < key then gmaxy = key end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
    if minp.y > gmaxy or maxp.y < gminy then return end

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
    local data = vm:get_data()

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if layers[y] then data[vi] = layers[y] end
            end
        end
    end

    vm:set_data(data)
    vm:set_lighting({day = 0, night = 0})
    vm:update_liquids()
    vm:calc_lighting()
    vm:write_to_map(data)
end)
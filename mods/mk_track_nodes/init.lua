minetest.register_node("mk_track_nodes:asphalt", {
    description = "asphalt",
    tiles = {"mk_asphalt.png"},
    groups = {oddly_breakable_by_hand = 3}
})

minetest.register_node("mk_track_nodes:asphalt_with_line", {
    description = "asphalt with line",
    paramtype2 = "facedir",
    tiles = {"mk_asphalt.png^mk_asphalt_line.png"},
    groups = {oddly_breakable_by_hand = 3}
})

minetest.register_node("mk_track_nodes:track_edge", {
    description = "track edge",
    tiles = {"mk_track_edge.png"},
    paramtype = "light",
    paramtype2 = "color",
    --sunlight_propagates = true,
    palette = "mk_palette.png",
    groups = {oddly_breakable_by_hand = 3},
})
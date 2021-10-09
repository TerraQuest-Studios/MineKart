local old_kop = minetest.registered_items["kartcar:kart"].on_place
minetest.override_item("kartcar:kart", {
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
        old_kop(itemstack, placer, pointed_thing)
        return ItemStack("kartcar:kart")
    end
})
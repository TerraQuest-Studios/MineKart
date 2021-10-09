minetest.settings:set_bool("enable_damage", false)

minetest.register_on_newplayer(function(ObjectRef)
    ObjectRef:set_pos(vector.new(0,5,0))
    ObjectRef:override_day_night_ratio(1)
    ObjectRef:hud_set_hotbar_itemcount(1)
    ObjectRef:get_inventory():set_size("main", 1)
    ObjectRef:get_inventory():set_stack("main", 1, "kartcar:kart")
    minetest.chat_send_player(ObjectRef:get_player_name(), "use /gen_map to create a new map")
end)

local function int_to_bool(int)
    if int == 1 then return true else return false end
end

minetest.register_on_joinplayer(function(player, last_login)
    player:override_day_night_ratio(1)
    if player:get_meta():get_int("edit_mode") == 1 then
        player:hud_set_hotbar_itemcount(9)
    else
        player:hud_set_hotbar_itemcount(1)
    end
    player:hud_set_hotbar_image("mk_hotbar.png")
    player:hud_set_hotbar_selected_image("mk_hotbar_selector.png")
    player:hud_set_flags({
        hotbar = int_to_bool(player:get_meta():get_int("edit_mode")),
        --wielditem = int_to_bool(player:get_meta():get_int("edit_mode")),
        healthbar = false,
        breathbar = false,
        minimap_radar = false,
    })

    --legacy version support
    --if player:get_inventory():get_size("main") ~= 32
end)

local old_item_drop = minetest.item_drop

function minetest.item_drop(itemstack, dropper, pos)
    if itemstack:get_name() == "kartcar:kart" then return itemstack end
    return old_item_drop(itemstack, dropper, pos)
end
minetest.settings:set_bool("enable_damage", false)

minetest.register_on_newplayer(function(ObjectRef)
    ObjectRef:set_pos(vector.new(0,5,0))
    ObjectRef:override_day_night_ratio(1)
    --while no menu
    ObjectRef:get_inventory():add_item("main", "kartcar:kart")
    minetest.chat_send_player(ObjectRef:get_player_name(), "use /gen_map to create a new map")
end)

minetest.register_on_joinplayer(function(ObjectRef, last_login)
    ObjectRef:override_day_night_ratio(1)
end)
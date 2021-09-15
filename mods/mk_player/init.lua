minetest.register_on_newplayer(function(ObjectRef)
    ObjectRef:set_pos(vector.new(0,5,0))
    ObjectRef:override_day_night_ratio(1)
end)

minetest.register_on_joinplayer(function(ObjectRef, last_login)
    ObjectRef:override_day_night_ratio(1)
end)
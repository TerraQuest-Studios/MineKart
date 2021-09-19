local modpath = minetest.get_modpath("mk_track_manager")

mk_track_manager = {}

dofile(modpath .. "/core_api.lua")
dofile(modpath .. "/track_gen.lua")
dofile(modpath .. "/mkt_loader.lua")

mk_track_manager.init = true
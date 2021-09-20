--make dir at worldpath
local mkt_dir = minetest.get_worldpath() .. "/mkt"
minetest.mkdir(mkt_dir)

-------------------------
--create demo mtk files--
-------------------------
local mkt_test1 = {
    version = 1,
    size = vector.new(4,2,5),
    data = {
        {"ts",0,0,"ts"},
        {0,{schem = "tcs", rot = 180},{schem = "ts", rot = 90},{schem = "tcs", rot = 270}},
        {"ts","ts",0,"ts"},
        {0,{schem = "tcs", rot = 90},{schem = "ts", rot = 90},"tcs"},
        {"ts",0,0,0},
    }
}
minetest.safe_file_write(mkt_dir .. "/testing_test1.mkt", minetest.write_json(mkt_test1, true))

local mkt_test2 = {
    version = 1,
    size = vector.new(3,2,3),
    data = {
        {{schem = "tcs", rot = 180},{schem = "ts", rot = 90},{schem = "tcs", rot = 270}},
        {"ts",0,"ts"},
        {{schem = "tcs", rot = 90},{schem = "ts", rot = 90},"tcs"},
    }
}
minetest.safe_file_write(mkt_dir .. "/testing_test2.mkt", minetest.write_json(mkt_test2, true))


-----------
--mtk api--
-----------

function mk_track_manager.load_mkt(name)
    --potentially could cache the loaded data into a table,
    --and do a look up for it before loading from file if it exists
    local file = io.open(mkt_dir .. "/" .. name .. ".mkt", "r")
    if not file then return nil end
    local mkt = minetest.parse_json(file:read("*all"))
    file:close()
    return mkt
end

function mk_track_manager.validate_mkt(mkt)
    if not mkt.version or not mkt.size or not mkt.data then return false end
    if #mkt.data ~= mkt.size.z then return false end
    for _, content in pairs(mkt.data) do
        if #content ~= mkt.size.x then return false end
    end
    return true
end

function mk_track_manager.build_mkt(pos1, pos2, mkt)
    if not mk_track_manager.validate_mkt(mkt) then return false end
    local size = vector.subtract(pos2, pos1)
    if mkt.size.x*10 ~= size.x or mkt.size.z*10 ~= size.z then return false end

    local tracks = {}
    tracks.tcs = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_curve.mts"
    tracks.ts = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_straight.mts"
    tracks.tss = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_straight_start.mts"
    local vm = minetest.get_voxel_manip(pos1, pos2)
    vm:read_from_map(pos1, pos2)

    for i=1, mkt.size.z do
        for j=1, mkt.size.x do
            local pos = vector.new(pos1.x+((j-1)*10),3,pos2.z-(i*10))
            if type(mkt.data[i][j]) == "string" then
                minetest.place_schematic_on_vmanip(
                    vm,pos,tracks[mkt.data[i][j]]
                )
            elseif type(mkt.data[i][j]) == "table" then
                minetest.place_schematic_on_vmanip(
                    vm,pos,tracks[mkt.data[i][j]["schem"]], mkt.data[i][j]["rot"]
                )
            end
            --minetest.chat_send_all("i: " .. i .. ", j:" .. j)
        end
    end

    vm:set_lighting({day = 0, night = 0})
    vm:update_liquids()
    vm:calc_lighting()
    vm:write_to_map()

    --minetest.chat_send_all("test")
end

--demo command, for now
local function callback(mkt)
    mk_track_manager.build_mkt(vector.new(0,3,0), vector.new(mkt.size.x*10,5,mkt.size.z*10), mkt)
end

minetest.register_chatcommand("load_mkt", {
    func = function(name, param)
        --currently loading is done only from testing_,
        --in the future, global_ and playername_ will be used
        local fname = "testing_" .. param
        local mkt = mk_track_manager.load_mkt(fname)
        if not mkt then return minetest.chat_send_player(name, "mkt not available") end
        local status = mk_track_manager.validate_mkt(mkt)
        if status == false then return minetest.chat_send_player(name, "not valid mkt") end
        minetest.delete_area(vector.new(0,0,0), vector.new(mkt.size.x*10,5,mkt.size.z*10))
        mk_track_manager.emerge_area(vector.new(0,0,0), vector.new(mkt.size.x*10,5,mkt.size.z*10), callback, mkt)
        --[[
        minetest.after(5, function()
            mk_track_manager.build_mkt(vector.new(0,3,0), vector.new(mkt.size.x*10,5,mkt.size.z*10), mkt)
        end)
        --]]
    end,
})
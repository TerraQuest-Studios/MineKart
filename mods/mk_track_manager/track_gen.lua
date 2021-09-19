--warning this track generation code is absolutely terrible

local function emerge_callback(blockpos, action, calls_remaining, param)
    if not param.total then
        param.total = calls_remaining + 1
        param.current = 0
    end
    param.current = param.current + 1
    if param.total == param.current then
        minetest.chat_send_all("time: " .. ((os.clock() - param.start_time) * 1000))
        param.callback(param.data)
    end
end

local function emerge_area(pos1, pos2, callback, input_data)
    local param = {
        callback = callback,
        start_time = os.clock(),
        data = input_data,
    }
    minetest.emerge_area(pos1, pos2, emerge_callback, param)
end

function generate_map(input)
    minetest.chat_send_all("map generated")
    minetest.chat_send_all(input.i)

    local vm = minetest.get_voxel_manip(vector.new(0,3,0), vector.new(100,4,100))
    vm:read_from_map(vector.new(0,3,0), vector.new(100,4,100))
    local tcs = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_curve.mts"
    local ts = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_straight.mts"
    local tss = minetest.get_modpath("mk_track_manager") .. "/schems/mk_track_straight_start.mts"
    local locations = {
        bl = {math.random(0,3), math.random(0,3)},
        br = {math.random(0,3), math.random(1,3)},
        tl = {math.random(1,3), math.random(1,3)},
        tr = {math.random(1,3), math.random(0,3)},
    }
    --corners
    minetest.place_schematic_on_vmanip(
        vm,vector.new(locations.br[1]*10,3,locations.br[2]*10),tcs, 90
    )
    minetest.place_schematic_on_vmanip(
        vm,vector.new(locations.bl[1]*10,3,100-(locations.bl[2]*10)),tcs,180
    )
    minetest.place_schematic_on_vmanip(
        vm,vector.new(100-(locations.tl[1]*10),3,100-(locations.tl[2]*10)),tcs,270
    )
    minetest.place_schematic_on_vmanip(
        vm,vector.new(100-(locations.tr[1]*10),3,locations.tr[2]*10),tcs,360
    )

    --bottom track
    minetest.place_schematic_on_vmanip(
        vm,vector.new(locations.br[1]*10,3,(locations.br[2]*10)+10),tss
    )
    local rot = {180,0}
    local dist = locations.bl[1]-locations.br[1]

    --straight shot
    if dist == 0 then
        minetest.place_schematic_on_vmanip(
            vm,vector.new(locations.br[1]*10,3,(locations.br[2]*10)+10),tss
        )
        local i = (locations.br[2]*10)+20
        while i < 100-(locations.bl[2]*10) do
            minetest.place_schematic_on_vmanip(
                vm,vector.new(locations.br[1]*10,3,i),ts
            )
            i = i+10
        end
    else
        local x = (locations.br[1]*10)+10
        --move up to line up
        if math.abs(dist) == dist then
            minetest.place_schematic_on_vmanip(
                vm,vector.new(locations.br[1]*10,3,(locations.br[2]*10)+20),tcs, rot[1]
            )
            --no extension
            if dist == 1 then
                minetest.place_schematic_on_vmanip(
                    vm,vector.new((locations.br[1]*10)+10,3,(locations.br[2]*10)+20),tcs, rot[2]
                )
            --needs extending
            else
                local i = (locations.br[1]*10)+10
                while i/10 < locations.bl[1] do
                    minetest.place_schematic_on_vmanip(
                        vm,vector.new(i,3,(locations.br[2]*10)+20),ts, 90
                    )
                    i = i+10
                end
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(i,3,(locations.br[2]*10)+20),tcs, rot[2]
                )
                x = i
            end
        --move down to line up
        else
            rot = {270,90}
            minetest.place_schematic_on_vmanip(
                vm,vector.new(locations.br[1]*10,3,(locations.br[2]*10)+20),tcs, rot[1]
            )
            if math.abs(dist) == 1 then
                minetest.place_schematic_on_vmanip(
                    vm,vector.new((locations.br[1]*10)-10,3,(locations.br[2]*10)+20),tcs, rot[2]
                )
                x = (locations.br[1]*10)-10
            else
                local i = (locations.br[1]*10)-10
                while i/10 > locations.bl[1] do
                    minetest.place_schematic_on_vmanip(
                        vm,vector.new(i,3,(locations.br[2]*10)+20),ts, 90
                    )
                    i = i-10
                end
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(i,3,(locations.br[2]*10)+20),tcs, rot[2]
                )
                x=i
            end
        end
        --connect to corner
        local i = (locations.br[2]*10)+30
        while i < 100-(locations.bl[2]*10) do
            minetest.place_schematic_on_vmanip(
                vm,vector.new(x,3,i),ts
            )
            i = i+10
        end
    end

    --left hand track
    rot = {270,90}
    --dist = locations.tl[1]-locations.bl[1]
    local tl, bl = 100-(locations.tl[2]*10), 100-(locations.bl[2]*10)
    dist = (tl-bl)/10
    local xz = {locations.bl[1]*10,100-(locations.bl[2]*10)}
    minetest.place_schematic_on_vmanip(
        vm,vector.new(xz[1]+10,3,xz[2]),ts, 90
    )
    xz[1] = xz[1]+10
    --minetest.chat_send_all((100-(locations.tl[2]*10)) .. " " .. (100-(locations.bl[2]*10)))
    --minetest.chat_send_all(dist)
    if math.abs(dist) ~= dist and dist ~= 0 then
        xz[1] = xz[1]+10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[2] = xz[2]-10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1],3,xz[2]-10),ts
                )
                xz[2] = xz[2]-10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]-10),tcs, rot[2]
            )
            xz[2] = xz[2]-10
        end
    elseif math.abs(dist) == dist and dist ~= 0 then
        rot = {360,180}
        xz[1] = xz[1]+10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[2] = xz[2]+10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1],3,xz[2]+10),ts
                )
                xz[2] = xz[2]+10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]+10),tcs, rot[2]
            )
            xz[2] = xz[2]+10
        end
    end
    local j = xz[1]+10
    while j < 100-(locations.tl[1]*10) do
        minetest.place_schematic_on_vmanip(
            vm,vector.new(j,3,xz[2]),ts, 90
        )
        j = j+10
    end

    --top
    rot = {90, 270}
    local tr
    tl, tr = 100-(locations.tl[1]*10), 100-(locations.tr[1]*10)
    dist = (tl-tr)/10
    xz = {100-(locations.tl[1]*10),100-(locations.tl[2]*10)}
    minetest.place_schematic_on_vmanip(
        vm,vector.new(xz[1],3,xz[2]-10),ts
    )
    xz[2] = xz[2]-10
    if math.abs(dist) ~= dist and dist ~= 0 then
        xz[2] = xz[2]-10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[1] = xz[1]+10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1]+10,3,xz[2]),ts,90
                )
                xz[1] = xz[1]+10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1]+10,3,xz[2]),tcs, rot[2]
            )
            xz[1] = xz[1]+10
        end
        --]]
    elseif math.abs(dist) == dist and dist ~= 0 then
        rot = {360,180}
        xz[2] = xz[2]-10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[1] = xz[1]-10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1]-10,3,xz[2]),ts,90
                )
                xz[1] = xz[1]-10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1]-10,3,xz[2]),tcs, rot[2]
            )
            xz[1] = xz[1]-10
        end
    end
    j = xz[2]-10
    while j > locations.tr[2]*10 do
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,j),ts
        )
        j = j-10
    end

    --right side
    rot = {90, 270}
    local br
    tr, br = locations.tr[2]*10, locations.br[2]*10
    dist = (tr-br)/10
    xz = {100-(locations.tr[1]*10),locations.tr[2]*10}
    minetest.place_schematic_on_vmanip(
        vm,vector.new(xz[1]-10,3,xz[2]),ts,90
    )
    xz[1] = xz[1]-10
    if math.abs(dist) ~= dist and dist ~= 0 then
        xz[1] = xz[1]-10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[2] = xz[2]+10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1],3,xz[2]+10),ts
                )
                xz[2] = xz[2]+10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]+10),tcs, rot[2]
            )
            xz[2] = xz[2]+10
        end
    elseif math.abs(dist) == dist and dist ~= 0 then
        rot = {180,360}
        xz[1] = xz[1]-10
        minetest.place_schematic_on_vmanip(
            vm,vector.new(xz[1],3,xz[2]),tcs, rot[1]
        )
        if math.abs(dist) == 1 then
            xz[2] = xz[2]-10
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]),tcs, rot[2]
            )
        else
            for i = 1, math.abs(dist)-1 do
                minetest.place_schematic_on_vmanip(
                    vm,vector.new(xz[1],3,xz[2]-10),ts
                )
                xz[2] = xz[2]-10
            end
            minetest.place_schematic_on_vmanip(
                vm,vector.new(xz[1],3,xz[2]-10),tcs, rot[2]
            )
            xz[2] = xz[2]-10
        end
    end
    j = xz[1]-10
    while j > locations.br[1]*10 do
        minetest.place_schematic_on_vmanip(
            vm,vector.new(j,3,xz[2]),ts,90
        )
        j = j-10
    end

    --vm:set_data()
    vm:set_lighting({day = 0, night = 0})
    vm:update_liquids()
    vm:calc_lighting()
    vm:write_to_map()
end

minetest.register_chatcommand("gen_map", {
    --privs = {mk_editor = true},
    --params = "<yes/no>",
    description = "generate new map",
    func = function(name, param)
        minetest.delete_area(vector.new(0,3,0), vector.new(100,4,100))
        emerge_area(vector.new(0,3,0), vector.new(100,4,100), generate_map, {i = "pass through message"})
    end,
})
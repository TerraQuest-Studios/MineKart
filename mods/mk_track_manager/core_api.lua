local function emerge_callback(blockpos, action, calls_remaining, param)
    if not param.total then
        param.total = calls_remaining + 1
        param.current = 0
    end
    param.current = param.current + 1
    if param.total == param.current then
        --minetest.chat_send_all("time: " .. ((os.clock() - param.start_time) * 1000))
        param.callback(param.data)
    end
end

function mk_track_manager.emerge_area(pos1, pos2, callback, input_data)
    local param = {
        callback = callback,
        start_time = os.clock(),
        data = input_data,
    }
    minetest.emerge_area(pos1, pos2, emerge_callback, param)
end
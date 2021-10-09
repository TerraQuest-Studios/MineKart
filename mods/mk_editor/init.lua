minetest.register_privilege("mk_editor", "allows entering edit mode")

minetest.register_item("mk_editor:edit_hand", {
    type = "none",
	wield_scale = {x=1,y=1,z=2.5},
    wield_image = "wieldhand.png",
    range = 12,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			oddly_breakable_by_hand = {times={[1]=0.15,[2]=0.15,[3]=0.15}, uses=0}
		},
		damage_groups = {fleshy=1},
	}
})

minetest.register_chatcommand("edit_mode", {
    privs = {mk_editor = true},
    params = "<yes/no>",
    description = "the flux is out of balance",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then minetest.chat_send_player(name, "[mk_editor]: you are not in game") end

        if minetest.is_yes(param) then
            player:get_meta():set_int("edit_mode", 1)
            player:get_inventory():set_size("main", 9)
            player:hud_set_hotbar_itemcount(9)
            player:get_inventory():set_list("main", {})
            player:hud_set_flags({hotbar = true})
            player:get_inventory():set_size("hand", 1)
            player:get_inventory():set_stack("hand", 1, "mk_editor:edit_hand")
            minetest.chat_send_player(name, "[mk_editor]: edit mode enabled")
        elseif param == "n" or param == "no" then
            player:get_meta():set_int("edit_mode", 0)
            player:hud_set_flags({hotbar = false})
            player:get_inventory():set_size("main", 1)
            player:get_inventory():set_list("main", {ItemStack("kartcar:kart")})
            player:get_inventory():set_size("hand", 0)
            player:hud_set_hotbar_itemcount(1)
            minetest.chat_send_player(name, "[mk_editor]: edit mode disabled")
            return
        else
            minetest.chat_send_player(name, "[mk_editor]: please enter y or n")
        end
    end,
})
local kart_textures = minetest.registered_entities["kartcar:kart"]["initial_properties"].textures
colors = {}

for color, _ in pairs(minekart.colors) do
    table.insert(colors, color)
end

minetest.override_item("kartcar:kart", {
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

        local pointed_pos = pointed_thing.under
		pointed_pos.y=pointed_pos.y+1

		local kart = minetest.add_entity(pointed_pos, "kartcar:kart")
		if kart and placer then
            local ent = kart:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			kart:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
            ent.object:set_acceleration({x=0,y=-minekart.gravity,z=0})

            ent._color = minekart.colors[colors[placer:get_meta():get_int("cart_color")+1]]
            minekart.paint(ent, minekart.colors[colors[placer:get_meta():get_int("cart_color")+1]])
		end

        return ItemStack("kartcar:kart")
    end
})

local function generate_formspec(player)
    local cv = player:get_meta():get_int("inv_cart_color")+1
    --if cv > #colors then
        --cv = 1
        --player:get_meta():set_int("inv_cart_color", 0)
    --end

    local display_color = colors[cv]
    if display_color:find("_") then
        local split = string.split(display_color, "_")
        display_color = table.concat(split, " ")
    end

    local kt = table.copy(kart_textures)
    for index, texture in pairs(kt) do
        if texture:find("kart_painting.png") then
            kt[index] = "kart_painting.png^[multiply:"..minekart.colors[colors[cv]]
        end
    end


    local tr180 = "^[transformR180"
    local formspec = {
        "formspec_version[4]",
        "size[28,15]",
        "no_prepend[]",
        "bgcolor[black;neither]",
        --panel one
        "background[0,0;7,15;[combine:1x1^\\[noalpha\\^[colorize:#00000070;false]",
        "image_button[0.5,1;0.3,0.3;mk_next.png"..tr180..";"..cv.."_cln;;true;false;mk_next_hover.png"..tr180.."]",
        "style_type[label;font_size=20]",
        "label[1.5,1.15;"..display_color.."]",
        "image_button[3.5,1;0.3,0.3;mk_next.png;"..cv.."_crn;;true;false;mk_next_hover.png]",
        "box[4.5,0.9;2,0.5;#808080]",
        "style_type[button;border=false]",
        "button[4.5,0.9;2,0.5;Apply;Apply]",
        --middle
        "background[7,0;14,15;[combine:1x1^\\[noalpha\\^[colorize:#00000010;false]",
        "model[8.5,1.5;10,10;test;kart_body.b3d;"..table.concat(kt, ",")..";-45,135;false;false;1,1]",
        --panel two
        "background[21,0;7,15;[combine:1x1^\\[noalpha\\^[colorize:#00000070;false]",
    }

    return formspec
end

minetest.register_on_joinplayer(function(player, last_login)
    local formspec = generate_formspec(player)
    player:set_inventory_formspec(table.concat(formspec, ""))
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "" then return end

    for key, val in pairs(fields) do
        if key:find("cln") then
            local split = key:split("_")
            local index = tonumber(split[1])
            if index == 1 then
                index = #colors
            else
                index = index-1
            end
            player:get_meta():set_int("inv_cart_color", index-1)
            local formspec = generate_formspec(player)
            minetest.show_formspec(player:get_player_name(), "", table.concat(formspec, ""))
        elseif key:find("crn") then
            local split = key:split("_")
            local index = tonumber(split[1])
            if index == #colors then
                index = 1
            else
                index = index+1
            end
            player:get_meta():set_int("inv_cart_color", index-1)
            local formspec = generate_formspec(player)
            minetest.show_formspec(player:get_player_name(), "", table.concat(formspec, ""))
        elseif key == "Apply" then
            player:get_meta():set_int("cart_color", player:get_meta():get_int("inv_cart_color"))
        end
    end

    --yay, packet spam
    --however as formspecs are strings, need to update as cart changes
    local formspec = generate_formspec(player)
    player:set_inventory_formspec(table.concat(formspec, ""))
end)
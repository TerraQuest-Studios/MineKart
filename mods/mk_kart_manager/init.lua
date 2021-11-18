local function cosmetics(name, def)
    local formspec = {
        type = "container",
        name = name,
        x = def.pos[1],
        y = def.pos[2],
        {
            type = "label",
            label = "comsmetics content",
            x = 1,
            y = 1,
        }
    }

    return formspec
end

local function configuration(name, def)
    local formspec = {
        type = "container",
        name = name,
        x = def.pos[1],
        y = def.pos[2],
        {
            type = "label",
            label = "configuration content",
            x = 1,
            y = 1,
        }
    }

    return formspec
end

local function side_bar(name, def)
    local formspec = {
        type = "container",
        name = name,
        x = def.pos[1],
        y = def.pos[2],
        kuto.component.card("mk_cosmetics", {
            pos = {0.25,0.25},
            icon = "kart_inv.png",
            ttl_name = "mkcm_ttl_name",
            ttl_text = "Kart Cosmetics",
            ctt_name = "mkcm_ctt_name",
            ctt_text = "customize the look and feel of your kart here",
            btn_name = "mkcm_btn_name",
            on_event = function(form, player, element)
                minetest.chat_send_player(player:get_player_name(), minetest.colorize("yellow", "[mk]: cosmetic"))
                local index = kuto.get_index_by_name(form, "mk_content")
                form[index] = cosmetics("mk_content", {pos = {0,0}})

                return form
            end
        }),
        kuto.component.card("mk_configuration", {
            pos = {0.25,2.25},
            icon = "kart_inv.png",
            ttl_name = "mkcf_ttl_name",
            ttl_text = "Kart configuration",
            ctt_name = "mkcf_ctt_name",
            ctt_text = "customize config options",
            btn_name = "mkcf_btn_name",
            on_event = function(form, player, element)
                minetest.chat_send_player(player:get_player_name(), minetest.colorize("yellow", "[mk]: config"))
                local index = kuto.get_index_by_name(form, "mk_content")
                form[index] = configuration("mk_content", {pos = {0,0}})

                return form
            end
        }),
    }

    return formspec
end

local formspec = {
    formspec_version = 4,
    {
        type = "size",
        w = "17",
        h = "12"
    },
    {
        type = "background9",
        x = 0,
        y = 0,
        w = 10,
        h = 12,
        texture_name = "kuto_button.png^[combine:16x16^[noalpha^[colorize:#ffffff50",
        auto_clip = false,
        --middle = "4,4"
        middle_x = 4,
        middle_y = 4,
    },
    {
        type = "background9",
        x = 10.5,
        y = 0,
        w = 6.5,
        h = 12,
        texture_name = "kuto_button.png^[combine:16x16^[noalpha^[colorize:#ffffff50",
        auto_clip = false,
        --middle = "4,4"
        middle_x = 4,
        middle_y = 4,
    },
    side_bar("mk_sidebar", {pos = {10.5, 0}}),
    cosmetics("mk_content", {pos = {0,0}})
}

minetest.register_on_joinplayer(function(player, last_login)
    player:set_inventory_formspec(formspec)
end)
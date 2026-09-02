SMODS.ConsumableType {
    key = 'Mod_Consumable',
    primary_colour = HEX('d90e00'),
    secondary_colour = HEX('ffad66'),
    shop_rate = 0.0
}

SMODS.Consumable {
    key = 'mod_cons',
    set = 'Mod_Consumable',
    pixel_size = { w = 34, h = 34 },
    display_size = { w = 46, h = 46 },
    config = {
        extra = {
            mod_id = nil
        }
    },
    cost = 0,
    discovered = true,
    no_collection = true,
    loc_vars = function(self, info_queue, card) -- Thank you Wilson for this!!
        ensureModDescriptions()
        local id = card.ability.extra.mod_id
        local mod = SMODS.Mods[id]
        if not G.localization.descriptions.SuperRogue_Mod[id] then
            local loc_vars = mod.description_loc_vars and mod:description_loc_vars() or {}
            return {
                key = loc_vars.key or id,
                set = 'Mod',
                vars = loc_vars.vars,
                scale = loc_vars.scale,
                text_colour = loc_vars.text_colour,
                background_colour = loc_vars.background_colour,
                shadow = loc_vars.shadow
            }
        end
        return {
            key = id,
            set = "SuperRogue_Mod"
        }
    end,
    in_pool = function(self, args)
        if SuperRogue.get_total_inactive() > 0 then
            return true, { allow_duplicates = true }
        end
        return false
    end,
    use = function(self, card, area, copier)
        SuperRogue.activate_mod(card.ability.extra.mod_id)
        G.GAME.sr_choice_pool_blacklist = {}
    end,
    can_use = function(self, card)
        return true
    end,
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.extra.mod_id = SuperRogue.get_rand_inactive()
        local mod = SMODS.Mods[card.ability.extra.mod_id]

        SuperRogue.set_modcons_vars(card, mod)
    end
}

SMODS.Atlas {
    key = 'Boosters',
    path = 'Boosters.png',
    px = 71,
    py = 95
}

SMODS.Booster {
    key = 'mod_booster',
    kind = 'Mod_Consumable',
    group_key = 'k_sr_mod_booster',
    atlas = 'Boosters',
    pos = { x = 0, y = 0 },
    pixel_size = { w = 71, h = 77},
    config = {
        extra = 2,
        choose = 1
    },
    cost = 15,
    discovered = true,
    weight = 0.6,
    create_card = function(self, card)
        return SMODS.create_card({ area = G.pack_cards, key = 'c_sr_mod_cons', key_append = "sr_modpack", no_edition = true, skip_materialize = true })
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX('d90e00'))
        ease_background_colour({ new_colour = HEX('ffad66'), special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,
    in_pool = function(self, args)
        if G.GAME.sr_boosters_in_shop and SuperRogue.get_total_inactive() > 1 then
            return true
        end
        return false
    end
}

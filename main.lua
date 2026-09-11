SuperRogue = SMODS.current_mod
SuperRogue_config = SMODS.current_mod.config

assert(SMODS.load_file('src/functions.lua'))()
assert(SMODS.load_file('src/objects.lua'))()
assert(SMODS.load_file('src/overrides.lua'))()
assert(SMODS.load_file('src/ui.lua'))()

--#region Config
SuperRogue.config_tab = function()
    if not G.SUPERROGUE_CONFIG_PAGE then G.SUPERROGUE_CONFIG_PAGE = 1 end
    local config_pages = {}

    config_pages[1] = {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 }, nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.25 },
                nodes = {
                    { n = G.UIT.T, config = { text = localize('b_sr_main_config_options'), scale = 0.75, colour = G.C.UI.TEXT_LIGHT } },
                }
            },

            -- Cycles Row
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    {     -- Iterator Type Cycle
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                label = localize('b_sr_trigger_type'),
                                current_option = SuperRogue_config.trigger_type,
                                options = localize('sr_trigger_type_options'),
                                ref_table = SuperRogue_config,
                                ref_value = 'trigger_type',
                                info = localize('sr_trigger_type_desc'),
                                colour = G.C.RED,
                                opt_callback = 'sr_cycle_update'
                            })
                        }
                    },
                    {     -- Activation Threashold Cycle
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                label = localize('b_sr_activation_threashold'),
                                current_option = SuperRogue_config.activation_threashold,
                                options = { 1, 2, 3, 4, 5, 6, 7, 8 },
                                ref_table = SuperRogue_config,
                                ref_value = 'activation_threashold',
                                info = localize('sr_activation_threashold_desc'),
                                colour = G.C.RED,
                                opt_callback = 'sr_cycle_update'
                            })
                        }
                    },
                    {     -- Activation Mode Cycle
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                label = localize('b_sr_activation_mode'),
                                current_option = SuperRogue_config.activation_mode,
                                options = localize('sr_activation_mode_options'),
                                ref_table = SuperRogue_config,
                                ref_value = 'activation_mode',
                                info = localize('sr_activation_mode_desc'),
                                colour = G.C.RED,
                                opt_callback = 'sr_cycle_update'
                            })
                        }
                    },
                }
            },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    {     -- Pack Size Cycle
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                label = localize('b_sr_pack_size'),
                                current_option = SuperRogue_config.pack_size,
                                options = { 2, 3, 4, 5, 6, 7, 8 },
                                ref_table = SuperRogue_config,
                                ref_value = 'pack_size',
                                info = localize('sr_pack_size_desc'),
                                colour = G.C.RED,
                                opt_callback = 'sr_cycle_update'
                            })
                        }
                    },
                    {     -- Pack Choices Cycle
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                label = localize('b_sr_pack_choices'),
                                current_option = SuperRogue_config.pack_choices,
                                options = { 1, 2, 3, 4, 5, 6, 7, 8 },
                                ref_table = SuperRogue_config,
                                ref_value = 'pack_choices',
                                info = localize('sr_pack_choices_desc'),
                                colour = G.C.RED,
                                opt_callback = 'sr_cycle_update'
                            })
                        }
                    },
                }
            },

            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 }, nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_option_cycle({
                        options = localize('sr_config_pages'),
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback = "sr_set_config_page",
                        current_option = G.SUPERROGUE_CONFIG_PAGE or 1,
                        colour = G.C.GREEN,
                        no_pips = false,
                        focus_args = { snap_to = true, nav = "wide" },
                    }),
                },
            }
        }
    }

    config_pages[2] = {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 },        nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.25 },
                nodes = {
                    { n = G.UIT.T, config = { text = localize('b_sr_vanilla_obj_bl'), scale = 0.75, colour = G.C.UI.TEXT_LIGHT } },
                }
            },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, minh = 0.1 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0, minh = 0.1 },
                        nodes = { {
                            n = G.UIT.R,
                            config = { align = "cl", padding = 0 },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { align = "cl", padding = 0.05 },
                                    nodes = {
                                        create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "jokers" },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { align = "c", padding = 0 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_jokers'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                    }
                                },
                            }
                        }, {
                            n = G.UIT.R,
                            config = { align = "cl", padding = 0 },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { align = "cl", padding = 0.05 },
                                    nodes = {
                                        create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "vouchers" },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { align = "c", padding = 0 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_vouchers'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                    }
                                },
                            }
                        },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "tags" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_tags'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            } },
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0, minh = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "enhancements" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_enhanced_cards'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "editions" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_editions'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "blinds" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_blinds'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "seals" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_seals'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            } },
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cr", padding = 0, minh = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "tarots" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_tarot_cards'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "planets" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_planet_cards'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cl", padding = 0 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cl", padding = 0.05 },
                                        nodes = {
                                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config.vanilla_blacklist, ref_value = "spectrals" },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "c", padding = 0 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('b_spectral_cards'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                                        }
                                    },
                                }
                            } },
                    },
                }
            },

            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 }, nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, minh = 0.1 },
                nodes = {
                    create_option_cycle({
                        options = localize('sr_config_pages'),
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback = "sr_set_config_page",
                        current_option = G.SUPERROGUE_CONFIG_PAGE or 1,
                        colour = G.C.GREEN,
                        no_pips = true,
                        focus_args = { snap_to = true, nav = "wide" },
                    }),
                },
            }
        }
    }

    config_pages[3] = {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 },        nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.25 },
                nodes = {
                    { n = G.UIT.T, config = { text = localize('b_sr_optional_config_options'), scale = 0.75, colour = G.C.UI.TEXT_LIGHT } },
                }
            },

            -- Start with mod toggle
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.05 },
                        nodes = {
                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config, ref_value = "start_with_mod" },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "c", padding = 0 },
                        nodes = {
                            { n = G.UIT.T, config = { text = localize('b_sr_start_with_mod'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                        }
                    },
                }
            },

            -- Boosters in shop toggle
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.05 },
                        nodes = {
                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config, ref_value = "boosters_in_shop" },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "c", padding = 0 },
                        nodes = {
                            { n = G.UIT.T, config = { text = localize('b_sr_boosters_in_shop'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                        }
                    },
                }
            },

            -- Disable Mod toggle
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.05 },
                        nodes = {
                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = SuperRogue_config, ref_value = "disabled" },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "c", padding = 0 },
                        nodes = {
                            { n = G.UIT.T, config = { text = localize('b_sr_disable_mod'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                        }
                    },
                }
            },

            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 }, nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, minh = 0.1 },
                nodes = {
                    create_option_cycle({
                        options = localize('sr_config_pages'),
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback = "sr_set_config_page",
                        current_option = G.SUPERROGUE_CONFIG_PAGE or 1,
                        colour = G.C.GREEN,
                        no_pips = true,
                        focus_args = { snap_to = true, nav = "wide" },
                    }),
                },
            }
        }
    }

    return config_pages[G.SUPERROGUE_CONFIG_PAGE]
end

G.FUNCS.sr_set_config_page = function(args)
    G.SUPERROGUE_CONFIG_PAGE = args.cycle_config.current_option
    G.FUNCS["openModUI_SuperRogue"]()
end

-- Taken from Galdur
G.FUNCS.sr_cycle_update = function(args)
    args = args or {}
    if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
        args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_key
    end
end

-- Blacklist and Starting Mods tabs
SMODS.current_mod.extra_tabs = function()
    return {
        {
            label = localize('b_sr_blacklist'),
            tab_definition_function = function()
                local silent = false
                local keys_used = {}
                local mod_areas = {}
                local mod_tables = {}
                local mod_table_rows = {}
                for k, v in pairs(SuperRogue.content_mods) do
                    if not SuperRogue_config.core_mods[k] then
                        keys_used[k] = k
                    end
                end
                for k, v in pairs(keys_used) do
                    if v then
                        if #mod_areas == 0 then
                            mod_areas[#mod_areas + 1] = CardArea(
                                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                                5.33 * G.CARD_W,
                                0.53 * G.CARD_H,
                                { card_limit = 7, type = 'title_2', highlight_limit = 0 })
                            table.insert(mod_tables,
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = mod_areas[#mod_areas] } }
                                    }
                                }
                            )
                        elseif #mod_areas >= 1 and #mod_areas[#mod_areas].cards == 7 then
                            table.insert(mod_table_rows,
                                { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = mod_tables }
                            )
                            mod_tables = {}
                            mod_areas[#mod_areas + 1] = CardArea(
                                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                                5.33 * G.CARD_W,
                                0.53 * G.CARD_H,
                                { card_limit = 7, type = 'title_2', highlight_limit = 0 })
                            table.insert(mod_tables,
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = mod_areas[#mod_areas] } }
                                    }
                                }
                            )
                        end
                        local center = G.P_CENTERS['c_sr_mod_cons']
                        local card = Card(mod_areas[#mod_areas].T.x + mod_areas[#mod_areas].T.w / 2,
                            mod_areas[#mod_areas].T.y,
                            G.CARD_W, G.CARD_H, nil, center,
                            { bypass_discovery_center = true, bypass_discovery_ui = true, bypass_lock = true })
                        card.ability.extra.mod_id = k
                        card.ability.extra.blacklist_obj = true
                        SuperRogue.set_modcons_vars(card)
                        if SuperRogue_config.activation_blacklist[card.ability.extra.mod_id] then
                            card.debuff = true
                        end
                        card:start_materialize(nil, silent)
                        silent = true
                        mod_areas[#mod_areas]:emplace(card)
                    end
                end
                table.insert(mod_table_rows,
                    { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = mod_tables }
                )

                local t = silent and {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_mods_blacklist') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_crossed_blacklist') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.4 }) } }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm", minh = 0.5 },
                                nodes = {
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05 },
                                nodes = {
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = mod_table_rows },
                                }
                            }
                        }
                    } or
                    {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_no_mods_available') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                                }
                            },
                        }
                    }
                return t
            end
        },
        {
            label = localize('b_sr_starting_mods'),
            tab_definition_function = function()
                local silent = false
                local keys_used = {}
                local mod_areas = {}
                local mod_tables = {}
                local mod_table_rows = {}
                local rand_starting_options = { 0 }
                for k, v in pairs(SuperRogue.content_mods) do
                    if not SuperRogue_config.core_mods[k] then
                        keys_used[k] = k
                        rand_starting_options[#rand_starting_options + 1] = #rand_starting_options
                    end
                end
                for k, v in pairs(keys_used) do
                    if v then
                        if #mod_areas == 0 then
                            mod_areas[#mod_areas + 1] = CardArea(
                                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                                5.33 * G.CARD_W,
                                0.53 * G.CARD_H,
                                { card_limit = 7, type = 'title_2', highlight_limit = 0 })
                            table.insert(mod_tables,
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = mod_areas[#mod_areas] } }
                                    }
                                }
                            )
                        elseif #mod_areas >= 1 and #mod_areas[#mod_areas].cards == 7 then
                            table.insert(mod_table_rows,
                                { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = mod_tables }
                            )
                            mod_tables = {}
                            mod_areas[#mod_areas + 1] = CardArea(
                                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                                5.33 * G.CARD_W,
                                0.53 * G.CARD_H,
                                { card_limit = 7, type = 'title_2', highlight_limit = 0 })
                            table.insert(mod_tables,
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = mod_areas[#mod_areas] } }
                                    }
                                }
                            )
                        end
                        local center = G.P_CENTERS['c_sr_mod_cons']
                        local card = Card(mod_areas[#mod_areas].T.x + mod_areas[#mod_areas].T.w / 2,
                            mod_areas[#mod_areas].T.y,
                            G.CARD_W, G.CARD_H, nil, center,
                            { bypass_discovery_center = true, bypass_discovery_ui = true, bypass_lock = true })
                        card.ability.extra.mod_id = k
                        card.ability.extra.starter_obj = true
                        SuperRogue.set_modcons_vars(card)
                        if not SuperRogue_config.starting_mods[card.ability.extra.mod_id] then
                            card.debuff = true
                        end
                        card:start_materialize(nil, silent)
                        silent = true
                        mod_areas[#mod_areas]:emplace(card)
                    end
                end
                table.insert(mod_table_rows,
                    { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = mod_tables }
                )

                local t = silent and {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_mods_starting') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_crossed_starting') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.4 }) } }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm", minh = 0.5 },
                                nodes = {
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05 },
                                nodes = {
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = mod_table_rows },
                                }
                            },

                            { n = G.UIT.R, config = { minh = 0.04, minw = 3.5, colour = G.C.L_BLACK } },

                            {
                                n = G.UIT.R,
                                config = { align = "cm", padding = 0 },
                                nodes = {
                                    { -- Random Starting Mods cycle
                                        n = G.UIT.C,
                                        config = { align = "cm", padding = 0.1 },
                                        nodes = {
                                            create_option_cycle({
                                                label = localize('b_sr_rand_starting'),
                                                current_option = SuperRogue_config.rand_starting,
                                                options = rand_starting_options,
                                                ref_table = SuperRogue_config,
                                                ref_value = 'rand_starting',
                                                info = localize('sr_rand_starting_desc'),
                                                colour = G.C.RED,
                                                opt_callback = 'sr_cycle_update'
                                            })
                                        }
                                    },
                                }
                            },
                        }
                    } or
                    {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_no_mods_available') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                                }
                            },
                        }
                    }
                return t
            end
        },
    }
end

--#endregion

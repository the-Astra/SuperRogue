-- Prevent specific mod cards from spawning if not active in pool
local gcp = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local _pool, _pool_key = gcp(_type, _rarity, _legendary, _append)
    if G.STAGE == G.STAGES.RUN and SuperRogue_config.disabled then
        local _pool_size = 0
        local pool_copy = SMODS.shallow_copy(_pool)

        for i = 1, #pool_copy do
            if pool_copy[i] ~= 'UNAVAILABLE' then
                local key = pool_copy[i]

                if G.P_CENTERS[key] and not SuperRogue.is_object_mod_active(G.P_CENTERS[key], { type = _type }) then
                    pool_copy[i] = 'UNAVAILABLE'
                elseif G.P_SEALS[key] and not SuperRogue.is_object_mod_active(G.P_SEALS[key], { type = _type }) then
                    pool_copy[i] = 'UNAVAILABLE'
                elseif G.P_TAGS[key] and not SuperRogue.is_object_mod_active(G.P_TAGS[key], { type = _type }) then
                    pool_copy[i] = 'UNAVAILABLE'
                else
                    pool_copy[i] = key
                    _pool_size = _pool_size + 1
                end
            end
        end

        _pool = pool_copy

        --if pool is empty
        if _pool_size == 0 then
            _pool = EMPTY(G.ARGS.TEMP_POOL)
            if SMODS.ObjectTypes[_type] and SMODS.ObjectTypes[_type].default and G.P_CENTERS[SMODS.ObjectTypes[_type].default] then
                if SuperRogue.is_object_mod_active(SMODS.ObjectTypes[_type]) then
                    _pool[#_pool + 1] = SMODS.ObjectTypes[_type].default
                end
            elseif _type == 'Tarot' or _type == 'Tarot_Planet' then
                _pool[#_pool + 1] = "c_strength"
            elseif _type == 'Planet' then
                _pool[#_pool + 1] = "c_pluto"
            elseif _type == 'Spectral' then
                _pool[#_pool + 1] = "c_incantation"
            elseif _type == 'Joker' then
                _pool[#_pool + 1] = "j_joker"
            elseif _type == 'Demo' then
                _pool[#_pool + 1] = "j_joker"
            elseif _type == 'Voucher' then
                _pool[#_pool + 1] = "v_blank"
            elseif _type == 'Tag' then
                _pool[#_pool + 1] = "tag_handy"
            elseif _type == 'Edition' then
                _pool[#_pool + 1] = "e_foil"
            elseif _type == 'Seal' then
                _pool[#_pool + 1] = "Purple"
            else
                _pool[#_pool + 1] = "j_joker"
            end
        end
    end
    return _pool, _pool_key
end

-- Use this in tandem with gcp
local add_to_pool_ref = SMODS.add_to_pool
function SMODS.add_to_pool(prototype_obj, args)
    local ret = add_to_pool_ref(prototype_obj, args)
    if ret and not SuperRogue.is_object_mod_active(prototype_obj, {type = prototype_obj.set}) and SuperRogue_config.disabled then
        ret = false
    end
    return ret
end

-- Init SuperRogue game objects
local igo = Game.init_game_object
Game.init_game_object = function(self)
    local ret = igo(self)

    if SuperRogue_config.disabled then return ret end

    SuperRogue.content_mods = {}

    -- Check for content mods
    for k, v in pairs(SMODS.Mods) do
        if SuperRogue.does_mod_have_content(v.id) and not SuperRogue_config.core_mods[v.id] and not v.disabled and v.can_load then
            SuperRogue.content_mods[v.id] = true
        end
    end

    ret.sr_active_mod_pool = {}
    -- Force core mods into mod pool
    for k, _ in pairs(SuperRogue_config.core_mods) do
        ret.sr_active_mod_pool[k] = true
    end

    -- Load Mod Pool
    for k, v in pairs(SuperRogue.content_mods) do
        local blacklisted = SuperRogue_config.activation_blacklist[k]
        if not blacklisted and v then
            if SuperRogue_config.starting_mods[k] then
                ret.sr_active_mod_pool[k] = true
            else
                ret.sr_active_mod_pool[k] = false
            end
        end
    end

    if SuperRogue_config.rand_starting - 1 > 0 then
        for i = 1, SuperRogue_config.rand_starting - 1 do
            local valid_mods = {}
            for k, v in pairs(ret.sr_active_mod_pool) do
                if not v then
                    valid_mods[#valid_mods + 1] = k
                end
            end
            if next(valid_mods) then
                ret.sr_active_mod_pool[pseudorandom_element(valid_mods)] = true
            end
        end
    end

    ret.sr_iteration_steps = 0
    ret.sr_activation_threashold = SuperRogue_config.activation_threashold
    ret.sr_activation_mode = SuperRogue_config.activation_mode
    ret.sr_trigger_type = SuperRogue_config.trigger_type
    ret.sr_choice_pool_blacklist = {}
    ret.sr_boosters_in_shop = SuperRogue_config.boosters_in_shop
    ret.sr_vanilla_blacklist = SuperRogue_config.vanilla_blacklist

    G.P_CENTERS['p_sr_mod_booster'].config.extra = SuperRogue_config.pack_size + 1 -- jank lol
    G.P_CENTERS['p_sr_mod_booster'].config.choose = math.min(SuperRogue_config.pack_choices, SuperRogue_config.pack_size + 1)

    return ret
end

-- Setup values on run start
local atr = Back.apply_to_run
Back.apply_to_run = function(self)
    atr(self)

    if SuperRogue_config.disabled then return end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        func = function()
            -- Start run by activating mod if option is active
            if SuperRogue_config.start_with_mod and SuperRogue.get_total_inactive() > 0 then
                if G.GAME.sr_activation_mode == 1 then
                    SuperRogue.activate_mod(SuperRogue.get_rand_inactive())
                else
                    if SuperRogue.get_total_inactive() > 1 then
                        G.CONTROLLER.locks.use = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            func = function()
                                if G.STATE_COMPLETE then
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            if G.blind_select and not G.blind_select.alignment.offset.py then
                                                G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                                                G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
                                            end
                                            return true;
                                        end
                                    }))
                                    local card = Card(G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
                                        G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2, G.CARD_W * 1.27,
                                        G.CARD_H * 1.27,
                                        G.P_CARDS.empty,
                                        G.P_CENTERS["p_sr_mod_booster"],
                                        { bypass_discovery_center = true, bypass_discovery_ui = true })
                                    card.cost = 0
                                    G.FUNCS.use_card({ config = { ref_table = card } })
                                    card:start_materialize()
                                    G.CONTROLLER.locks.use = nil
                                    return true
                                end
                                return true;
                            end
                        }))
                    else
                        SuperRogue.activate_mod(SuperRogue.get_rand_inactive())
                    end
                end
            end
            return true;
        end
    }))
end

-- Spawn Mod Booster if threashold is met when entering shop
local update_shopref = Game.update_shop
function Game.update_shop(self, dt)
    update_shopref(self, dt)
    if SuperRogue_config.disabled then return end
    if (G.GAME.sr_iteration_steps >= G.GAME.sr_activation_threashold) and G.GAME.sr_activation_mode == 2 then
        G.GAME.sr_iteration_steps = 0

        if SuperRogue.get_total_inactive() > 1 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    if G.STATE_COMPLETE then
                        local card = Card(G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
                            G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2, G.CARD_W * 1.27, G.CARD_H * 1.27,
                            G.P_CARDS.empty,
                            G.P_CENTERS["p_sr_mod_booster"],
                            { bypass_discovery_center = true, bypass_discovery_ui = true })
                        card.cost = 0
                        G.FUNCS.use_card({ config = { ref_table = card } })
                        card:start_materialize()
                        return true
                    end
                end
            }))
        else
            SuperRogue.activate_mod(SuperRogue.get_rand_inactive())
        end
    end
end

-- Change mod consumable behavior in run info ui
local cc = Card.click
function Card:click()
    cc(self)

    if self.config.center_key == 'c_sr_mod_cons' then
        if self.ability.extra.run_info_obj then
            play_sound('button', 1, 0.3)
            G.FUNCS['openModUI_' .. self.ability.extra.mod_id]()
        elseif self.ability.extra.blacklist_obj then
            play_sound('button', 1, 0.3)
            if SuperRogue_config.activation_blacklist[self.ability.extra.mod_id] then
                SuperRogue_config.activation_blacklist[self.ability.extra.mod_id] = nil
                self.debuff = false
            else
                SuperRogue_config.activation_blacklist[self.ability.extra.mod_id] = true
                self.debuff = true
                if SuperRogue_config.starting_mods[self.ability.extra.mod_id] then
                    SuperRogue_config.starting_mods[self.ability.extra.mod_id] = nil
                end
            end
        elseif self.ability.extra.starter_obj then
            play_sound('button', 1, 0.3)
            if SuperRogue_config.starting_mods[self.ability.extra.mod_id] then
                SuperRogue_config.starting_mods[self.ability.extra.mod_id] = nil
                self.debuff = true
            else
                SuperRogue_config.starting_mods[self.ability.extra.mod_id] = true
                self.debuff = false
                if SuperRogue_config.activation_blacklist[self.ability.extra.mod_id] then
                    SuperRogue_config.activation_blacklist[self.ability.extra.mod_id] = nil
                end
            end
        end
    end
end

-- Prevent packs from inactive mods from opening
local gfuc = G.FUNCS.use_card
function G.FUNCS.use_card(e, mute, nosave)
    local obj = e.config.ref_table
    if obj.ability.set == 'Booster' and not SuperRogue.is_object_mod_active(obj.config.center) then
        SMODS.calculate_effect(
            {
                message = localize('k_sr_mod_not_active_ex'),
                colour = G.C.FILTER,
                sound = 'tarot2'
            }, obj
        )
        G.E_MANAGER:add_event(Event({
            func = function()
                obj:start_dissolve()
                return true;
            end
        }))
    else
        gfuc(e, mute, nosave)
    end
end

-- Open mod menu on right click
local controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    controller_queue_R_cursor_press_ref(self, x, y)
    local press_node = self.hovering.target or self.focused.target
    if press_node and press_node:is(Card) and press_node.ability.extra and press_node.ability.extra.mod_id then
        play_sound('button', 1, 0.3)
        SuperRogue.last_selected_tab = SMODS.LAST_SELECTED_MOD_TAB
        SMODS.LAST_SELECTED_MOD_TAB = "additions"
        G.FUNCS['openModUI_' .. press_node.ability.extra.mod_id]()
        G.OVERLAY_MENU:get_UIE_by_ID("overlay_menu_back_button").config.button = "exit_overlay_menu_SuperRogue"
    end
end

G.FUNCS.exit_overlay_menu_SuperRogue = function()
    if SuperRogue.last_selected_tab then
        SMODS.LAST_SELECTED_MOD_TAB = SuperRogue.last_selected_tab
        G.FUNCS['openModUI_SuperRogue']()
        SuperRogue.last_selected_tab = nil
    else
        G.ACTIVE_MOD_UI = nil
        G.FUNCS.exit_overlay_menu()
        SMODS.LAST_SELECTED_MOD_TAB = nil
    end
end

-- Handle stickers
local smods_sticker_ref = SMODS.Sticker.should_apply
SMODS.Sticker.should_apply = function(self, card, center, area, bypass_roll)
    if not SuperRogue.is_object_mod_active(self) then return false end
    return smods_sticker_ref(self, card, center, area, bypass_roll)
end

local main_menu_ref = Game.main_menu
function Game:main_menu(change_context)
    local ret = main_menu_ref(self, change_context)

    local SC_scale = 1.2 * (G.debug_splash_size_toggle and 0.8 or 1)
    G.SPLASH_SUPERROGUE_LOGO = Sprite(0, 0,
        1 * SC_scale,
        1 * SC_scale * (G.ASSET_ATLAS["sr_modicon"].py / G.ASSET_ATLAS["sr_modicon"].px),
        G.ASSET_ATLAS["sr_modicon"], { x = 0, y = 0 }
    )
    G.SPLASH_SUPERROGUE_LOGO:set_alignment({
        major = G.SPLASH_LOGO,
        type = 'tr',
        bond = 'Strong',
        offset = { x = -0.9, y = 3 }
    })
    G.SPLASH_SUPERROGUE_LOGO:define_draw_steps({ {
        shader = 'dissolve',
    } })

    -- Define badge properties
    G.SPLASH_SUPERROGUE_LOGO.tilt_var = { mx = 0, my = 0, dx = 0, dy = 0, amt = 0 }

    G.SPLASH_SUPERROGUE_LOGO.dissolve_colours = { HEX("ffad66"), HEX("d90e00") }
    G.SPLASH_SUPERROGUE_LOGO.dissolve = 1

    G.SPLASH_SUPERROGUE_LOGO.states.collide.can = true

    -- Define node functions for SuperRogue badge
    function G.SPLASH_SUPERROGUE_LOGO:click()
        play_sound('button', 1, 0.3)
        SMODS.LAST_SELECTED_MOD_TAB = nil
        G.FUNCS['openModUI_SuperRogue']()
        G.OVERLAY_MENU:get_UIE_by_ID("overlay_menu_back_button").config.button = "exit_overlay_menu_sr_menu"
    end

    G.FUNCS.exit_overlay_menu_sr_menu = function()
        G.ACTIVE_MOD_UI = nil
        G.FUNCS.exit_overlay_menu()
    end

    function G.SPLASH_SUPERROGUE_LOGO:hover()
        G.SPLASH_SUPERROGUE_LOGO:juice_up(0.05, 0.03)
        play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
        Node.hover(self)
    end

    function G.SPLASH_SUPERROGUE_LOGO:stop_hover() Node.stop_hover(self) end

    --Badge animation
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = change_context == 'splash' and 1.8 or change_context == 'game' and 2 or 1,
        blockable = false,
        blocking = false,
        func = (function()
            ease_value(G.SPLASH_SUPERROGUE_LOGO, 'dissolve', -1, nil, nil, nil, change_context == 'splash' and 2.3 or 0.9)
            G.VIBRATION = G.VIBRATION + 1.5
            return true
        end)
    }))

    if not SuperRogue_config.first_startup then -- Attach to config instead of profile because per-profile feels less right
        SuperRogue_config.first_startup = true

        local nodes = {}
        nodes[#nodes + 1] = {}
        local loc_vars = {
            background_colour = G.C.CLEAR,
            text_colour = G.C.WHITE,
            scale = 1.4,
            vars = {
                elements = {
                    SMODS.create_sprite(0, 0, 1, 1 * (G.ASSET_ATLAS["sr_modicon"].py / G.ASSET_ATLAS["sr_modicon"].px),
                        "sr_modicon", { x = 0, y = 0 }),
                }
            }
        }

        localize { type = 'descriptions', key = 'sr_recommendation', set = 'Other', nodes = nodes[#nodes], vars = loc_vars.vars, text_colour = loc_vars.text_colour, shadow = loc_vars.shadow }
        nodes[#nodes] = desc_from_rows(nodes[#nodes])
        nodes[#nodes].config.colour = loc_vars.background_colour or nodes[#nodes].config.colour

        G.FUNCS.overlay_menu {
            definition = {
                n = G.UIT.ROOT, config = { align = "cm", minw = G.ROOM.T.w * 5, minh = G.ROOM.T.h * 5, padding = 0.1, r = 0.1, colour = { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.7 } }, nodes = {
                { n = G.UIT.R, config = { r = 0.1, colour = G.C.JOKER_GREY, padding = 0.05, align = "cm" }, nodes = {
                    { n = G.UIT.C, config = { colour = G.C.L_BLACK, r = 0.1, padding = 0.2, align = "cm" }, nodes = {
                        { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = nodes },
                        { n = G.UIT.R, config = { id = "overlay_menu_back_button", align = "cm", minw = 2.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.ORANGE, button = "exit_overlay_menu", shadow = true, focus_args = { nav = "wide", button = "b" } }, nodes = {
                            { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = {
                                { n = G.UIT.T, config = { text = localize("k_sr_okay"), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
                            } },
                        } },
                    } },
                } },
            } }
        }
    end

    return ret
end

--#region Compat

if Giga then
    local giga_astra_roll_ref = Giga.astral_roll
    function Giga.astral_roll()
        if not G.GAME.sr_active_mod_pool['GIGA'] then return false end
        return giga_astra_roll_ref()
    end
end

--#endregion

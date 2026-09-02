-- Prevent specific mod cards from spawning if not active in pool
local gcp = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local _pool, _pool_key = gcp(_type, _rarity, _legendary, _append)
    local _pool_size = 0

    for i = 1, #_pool do
        if _pool[i] ~= 'UNAVAILABLE' then
            local key = _pool[i]

            if G.P_CENTERS[key] and not SuperRogue.is_object_mod_active(G.P_CENTERS[key], {type = _type}) then
                _pool[i] = 'UNAVAILABLE'
            elseif G.P_SEALS[key] and not SuperRogue.is_object_mod_active(G.P_SEALS[key], {type = _type}) then
                _pool[i] = 'UNAVAILABLE'
            elseif G.P_TAGS[key] and not SuperRogue.is_object_mod_active(G.P_TAGS[key], {type = _type}) then
                _pool[i] = 'UNAVAILABLE'
            else
                _pool_size = _pool_size + 1
            end
        end
    end

    --if pool is empty
    if _pool_size == 0 then
        _pool = EMPTY(G.ARGS.TEMP_POOL)
        if SMODS.ObjectTypes[_type] and SMODS.ObjectTypes[_type].default and G.P_CENTERS[SMODS.ObjectTypes[_type].default] then
            if SuperRogue.is_object_mod_active(SMODS.ObjectTypes[_type]) then
                _pool[#_pool+1] = SMODS.ObjectTypes[_type].default
            end
        elseif _type == 'Tarot' or _type == 'Tarot_Planet' then _pool[#_pool + 1] = "c_strength"
        elseif _type == 'Planet' then _pool[#_pool + 1] = "c_pluto"
        elseif _type == 'Spectral' then _pool[#_pool + 1] = "c_incantation"
        elseif _type == 'Joker' then _pool[#_pool + 1] = "j_joker"
        elseif _type == 'Demo' then _pool[#_pool + 1] = "j_joker"
        elseif _type == 'Voucher' then _pool[#_pool + 1] = "v_blank"
        elseif _type == 'Tag' then _pool[#_pool + 1] = "tag_handy"
        elseif _type == 'Edition' then _pool[#_pool + 1] = "e_foil"
        elseif _type == 'Seal' then _pool[#_pool + 1] = "Purple"
        else _pool[#_pool + 1] = "j_joker"
        end
    end

    return _pool, _pool_key
end

-- Init SuperRogue game objects
local igo = Game.init_game_object
Game.init_game_object = function(self)
    local ret = igo(self)

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
    G.P_CENTERS['p_sr_mod_booster'].config.choose = SuperRogue_config.pack_choices

    return ret
end

-- Setup values on run start
local atr = Back.apply_to_run
Back.apply_to_run = function(self)
    atr(self)

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

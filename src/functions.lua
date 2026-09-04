-- Global calculate for activating mods whenever a threashold is met
SuperRogue.calculate = function(self, context)
    if G.GAME.sr_trigger_type == 1 and context.ante_change and context.ante_end
        or G.GAME.sr_trigger_type == 2 and context.end_of_round and not context.repetition and not context.individual then
        G.GAME.sr_iteration_steps = G.GAME.sr_iteration_steps + 1
        if G.GAME.sr_iteration_steps >= G.GAME.sr_activation_threashold and G.GAME.sr_activation_mode == 1 then
            SuperRogue.activate_mod(SuperRogue.get_rand_inactive())
            G.GAME.sr_iteration_steps = 0
        end
    end

    if context.skipping_booster then
        G.GAME.sr_choice_pool_blacklist = {}
    end
end

-- Helper function to get a random inactive mod
function SuperRogue.get_rand_inactive()
    local inactive_pool = {}
    for k, v in pairs(G.GAME.sr_active_mod_pool) do
        if not v and not G.GAME.sr_choice_pool_blacklist[k] then
            inactive_pool[#inactive_pool + 1] = k
        end
    end
    if next(inactive_pool) then
        local key = pseudorandom_element(inactive_pool, pseudoseed('SRRandom'))
        if G.GAME.sr_activation_mode == 2 then
            G.GAME.sr_choice_pool_blacklist[key] = key
        end
        return key
    elseif next(G.GAME.sr_choice_pool_blacklist) then
        return pseudorandom_element(G.GAME.sr_choice_pool_blacklist, pseudoseed('SRRandom'))
    else
        return nil
    end
end

-- Helper function to activate mod
function SuperRogue.activate_mod(key, silent)
    if key and G.GAME.sr_active_mod_pool[key] ~= nil then
        G.GAME.sr_active_mod_pool[key] = true
        if not silent then
            local disp_text = (SMODS.Mods[key].name) .. localize('k_sr_activation')
            local hold_time = G.SETTINGS.GAMESPEED * (#disp_text * 0.035 + 1.3)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blockable = false,
                func = function()
                    play_sound('whoosh1', 0.55, 0.62)
                    attention_text({
                        scale = 0.7,
                        text = disp_text,
                        maxw = 12,
                        hold = hold_time,
                        align = 'cm',
                        offset = { x = 0, y = -1 },
                        major = G.play
                    })
                    return true;
                end
            }))
        end
    end
end

-- Helper function to set Mod Consumable attributes
function SuperRogue.set_modcons_vars(card, mod)
    if not mod then
        mod = SMODS.Mods[card.ability.extra.mod_id]
        if not mod then return end
    end
    card.children.center.atlas = mod.prefix and G.ASSET_ATLAS[mod.prefix .. '_modicon'] or G.ASSET_ATLAS['modicon'] or
        G.ASSET_ATLAS['tags']
    card.children.center:set_sprite_pos({ x = 0, y = 0 })
end

--Helper function to get number of inactive mods
function SuperRogue.get_total_inactive()
    local inactive_mods = 0
    for k, v in pairs(G.GAME.sr_active_mod_pool) do
        if not v then
            inactive_mods = inactive_mods + 1
        end
    end
    return inactive_mods
end

--Helper function to check if an object pool has any available objects
function SuperRogue.is_pool_available(_type)
    local available_type = false
    local _type_pool = get_current_pool(_type)
    for i = 1, #_type_pool do
        if _type_pool[i] ~= 'UNAVAILABLE' then
            available_type = true
            break
        end
    end
    return available_type
end

--Helper function to check if an object's mod is active (makes conditionals more concise)
function SuperRogue.is_object_mod_active(obj_prototype, args)
    if obj_prototype.original_mod then
        return G.GAME.sr_active_mod_pool[obj_prototype.original_mod.id]
    else
        if args and args.type then
            if args.type == 'Joker' and G.GAME.sr_vanilla_blacklist.jokers then
                return false
            end
            if args.type == 'Voucher' and G.GAME.sr_vanilla_blacklist.vouchers then
                return false
            end
            if args.type == 'Planet' and G.GAME.sr_vanilla_blacklist.planets then
                return false
            end
            if args.type == 'Tarot' and G.GAME.sr_vanilla_blacklist.tarots then
                return false
            end
            if args.type == 'Spectral' and G.GAME.sr_vanilla_blacklist.spectrals then
                return false
            end
            if args.type == 'Booster' then
                if obj_prototype.kind == 'Celestial' then
                    return SuperRogue.is_pool_available('Planet')
                elseif obj_prototype.kind == 'Arcana' then
                    return SuperRogue.is_pool_available('Tarot')
                elseif obj_prototype.kind == 'Spectral' then
                    return SuperRogue.is_pool_available('Spectral')
                elseif obj_prototype.kind == 'Buffoon' then
                    return SuperRogue.is_pool_available('Joker')
                end
                return false
            end
            if args.type == 'Enhanced' and G.GAME.sr_vanilla_blacklist.enhancements then
                return false
            end
            if args.type == 'Edition' and G.GAME.sr_vanilla_blacklist.editions then
                return false
            end
            if args.type == 'Tag' and G.GAME.sr_vanilla_blacklist.tags then
                return false
            end
            if args.type == 'Seal' and G.GAME.sr_vanilla_blacklist.seals then
                return false
            end
            if args.type == 'Boss' and G.GAME.sr_vanilla_blacklist.blinds then
                return false
            end
        end

        return true
    end
end

--Helper function to check if a mod has tangible content
function SuperRogue.does_mod_have_content(id)
    local pool_blacklist = {
        ['Sleeve'] = true,
        ['Back'] = true
    }

    for pool, _ in pairs(G.P_CENTER_POOLS) do
        if not pool_blacklist[pool] then
            for _, v in pairs(G.P_CENTER_POOLS[pool]) do
                if v.mod and v.mod.id == id and not v.no_collection then
                    return true
                end
            end
        end
    end

    for _, v in pairs(G.P_TAGS) do
        if v.mod and v.mod.id == id and not v.no_collection then
            return true
        end
    end

    for _, v in pairs(G.P_BLINDS) do
        if v.mod and v.mod.id == id and not v.no_collection then
            return true
        end
    end

    return false
end

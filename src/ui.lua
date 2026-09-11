-- Stolen from SMODS
function wrapText(text, maxChars)
    local wrappedText = { "" }
    local curr_line = 1
    local currentLineLength = 0

    for word in text:gmatch("%S+") do
        if currentLineLength + #word <= maxChars then
            wrappedText[curr_line] = wrappedText[curr_line] .. word .. ' '
            currentLineLength = currentLineLength + #word + 1
        else
            wrappedText[curr_line] = string.sub(wrappedText[curr_line], 0, -2)
            curr_line = curr_line + 1
            wrappedText[curr_line] = ""
            wrappedText[curr_line] = wrappedText[curr_line] .. word .. ' '
            currentLineLength = #word + 1
        end
    end

    wrappedText[curr_line] = string.sub(wrappedText[curr_line], 0, -2)
    return wrappedText
end

function ensureModDescriptions()
    if G.localization.descriptions.SuperRogue_Mod then return end
    local sr_mod = {}
    G.localization.descriptions.SuperRogue_Mod = sr_mod
    local mod = G.localization.descriptions.Mod or {}
    for k, v in pairs(SMODS.Mods) do
        if not mod[k] then
            sr_mod[k] = {
                name = v.name,
                text = wrapText(v.description or '', 30)
            }
        end
    end
    init_localization()
end

-- Create Run Info Mods tab
function G.UIDEF.sr_activated_mods()
    local silent = false
    local keys_used = {}
    local mod_areas = {}
    local mod_tables = {}
    local mod_table_rows = {}
    for k, v in pairs(G.GAME.sr_active_mod_pool) do
        if not SuperRogue_config.core_mods[k] then
            keys_used[k] = G.GAME.sr_active_mod_pool[k]
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
            local card = Card(mod_areas[#mod_areas].T.x + mod_areas[#mod_areas].T.w / 2, mod_areas[#mod_areas].T.y,
                G.CARD_W, G.CARD_H, nil, center,
                { bypass_discovery_center = true, bypass_discovery_ui = true, bypass_lock = true })
            card.ability.extra.mod_id = k
            card.ability.extra.run_info_obj = true
            SuperRogue.set_modcons_vars(card)
            card:start_materialize(nil, silent)
            silent = true
            mod_areas[#mod_areas]:emplace(card)
        end
    end
    table.insert(mod_table_rows,
        { n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = mod_tables }
    )

    local tracking_string = localize('ph_sr_no_mods_left')
    local steps_to_activation = G.GAME.sr_activation_threashold - G.GAME.sr_iteration_steps
    if SuperRogue.get_total_inactive() == 0 then
        -- Don't change the tracking string
    elseif G.GAME.sr_trigger_type == 1 then
        tracking_string = localize{type = 'variable', key = 'k_sr_antes_until_next_mod', vars = {steps_to_activation}}
    elseif G.GAME.sr_trigger_type == 2 then
        tracking_string = localize{type = 'variable', key = 'k_sr_rounds_until_next_mod', vars = {steps_to_activation}}
    end

    local t = silent and {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_mods_activated') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = { tracking_string }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.4 }) } }
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
                        { n = G.UIT.O, config = { object = DynaText({ string = { localize('ph_sr_no_mods_run') }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.6 }) } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = { tracking_string }, colours = { G.C.UI.TEXT_LIGHT }, bump = true, scale = 0.4 }) } }
                    }
                },
            }
        }
    return t
end
return {
    descriptions = {
        Other = {
            p_sr_mod_booster = {
                name = 'Mod Pack',
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2# {C:mod_consumable}Mods{} to",
                    "be activated immediately",
                },
            },
            sr_recommendation = {
                text = {
                    '{s:1.4,u:white}Welcome to {s:1.4,u:white,C:gold}SuperRogue{} {element:1} {}',
                    '{s:0.4} {}',
                    "This seems like your first time playing",
                    "{C:gold}SuperRogue{} (or you recently updated),",
                    "here's a couple tips!",
                    " ",
                    "You can right click any {C:mod_consumable}Mod Tag Object{} to open",
                    "the associated mod's menu, allowing easy",
                    "viewing of a mod's content",
                    " ",
                    "Don't forget to check out {C:gold}SuperRogue's{} config",
                    "menu to fine tune the experience to your",
                    "liking. There's {C:attention}loads{} of options to choose!",
                    " ",
                    "Any quesitons? DM me on discord {C:blue,u:blue}@theastra_{}",
                    "or ask in the {C:gold}SuperRogue{} thread in the Balatro Discord",
                    " ",
                    "Hope this helps, and enjoy!",
                    "{C:dark_edition,s:1.4}~ Astra {C:dark_edition,f:8,s:1.4}🪐"
                }
            }
        }
    },
    misc = {
        dictionary = {
            b_sr_activation_mode = 'Mod Activation Mode',
            b_sr_activation_threashold = 'Trigger Count',
            b_sr_blacklist = 'Mod Blacklist',
            b_sr_boosters_in_shop = 'Allow Mod Packs to appear in shops',
            b_sr_mods = 'Mods',
            b_sr_start_with_mod = 'Start run with a mod being activated through chosen mode',
            b_sr_starting_mods = 'Starting Mods',
            b_sr_trigger_type = 'Trigger Type',
            b_sr_main_config_options = 'Main Config Options',
            b_sr_optional_config_options = 'Optional Config Options',
            b_sr_pack_size = 'Pack Size',
            b_sr_pack_choices = 'Pack Choices',
            b_sr_rand_starting = 'Random Starting Mods',
            b_sr_vanilla_obj_bl = 'Vanilla Object Blacklist',
            b_sr_disable_mod = 'Disable SuperRogue',

            k_mod_consumable = 'Mod',
            k_sr_activation = ' has been activated!',
            k_sr_mod_booster = 'Choose Your Mod',
            k_sr_mod_not_active_ex = 'Mod Not Active!',
            k_sr_okay = 'Okay!',

            ph_sr_crossed_blacklist = '(Crossed out mods will not appear in run)',
            ph_sr_crossed_starting = '(Crossed out mods will not be active at start)',
            ph_sr_mods_activated = 'Mods activated this run',
            ph_sr_mods_blacklist = 'Mod Blacklist',
            ph_sr_mods_starting = 'Mods Active at Start',
            ph_sr_no_mods_available = 'No mods available to use with SuperRogue',
            ph_sr_no_mods_left = 'No mods left to activate',
            ph_sr_no_mods_run = 'No mods activated this run',


            sr_activation_mode_desc = {
                "Choose what method of mod",
                "activation should be used"
            },
            sr_activation_threashold_desc = {
                "Choose how many triggers must",
                "pass for a mod to activate"
            },
            sr_trigger_type_desc = {
                "Choose what trigger to",
                "use for mod activation"
            },

            sr_pack_size_desc = {
                "Choose how many mods can",
                "appear in a Mod Pack"
            },
            sr_pack_choices_desc = {
                "Choose how many mods can",
                "be activated in a Mod Pack"
            },
            sr_rand_starting_desc = {
                "The number of mods that will be randomly",
                "active at the start of a run",
            },


            sr_activation_mode_options = {
                "Random",
                "Choose"
            },
            sr_trigger_type_options = {
                "Ante",
                "Round"
            },
            sr_config_pages = {
                "Page 1/3",
                "Page 2/3",
                "Page 3/3"
            },

        },
        v_dictionary = {
            k_sr_antes_until_next_mod = 'Antes until next mod: #1#',
            k_sr_rounds_until_next_mod = 'Rounds until next mod: #1#',
        }
    }
}

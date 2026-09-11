return {
    start_with_mod = false,
    boosters_in_shop = false,
    trigger_type = 1,
    activation_threashold = 1,
    activation_mode = 1,
    starting_mods = {},
    rand_starting = 0,
    activation_blacklist = {},
    pack_size = 2,
    pack_choices = 1,
    disabled = false,
    vanilla_blacklist =  {
        jokers = false,
        vouchers = false,
        tarots = false,
        planets = false,
        spectrals = false,
        enhancements = false,
        seals = false,
        editions = false,
        tags = false,
        blinds = false
    },
    core_mods = { -- DO NOT TOUCH THIS UNLESS YOU ABSOLUTELY KNOW WHAT YOU ARE DOING
        ["Balatro"] = true,
        ["Lovely"] = true,
        ["SuperRogue"] = true,
        ["Steamodded"] = true,
    }
}

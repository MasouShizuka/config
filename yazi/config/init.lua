require("session"):setup({
    sync_yanked = true,
})


require("fzf-rg"):setup()

require("projects"):setup({
    save = {
        method = "lua",
    },
    merge = {
        quit_after_merge = true,
    },
})


-- ya pkg add ndtoan96/ouch

-- ya pkg add yazi-rs/plugins:full-border
require("full-border"):setup({
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
})

-- ya pkg add yazi-rs/plugins:git
require("git"):setup()

-- ya pkg add yazi-rs/plugins:smart-enter
require("smart-enter"):setup({
    open_multi = true,
})

return {
    condition = require("lazy.status").has_updates,
    provider = function(self)
        return require("lazy.status").updates()
    end,
    hl = { fg = "#ff9e64" },
    update = {
        "User",
        pattern = "LazyUpdate",
    },
    on_click = {
        callback = function()
            require("lazy").update()
        end,
        name = "heirline_update_plugins",
    },
}

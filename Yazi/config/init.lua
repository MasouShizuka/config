local themes = {
    ["onedarkpro"] = {
        black = "#282c34",
        blue = "#61afef",
        cyan = "#56b6c2",
        gray = "#5c6370",
        green = "#98c379",
        orange = "#d19a66",
        purple = "#c678dd",
        red = "#e06c75",
        white = "#abb2bf",
        yellow = "#e5c07b",
    },
    ["tokyonight-moon"] = {
        black = "#222436",
        blue = "#82aaff",
        cyan = "#4fd6be",
        gray = "#545c7e",
        green = "#c3e88d",
        orange = "#ff966c",
        purple = "#fca7ea",
        red = "#ff757f",
        white = "#c8d3f5",
        yellow = "#ffc777",
    },
}

local theme = themes["tokyonight-moon"]


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


-- ya pkg add imsi32/yatline
require("yatline"):setup({
    style_a = {
        fg = theme.black,
        bg_mode = {
            normal = theme.blue,
            select = theme.yellow,
            un_set = theme.red,
        },
    },
    style_b = { bg = theme.gray, fg = theme.white },
    style_c = { bg = theme.black, fg = theme.white },

    permissions_t_fg = theme.blue,
    permissions_r_fg = theme.yellow,
    permissions_w_fg = theme.red,
    permissions_x_fg = theme.green,
    permissions_s_fg = theme.white,

    selected = { icon = "󰻭", fg = theme.yellow },
    copied = { icon = "", fg = theme.green },
    cut = { icon = "", fg = theme.red },

    total = { icon = "󰮍", fg = theme.yellow },
    succ = { icon = "", fg = theme.green },
    fail = { icon = "", fg = theme.red },
    found = { icon = "󰮕", fg = theme.blue },
    processed = { icon = "󰐍", fg = theme.green },

    show_background = false,

    header_line = {
        left = {
            section_a = {
                { type = "line", custom = false, name = "tabs", params = { "left" } },
            },
            section_b = {
            },
            section_c = {
            },
        },
        right = {
            section_a = {
                { type = "string", custom = false, name = "tab_path" },
            },
            section_b = {
            },
            section_c = {
            },
        },
    },

    status_line = {
        left = {
            section_a = {
                { type = "string", custom = false, name = "tab_mode" },
            },
            section_b = {
                { type = "string", custom = false, name = "hovered_size" },
            },
            section_c = {
                { type = "string",   custom = false, name = "hovered_name",  params = { { show_symlink = true } } },
                { type = "coloreds", custom = false, name = "modified_time", params = { theme.white } },
                { type = "coloreds", custom = false, name = "permissions" },
            },
        },
        right = {
            section_a = {
                { type = "string", custom = false, name = "cursor_position" },
            },
            section_b = {
                { type = "string", custom = false, name = "cursor_percentage" },
            },
            section_c = {
                { type = "coloreds", custom = false, name = "count" },
            },
        },
    },
})

if Yatline ~= nil then
    function Yatline.coloreds.get:modified_time(color)
        color = color or "white"

        local modified_time = {}

        local h = cx.active.current.hovered
        if h == nil then
            return modified_time
        end

        local mtime = h.cha.mtime
        if mtime == nil then
            return modified_time
        end

        local date = os.date(" %Y-%m-%d %H:%M:%S ", math.floor(mtime or 0))
        if date == nil then
            return modified_time
        end

        table.insert(modified_time, { date, color })

        return modified_time
    end
end

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

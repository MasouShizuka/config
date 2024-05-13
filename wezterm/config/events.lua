local wezterm = require("wezterm")

local function get_tab_title(tab_info, opts)
    opts = opts or {}

    local tab_title = tab_info.tab_title
    if not (tab_title and #tab_title > 0) then
        tab_title = tab_info.active_pane.title
    end

    tab_title = string.gsub(tab_title, "\\", "/")

    if opts["only_exe"] then
        local index = string.match(tab_title, ".*()/")
        if index then
            tab_title = string.sub(tab_title, index + 1, #tab_title)
        end
    end

    if opts["remove_ext"] then
        local index = string.match(tab_title, ".*()%.")
        if index then
            tab_title = string.sub(tab_title, 1, index - 1)
        end
    end

    if opts["add_index"] then
        tab_title = string.format("%s.%s", tab_info.tab_index + 1, tab_title)
    end

    return tab_title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local tab_title = get_tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = true,
    })

    local left = "  "
    local right = "  "
    tab_title = wezterm.truncate_right(tab_title, max_width - (#left + #right))

    return {
        { Text = left },
        { Text = tab_title },
        { Text = right },
    }
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local zoomed = ""
    if tab.active_pane.is_zoomed then
        zoomed = "[Z] "
    end

    local index = ""
    if #tabs > 1 then
        index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end

    local tab_title = get_tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = false,
    })

    return string.format("%s%s%s", zoomed, index, tab_title)
end)

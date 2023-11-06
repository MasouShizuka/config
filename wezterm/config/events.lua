local wezterm = require("wezterm")

local function tab_title(tab_info, opts)
    local title = tab_info.tab_title
    if not (title and #title > 0) then
        title = tab_info.active_pane.title
    end

    title = string.gsub(title, "\\", "/")

    if opts["only_exe"] then
        local index = string.match(title, ".*()/")
        if index then
            title = string.sub(title, index + 1, #title)
        end
    end

    if opts["remove_ext"] then
        local index = string.match(title, ".*()%.")
        if index then
            title = string.sub(title, 1, index - 1)
        end
    end

    if opts["add_index"] then
        title = tostring(tab_info.tab_index + 1) .. "." .. title
    end

    return title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = true,
    })

    local left = "  "
    local right = "  "
    title = wezterm.truncate_right(title, max_width - (#left + #right))

    return {
        { Text = left },
        { Text = title },
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

    local title = tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = false,
    })

    return zoomed .. index .. title
end)

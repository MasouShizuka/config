-- ╭─────────────────────────────────────────────────────────╮
-- │ Header                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- 修改 tabs 样式
function Header:tabs()
    local tabs = #cx.tabs
    if tabs == 1 then
        return ui.Line({})
    end

    local spans = {}
    for i = 1, tabs do
        local text = i
        if THEME.manager.tab_width > 2 then
            text = ya.truncate(text .. " " .. cx.tabs[i]:name(), { max = THEME.manager.tab_width })
            if i ~= 1 then
                spans[#spans + 1] = ui.Span(" ")
            end
        end
        if i == cx.tabs.idx then
            spans[#spans + 1] = ui.Span(THEME.status.separator_open):fg(THEME.manager.tab_active.bg)
            spans[#spans + 1] = ui.Span(text):style(THEME.manager.tab_active)
            spans[#spans + 1] = ui.Span(THEME.status.separator_close):fg(THEME.manager.tab_active.bg)
        else
            spans[#spans + 1] = ui.Span(THEME.status.separator_open):fg(THEME.manager.tab_inactive.bg)
            spans[#spans + 1] = ui.Span(text):style(THEME.manager.tab_inactive)
            spans[#spans + 1] = ui.Span(THEME.status.separator_close):fg(THEME.manager.tab_inactive.bg)
        end
    end
    return ui.Line(spans)
end

Header:children_remove(2, Header.RIGHT)
Header:children_add(Header.tabs, 2000, Header.RIGHT)

-- ╭─────────────────────────────────────────────────────────╮
-- │ Status                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- Show symlink in status bar
function Status:name()
    local h = self._tab.current.hovered
    if not h then
        return ui.Line("")
    end

    local linked = ""
    if h.link_to ~= nil then
        linked = " -> " .. tostring(h.link_to)
    end
    return ui.Line(" " .. h.name .. linked)
end

-- 修改时间
function Status:modified()
    local h = self._tab.current.hovered
    if h == nil then
        return ui.Line("")
    end

    local time = h.cha.modified
    if time == nil then
        return ui.Line("")
    end

    local date = os.date("%Y-%m-%d %H:%M:%S", time // 1)
    if date == nil then
        return ui.Line("")
    end

    return ui.Line({
        ui.Span(date):fg(self:style().bg),
        ui.Span(" "),
    })
end

Status:children_remove(3, Status.LEFT)
Status:children_add(Status.name, 3000, Status.LEFT)

Status:children_add(Status.modified, 500, Status.RIGHT)

-- ╭─────────────────────────────────────────────────────────╮
-- │ plugin                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- ya pack -a ndtoan96/ouch
-- ya pack -a yazi-rs/plugins:full-border

require("full-border"):setup({
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
})

require("projects"):setup({
    save = {
        method = "lua",
    },
    merge = {
        quit_after_merge = true,
    },
})

require("session"):setup({
    sync_yanked = true,
})

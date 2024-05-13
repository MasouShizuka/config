-- 将 "\" 替换成 "/"
function Header:cwd(max)
    local cwd = cx.active.current.cwd
    local readable = ya.readable_path(tostring(cwd):gsub("\\", "/"))

    local text = cwd.is_search and string.format("%s (search: %s)", readable, cwd:frag()) or readable
    return ui.Span(ya.truncate(text, { max = max, rtl = true })):style(THEME.manager.cwd)
end

-- Full border
function Manager:render(area)
    local chunks = self:layout(area)

    local bar = function(c, x, y)
        x, y = math.max(0, x), math.max(0, y)
        return ui.Bar(ui.Rect { x = x, y = y, w = ya.clamp(0, area.w - x, 1), h = math.min(1, area.h) }, ui.Bar.TOP)
            :symbol(c)
    end

    return ya.flat {
        -- Borders
        ui.Border(area, ui.Border.ALL):type(ui.Border.ROUNDED),
        ui.Bar(chunks[1], ui.Bar.RIGHT),
        ui.Bar(chunks[3], ui.Bar.LEFT),

        bar("┬", chunks[1].right - 1, chunks[1].y),
        bar("┴", chunks[1].right - 1, chunks[1].bottom - 1),
        bar("┬", chunks[2].right, chunks[2].y),
        bar("┴", chunks[2].right, chunks[1].bottom - 1),

        -- Parent
        Parent:render(chunks[1]:padding(ui.Padding.xy(1))),
        -- Current
        Current:render(chunks[2]:padding(ui.Padding.y(1))),
        -- Preview
        Preview:render(chunks[3]:padding(ui.Padding.xy(1))),
    }
end

-- 显示修改时间
function Status:modified()
    local h = cx.active.current.hovered
    if h == nil then
        return ui.Line({})
    end

    local time = h.cha.modified
    if time == nil then
        return ui.Line({})
    end

    local date = os.date("%Y-%m-%d %H:%M:%S", time // 1)
    if date == nil then
        return ui.Line({})
    end

    return ui.Line({
        ui.Span(date):fg(self.style().bg),
        ui.Span(" "),
    })
end

-- Show symlink in status bar
function Status:name()
    local h = cx.active.current.hovered
    if not h then
        return ui.Span("")
    end

    local linked = ""
    if h.link_to ~= nil then
        linked = " -> " .. tostring(h.link_to)
    end
    return ui.Span(" " .. h.name .. linked)
end

function Status:render(area)
    self.area = area

    local left = ui.Line({ self:mode(), self:size(), self:name() })
    local right = ui.Line({ self:modified(), self:permissions(), self:percentage(), self:position() })
    return ({
        ui.Paragraph(area, { left }),
        ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
        table.unpack(Progress:render(area, right:width())),
    })
end

require("session"):setup({
    sync_yanked = true,
})

require("projects"):setup({
    last = {
        update_after_save = true,
        update_after_load = true,
    },
    notify = {
        enable = true,
        title = "Projects",
        timeout = 3,
        level = "info",
    },
})

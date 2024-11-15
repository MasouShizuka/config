-- comment-box.nvim
-- https://github.com/LudoPinelli/comment-box.nvim

--         ╭──────────────────────────────────────────────────────────╮
--         │                     LOCAL VARIABLES                      │
--         ╰──────────────────────────────────────────────────────────╯

local cat = require("comment-box.catalog")
local catalog = require("comment-box.catalog_view")
local utils = require("comment-box.utils")

local M = {}

--         ╭──────────────────────────────────────────────────────────╮
--         │                         SETTINGS                         │
--         ╰──────────────────────────────────────────────────────────╯

local default_config = {
    comment_style = "line", -- "line"|"block"|"auto"
    doc_width = 80,
    margin = 1,
    padding = 1,
    keep_indent = false,

    box_width = 60,
    borders = {
        top = "─",
        bottom = "─",
        left = "│",
        right = "│",
        top_left = "╭",
        top_right = "╮",
        bottom_left = "╰",
        bottom_right = "╯",
    },
    box_blank_line_above = false,
    box_blank_line_below = false,
    box_inner_blank_lines = false,

    line_width = 60,
    lines = {
        line = "─",
        line_start = "─",
        line_end = "─",
        title_left = "─",
        title_right = "─",
    },

    line_blank_line_above = false,
    line_blank_line_below = false,
}

local default_style = {
    position = "left",      -- "left"|"center"|"right"
    justification = "left", -- "left"|"center"|"right"|"adapted",
    choice = 0,
}

local global_config

local global_style

local function update_config(config)
    if type(config) ~= "table" then
        global_config = default_config
    else
        global_config = vim.tbl_deep_extend("force", global_config, config)
    end
end

local function update_style(style)
    if type(style) ~= "table" then
        global_style = default_style
    else
        global_style = vim.tbl_deep_extend("force", global_style, style)
    end
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                          UTILS                           │
--         ╰──────────────────────────────────────────────────────────╯

local function set_borders()
    local borders

    local choice = tonumber(global_style.choice) or 0
    if choice ~= 0 and cat.boxes[choice] then
        borders = cat.boxes[choice]
    else
        borders = global_config.borders
    end

    return borders
end

local function set_lines()
    local lines

    local choice = tonumber(global_style.choice) or 0
    if choice ~= 0 and cat.lines[choice] then
        lines = cat.lines[choice]
    else
        lines = global_config.lines
    end

    return lines
end

local function set_lead_space(final_width, comment_string)
    local lead_space = string.rep(" ", global_config.margin)

    local offset = vim.fn.strdisplaywidth(comment_string)
    if global_style.position == "center" then
        lead_space = string.rep(
            " ",
            math.floor((global_config.doc_width - final_width - offset - global_config.margin) / 2) + global_config.margin
        )
    elseif global_style.position == "right" then
        lead_space = string.rep(" ", global_config.doc_width - final_width - offset)
    end

    return lead_space
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                           CORE                           │
--         ╰──────────────────────────────────────────────────────────╯

local function get_formated_text(is_box, comment_string_l, comment_string_b_start, comment_string_b_end, lstart, lend)
    local line_start_pos, line_end_pos = utils.get_range(lstart, lend)

    local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
    local final_width = 0
    local final_indent = -1

    for pos, str in ipairs(text) do
        table.remove(text, pos)

        if str:match("^%s*$") then
            table.insert(text, pos, "")
            goto continue
        end

        local indent
        str, indent = utils.skip_cs(
            str,
            comment_string_l,
            comment_string_b_start,
            comment_string_b_end,
            global_config
        )
        if final_indent == -1 or final_indent > indent then
            final_indent = indent
        end

        table.insert(text, pos, str)

        ::continue::
    end

    local url_width = 0
    for _, str in ipairs(text) do
        if str == "" then
            goto continue
        end

        str = str:sub(final_indent + 1)

        local url_start, url_end = utils.is_url(str)
        if url_start then
            url_width = math.max(
                url_width,
                url_end - url_start + 1
                + vim.fn.strdisplaywidth(global_config.borders.left)
                + vim.fn.strdisplaywidth(global_config.borders.right)
                + 2 * global_config.padding
            )
        end

        ::continue::
    end

    for pos, str in ipairs(text) do
        table.remove(text, pos)

        if str == "" then
            table.insert(text, pos, "")
            goto continue
        end

        str = str:sub(final_indent + 1)

        table.insert(text, pos, str)

        local str_width = vim.fn.strdisplaywidth(str)
        if str_width == nil then
            str_width = 0
        end

        if is_box then
            if global_style.justification == "adapted" then
                local width = str_width
                    + vim.fn.strdisplaywidth(global_config.borders.left)
                    + vim.fn.strdisplaywidth(global_config.borders.right)
                    + 2 * global_config.padding
                if width > math.max(url_width, global_config.box_width) then
                    final_width = math.max(url_width, global_config.box_width)
                elseif width > final_width then
                    final_width = width
                end
            else
                final_width = math.max(url_width, global_config.box_width)
            end
        else
            final_width = math.max(url_width, global_config.line_width)
        end

        if str_width > final_width then
            local to_insert = utils.wrap(str, final_width)
            for ipos, st in ipairs(to_insert) do
                table.insert(text, pos + ipos, st)
            end
            table.remove(text, pos)
        end

        ::continue::
    end

    return text, final_width, final_indent
end

local function get_text(lstart, lend)
    local result = {}

    local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
    local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)

    for i, str in ipairs(text) do
        str = str:gsub("^[^%w|(){}!,.;:?]+", "")
        str = str:gsub("[^%w|(){}!,.;:?]+$", "")
        if str ~= "" then
            table.insert(result, str)
        else
            if i > 1 and i < #text then
                table.insert(result, " ")
            end
        end
    end

    return result
end

local function should_use_block(comment_style, comment_string_l, comment_string_b_start, lstart, lend)
    local use_block

    if comment_string_l == "" and comment_string_b_start ~= "" then
        use_block = true
    elseif comment_string_b_start == "" and comment_string_l ~= "" then
        use_block = false
    elseif comment_style == "auto" and lend ~= nil and lstart ~= nil then
        if math.abs(lend - lstart) > 0 then
            use_block = true
        else
            use_block = false
        end
    else
        use_block = comment_style == "block"
    end

    return use_block
end

local function get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)
    local comment_string_int_row = ""

    if not use_block then
        comment_string_int_row = comment_string_l
    else
        local cs_len = vim.fn.strdisplaywidth(comment_string_b_start)
        if cs_len > 1 then
            comment_string_int_row = " " .. comment_string_b_start:sub(2, 2)
            if cs_len > 2 then
                comment_string_int_row = comment_string_int_row .. string.rep(" ", cs_len - 2)
            end
        end
    end

    return comment_string_int_row
end

local function remove(lstart, lend)
    local comment_string_l, comment_string_b_start, comment_string_b_end = utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block("line", comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local lines = {}

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    local result = get_text(lstart, lend)
    for _, line in pairs(result) do
        if line ~= "" then
            local row = string.format("%s%s%s", comment_string_int_row, " ", line)
            table.insert(lines, row)
        end
    end

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, lines)
end

local function yank(lstart, lend)
    local tab_text = get_text(lstart, lend)
    local tab_text_to_str = table.concat(tab_text, "\n")

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fn.setreg("+", tab_text_to_str .. "\n", "l")
end

local function display_box(lstart, lend)
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(global_config.comment_style, comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local text, final_width, final_indent = get_formated_text(true, comment_string_l, comment_string_b_start, comment_string_b_end, lstart, lend)
    local lead_space = set_lead_space(final_width, comment_string_int_row)
    local indent = string.rep(" ", final_indent)

    local symbols = set_borders()

    local ext_top_row = string.format(
        "%s%s%s%s%s%s",
        indent,
        comment_string_int_row,
        lead_space,
        symbols.top_left,
        string.rep(
            symbols.top,
            final_width
            - vim.fn.strdisplaywidth(symbols.top_left)
            - vim.fn.strdisplaywidth(symbols.top_right)
        ),
        symbols.top_right
    )

    local ext_bottom_row = string.format(
        "%s%s%s%s%s%s",
        indent,
        comment_string_int_row,
        lead_space,
        symbols.bottom_left,
        string.rep(
            symbols.bottom,
            final_width
            - vim.fn.strdisplaywidth(symbols.bottom_left)
            - vim.fn.strdisplaywidth(symbols.bottom_right)
        ),
        symbols.bottom_right
    )

    local inner_blank_line = string.format(
        "%s%s%s%s%s%s",
        indent,
        comment_string_int_row,
        lead_space,
        symbols.left,
        string.rep(" ", final_width),
        symbols.right
    )

    if global_config.box_blank_line_above then
        table.insert(lines, "")
    end

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    table.insert(lines, ext_top_row)

    if global_config.box_inner_blank_lines then
        table.insert(lines, inner_blank_line)
    end

    for _, line in pairs(text) do
        local start_pad, end_pad = utils.get_pad(
            line,
            global_style.justification,
            final_width
            - vim.fn.strdisplaywidth(symbols.left)
            - vim.fn.strdisplaywidth(symbols.right),
            global_config.padding
        )

        local int_row = string.format(
            "%s%s%s%s%s%s%s%s",
            indent,
            comment_string_int_row,
            lead_space,
            symbols.left,
            string.rep(" ", start_pad),
            line,
            string.rep(" ", end_pad),
            symbols.right
        )

        table.insert(lines, int_row)
    end

    if global_config.box_inner_blank_lines then
        table.insert(lines, inner_blank_line)
    end

    table.insert(lines, ext_bottom_row)

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if global_config.box_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_end_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] + 1
    if global_config.box_inner_blank_lines then
        cur[1] = cur[1] + 1
    end
    if global_config.box_blank_line_above then
        cur[1] = cur[1] + 1
    end
    vim.api.nvim_win_set_cursor(0, cur)
end

local function display_line()
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(global_config.comment_style, comment_string_l, comment_string_b_start)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local final_indent = 0
    if global_config.keep_indent then
        local line_start_pos, line_end_pos = utils.get_range()
        local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)

        final_indent = #text[1]:gsub("^(%s*).-%s*$", "%1")
    end
    local indent = string.rep(" ", final_indent)

    if global_config.line_blank_line_above then
        table.insert(lines, "")
    end

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    local symbols = set_lines()

    table.insert(
        lines,
        string.format(
            "%s%s%s%s%s%s",
            indent,
            comment_string_int_row,
            set_lead_space(global_config.line_width, comment_string_int_row),
            symbols.line_start,
            string.rep(
                symbols.line,
                global_config.line_width
                - vim.fn.strdisplaywidth(symbols.line_start)
                - vim.fn.strdisplaywidth(symbols.line_end)
            ),
            symbols.line_end
        )
    )

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if global_config.line_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, _ = utils.get_range()
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_start_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    if global_config.line_blank_line_below then
        cur[1] = cur[1] + 1
    end
    if global_config.line_blank_line_above then
        cur[1] = cur[1] + 1
    end
    vim.api.nvim_win_set_cursor(0, cur)
end

local function display_titled_line(lstart, lend)
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(global_config.comment_style, comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local text, final_width, final_indent = get_formated_text(false, comment_string_l, comment_string_b_start, comment_string_b_end, lstart, lend)
    local indent = string.rep(" ", final_indent)

    if global_config.line_blank_line_above then
        table.insert(lines, "")
    end

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    local symbols = set_lines()

    local start_pad, end_pad = utils.get_pad(
        text[1],
        global_style.justification,
        final_width
        - vim.fn.strdisplaywidth(symbols.line_start)
        - vim.fn.strdisplaywidth(symbols.title_left)
        - vim.fn.strdisplaywidth(symbols.title_right)
        - vim.fn.strdisplaywidth(symbols.line_end),
        global_config.padding
    )

    local padding = string.rep(" ", global_config.padding)

    table.insert(
        lines,
        string.format(
            "%s%s%s%s%s%s%s%s%s%s%s%s",
            indent,
            comment_string_int_row,
            set_lead_space(global_config.line_width, comment_string_int_row),
            symbols.line_start,
            string.rep(symbols.line, start_pad - global_config.padding),
            symbols.title_left,
            padding,
            text[1],
            padding,
            symbols.title_right,
            string.rep(symbols.line, end_pad - global_config.padding),
            symbols.line_end
        )
    )

    if #text > 1 then
        for i, value in ipairs(text) do
            if i > 1 then
                table.insert(
                    lines,
                    string.format(
                        "%s%s%s%s",
                        indent,
                        comment_string_int_row,
                        padding,
                        value
                    )
                )
            end
        end
    end

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if global_config.line_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_end_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    if global_config.line_blank_line_below then
        cur[1] = cur[1] + 1
    end
    if global_config.line_blank_line_above then
        cur[1] = cur[1] + 1
    end
    vim.api.nvim_win_set_cursor(0, cur)
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                        DOT REPEAT                        │
--         ╰──────────────────────────────────────────────────────────╯
-- https://github.com/kylechui/nvim-surround/blob/7b8a295a27038715bc87c01277d82c294b690e6d/lua/nvim-surround/cache.lua#L12
M.NOOP = function() end
local function set_callback(func_name)
    vim.go.operatorfunc = "v:lua.require'comment-box'.NOOP"
    vim.cmd.normal({ "g@l", bang = true })
    vim.go.operatorfunc = func_name
end

M.setup = function(opts)
    default_config = vim.tbl_deep_extend("force", default_config, opts or {})
    global_config = default_config
    global_style = default_style

    M._box = function()
        display_box()
    end
    M.box = function(style, config, lstart, lend)
        update_style(style)
        update_config(config)

        display_box(lstart, lend)

        set_callback("v:lua.require'comment-box'._box")
    end

    M._titled_line = function()
        display_titled_line()
    end
    M.titled_line = function(style, config, lstart, lend)
        update_style(style)
        update_config(config)

        display_titled_line(lstart, lend)

        set_callback("v:lua.require'comment-box'._titled_line")
    end

    M._line = function()
        display_line()
    end
    M.line = function(style, config)
        update_style(style)
        update_config(config)

        display_line()

        set_callback("v:lua.require'comment-box'._line")
    end

    M._dbox = function()
        remove()
    end
    M.dbox = function(lstart, lend)
        remove(lstart, lend)

        set_callback("v:lua.require'comment-box'._dbox")
    end

    M._yank = function()
        yank()
    end
    M.yank = function(lstart, lend)
        yank(lstart, lend)

        set_callback("v:lua.require'comment-box'._yank")
    end

    M.catalog = function()
        catalog.view_cat()
    end
end

return M

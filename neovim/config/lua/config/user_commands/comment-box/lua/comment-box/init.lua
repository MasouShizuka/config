-- comment-box.nvim
-- https://github.com/LudoPinelli/comment-box.nvim

--         ╭──────────────────────────────────────────────────────────╮
--         │                     LOCAL VARIABLES                      │
--         ╰──────────────────────────────────────────────────────────╯

local cat = require("comment-box.catalog")
local catalog = require("comment-box.catalog_view")
local comment_box_utils = require("comment-box.utils")

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
local config = vim.fn.deepcopy(default_config)

local default_style = {
    position = "left",      -- "left"|"center"|"right"
    justification = "left", -- "left"|"center"|"right"|"adapted",
    choice = 0,
}
local style = vim.fn.deepcopy(default_style)

local function wrapper(s, c, fn)
    local original_style = style
    local original_config = config

    if type(s) == "table" then
        style = vim.tbl_deep_extend("force", style, s)
    end
    if type(c) == "table" then
        config = vim.tbl_deep_extend("force", config, c)
    end

    fn()

    config = original_config
    style = original_style
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                          UTILS                           │
--         ╰──────────────────────────────────────────────────────────╯

local function set_borders()
    local borders

    local choice = tonumber(style.choice) or 0
    if choice ~= 0 and cat.boxes[choice] then
        borders = cat.boxes[choice]
    else
        borders = config.borders
    end

    return borders
end

local function set_lines()
    local lines

    local choice = tonumber(style.choice) or 0
    if choice ~= 0 and cat.lines[choice] then
        lines = cat.lines[choice]
    else
        lines = config.lines
    end

    return lines
end

local function set_lead_space(final_width, comment_string)
    local lead_space = string.rep(" ", config.margin)

    local offset = vim.fn.strdisplaywidth(comment_string)
    if style.position == "center" then
        lead_space = string.rep(
            " ",
            math.floor((config.doc_width - final_width - offset - config.margin) / 2) + config.margin
        )
    elseif style.position == "right" then
        lead_space = string.rep(" ", config.doc_width - final_width - offset)
    end

    return lead_space
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                           CORE                           │
--         ╰──────────────────────────────────────────────────────────╯

local function get_formated_text(is_box, comment_string_l, comment_string_b_start, comment_string_b_end, lstart, lend)
    local line_start_pos, line_end_pos = comment_box_utils.get_range(lstart, lend)

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
        str, indent = comment_box_utils.skip_cs(
            str,
            comment_string_l,
            comment_string_b_start,
            comment_string_b_end,
            config
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

        local url_start, url_end = comment_box_utils.is_url(str)
        if url_start then
            url_width = math.max(
                url_width,
                url_end - url_start + 1
                + vim.fn.strdisplaywidth(config.borders.left)
                + vim.fn.strdisplaywidth(config.borders.right)
                + 2 * config.padding
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
            if style.justification == "adapted" then
                local width = str_width
                    + vim.fn.strdisplaywidth(config.borders.left)
                    + vim.fn.strdisplaywidth(config.borders.right)
                    + 2 * config.padding
                if width > math.max(url_width, config.box_width) then
                    final_width = math.max(url_width, config.box_width)
                elseif width > final_width then
                    final_width = width
                end
            else
                final_width = math.max(url_width, config.box_width)
            end
        else
            final_width = math.max(url_width, config.line_width)
        end

        if str_width > final_width then
            local to_insert = comment_box_utils.wrap(str, final_width)
            for ipos, st in ipairs(to_insert) do
                table.insert(text, pos + ipos, st)
            end
            table.remove(text, pos)
        end

        ::continue::
    end

    return text, final_width, final_indent
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

    return vim.trim(comment_string_int_row)
end

local function get_text(lstart, lend)
    local utils = require("utils")

    local result = {}

    local line_start_pos, line_end_pos = comment_box_utils.get_range(lstart, lend)
    local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
    local indent = #text[1]:gsub("^(%s*).-%s*$", "%1")

    local comment_string_l, comment_string_b_start, comment_string_b_end = comment_box_utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block("line", comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    for i, str in ipairs(text) do
        str = str:sub(indent + 1, #str)

        for _, titled_line in ipairs(cat.lines) do
            local titled_line_rule = string.format(
                "^%s%%s*%s[%s]*%s%s(.-)%s%s[%s]*%s%%s*$",
                comment_string_int_row,
                utils.escape(titled_line.line_start),
                utils.escape(titled_line.line),
                utils.escape(titled_line.title_left),
                string.rep(" ", config.padding),
                string.rep(" ", config.padding),
                utils.escape(titled_line.title_right),
                utils.escape(titled_line.line),
                utils.escape(titled_line.line_end)
            )
            local res = str:match(titled_line_rule)
            if res then
                result[#result + 1] = res
                goto continue
            end
        end

        for _, box in ipairs(cat.boxes) do
            local box_rule = string.format(
                "^%s%%s*%s%s(.-)%s%s%%s*$",
                comment_string_int_row,
                utils.escape(box.left),
                string.rep(" ", config.padding),
                string.rep(" ", config.padding),
                utils.escape(box.right)
            )
            local res = str:match(box_rule)
            if res then
                result[#result + 1] = res
                goto continue
            end
        end

        str = str:gsub("^[^%w|(){}!,.;:?]+", "")
        str = str:gsub("[^%w|(){}!,.;:?]+$", "")
        if str ~= "" then
            table.insert(result, str)
        else
            if i > 1 and i < #text then
                table.insert(result, " ")
            end
        end

        ::continue::
    end

    return result, indent
end

local function remove(lstart, lend)
    local comment_string_l, comment_string_b_start, comment_string_b_end = comment_box_utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block("line", comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local lines = {}

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    local result, indent = get_text(lstart, lend)
    if not config.keep_indent then
        indent = 0
    end

    for _, line in pairs(result) do
        table.insert(lines, string.format(
            "%s%s%s%s",
            string.rep(" ", indent),
            comment_string_int_row,
            string.rep(" ", config.margin),
            line:match("^(.-)%s*$")
        ))
    end

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    local line_start_pos, line_end_pos = comment_box_utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, lines)
end

local function yank(lstart, lend)
    local tab_text, _ = get_text(lstart, lend)
    local tab_text_to_str = table.concat(vim.tbl_filter(function(s)
        return s ~= ""
    end, tab_text), "\n")

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fn.setreg("+", tab_text_to_str .. "\n", "l")
end

local function display_box(lstart, lend)
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = comment_box_utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(config.comment_style, comment_string_l, comment_string_b_start, lstart, lend)
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

    if config.box_blank_line_above then
        table.insert(lines, "")
    end

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    table.insert(lines, ext_top_row)

    if config.box_inner_blank_lines then
        table.insert(lines, inner_blank_line)
    end

    for _, line in pairs(text) do
        local start_pad, end_pad = comment_box_utils.get_pad(
            line,
            style.justification,
            final_width
            - vim.fn.strdisplaywidth(symbols.left)
            - vim.fn.strdisplaywidth(symbols.right),
            config.padding
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

    if config.box_inner_blank_lines then
        table.insert(lines, inner_blank_line)
    end

    table.insert(lines, ext_bottom_row)

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if config.box_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, line_end_pos = comment_box_utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_end_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] + 1
    if config.box_inner_blank_lines then
        cur[1] = cur[1] + 1
    end
    if config.box_blank_line_above then
        cur[1] = cur[1] + 1
    end
    vim.api.nvim_win_set_cursor(0, cur)
end

local function display_line()
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = comment_box_utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(config.comment_style, comment_string_l, comment_string_b_start)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local final_indent = 0
    if config.keep_indent then
        local line_start_pos, line_end_pos = comment_box_utils.get_range()
        local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)

        final_indent = #text[1]:gsub("^(%s*).-%s*$", "%1")
    end
    local indent = string.rep(" ", final_indent)

    if config.line_blank_line_above then
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
            set_lead_space(config.line_width, comment_string_int_row),
            symbols.line_start,
            string.rep(
                symbols.line,
                config.line_width
                - vim.fn.strdisplaywidth(symbols.line_start)
                - vim.fn.strdisplaywidth(symbols.line_end)
            ),
            symbols.line_end
        )
    )

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if config.line_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, _ = comment_box_utils.get_range()
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_start_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    if config.line_blank_line_below then
        cur[1] = cur[1] + 1
    end
    if config.line_blank_line_above then
        cur[1] = cur[1] + 1
    end
    vim.api.nvim_win_set_cursor(0, cur)
end

local function display_titled_line(lstart, lend)
    local lines = {}

    local comment_string_l, comment_string_b_start, comment_string_b_end = comment_box_utils.get_comment_string(vim.bo.filetype)
    local use_block = should_use_block(config.comment_style, comment_string_l, comment_string_b_start, lstart, lend)
    local comment_string_int_row = get_comment_string_int_row(use_block, comment_string_l, comment_string_b_start)

    local text, final_width, final_indent = get_formated_text(false, comment_string_l, comment_string_b_start, comment_string_b_end, lstart, lend)
    local indent = string.rep(" ", final_indent)

    if config.line_blank_line_above then
        table.insert(lines, "")
    end

    if use_block then
        table.insert(lines, comment_string_b_start)
    end

    local symbols = set_lines()

    for _, line in ipairs(text) do
        local start_pad, end_pad = comment_box_utils.get_pad(
            line,
            style.justification,
            final_width
            - vim.fn.strdisplaywidth(symbols.line_start)
            - vim.fn.strdisplaywidth(symbols.title_left)
            - vim.fn.strdisplaywidth(symbols.title_right)
            - vim.fn.strdisplaywidth(symbols.line_end),
            config.padding
        )

        local padding = string.rep(" ", config.padding)

        table.insert(
            lines,
            string.format(
                "%s%s%s%s%s%s%s%s%s%s%s%s",
                indent,
                comment_string_int_row,
                set_lead_space(config.line_width, comment_string_int_row),
                symbols.line_start,
                string.rep(symbols.line, start_pad - config.padding),
                symbols.title_left,
                padding,
                line,
                padding,
                symbols.title_right,
                string.rep(symbols.line, end_pad - config.padding),
                symbols.line_end
            )
        )
    end

    if use_block then
        table.insert(lines, comment_string_b_end)
    end

    if config.line_blank_line_below then
        table.insert(lines, "")
    end

    local line_start_pos, line_end_pos = comment_box_utils.get_range(lstart, lend)
    vim.api.nvim_buf_set_lines(
        0,
        line_start_pos - 1,
        line_end_pos,
        false,
        lines
    )

    local cur = vim.api.nvim_win_get_cursor(0)
    if config.line_blank_line_below then
        cur[1] = cur[1] + 1
    end
    if config.line_blank_line_above then
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
    config = vim.tbl_deep_extend("force", config, opts or {})

    M._box = function()
        display_box()
    end
    M.box = function(s, c, lstart, lend)
        wrapper(s, c, function()
            display_box(lstart, lend)
            set_callback("v:lua.require'comment-box'._box")
        end)
    end

    M._titled_line = function()
        display_titled_line()
    end
    M.titled_line = function(s, c, lstart, lend)
        wrapper(s, c, function()
            display_titled_line(lstart, lend)
            set_callback("v:lua.require'comment-box'._titled_line")
        end)
    end

    M._line = function()
        display_line()
    end
    M.line = function(s, c)
        wrapper(s, c, function()
            display_line()
            set_callback("v:lua.require'comment-box'._line")
        end)
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

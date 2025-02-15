local icons = require("utils.icons")
local utils = require("utils")

local M = {}

--- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
---@param self any the self parameter from Heirline component on_click.callback function call
---@param minwid any the minwid parameter from Heirline component on_click.callback function call
---@param clicks any the clicks parameter from Heirline component on_click.callback function call
---@param button any the button parameter from Heirline component on_click.callback function call
---@param mods any the button parameter from Heirline component on_click.callback function call
---@return table # the argument table with the decoded mouse information and signcolumn signs information
-- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astroui.status").utils.statuscolumn_clickargs(...) end } }
local function statuscolumn_clickargs(self, minwid, clicks, button, mods)
    local args = {
        minwid = minwid,
        clicks = clicks,
        button = button,
        mods = mods,
        mousepos = vim.fn.getmousepos(),
    }
    args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
    if args.char == " " then
        args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
    end

    if not self.signs then self.signs = {} end
    args.sign = self.signs[args.char]
    if not args.sign then -- update signs if not found on first click
        if not self.bufnr then
            self.bufnr = vim.api.nvim_get_current_buf()
        end
        local row = args.mousepos.line - 1
        for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(self.bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })) do
            local sign = extmark[4]
            if not (self.namespaces and self.namespaces[sign.ns_id]) then
                self.namespaces = {}
                for ns, ns_id in pairs(vim.api.nvim_get_namespaces()) do
                    self.namespaces[ns_id] = ns
                end
            end
            if sign.sign_text then
                self.signs[sign.sign_text:gsub("%s", "")] = {
                    name = sign.sign_name,
                    text = sign.sign_text,
                    texthl = sign.sign_hl_group or "NoTexthl",
                    namespace = sign.ns_id and self.namespaces[sign.ns_id],
                }
            end
        end
        args.sign = self.signs[args.char]
    end
    vim.api.nvim_set_current_win(args.mousepos.winid)
    vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
    return args
end

local ffi = require("ffi")
-- Custom C extension to get direct fold information from Neovim
ffi.cdef([[
    typedef struct {} Error;
    typedef struct {} win_T;
    typedef struct {
        int start;  // line number where deepest fold starts
        int level;  // fold level, when zero other fields are N/A
        int llevel; // lowest level that starts in v:lnum
        int lines;  // number of lines from v:lnum to end of closed fold
    } foldinfo_T;
    foldinfo_T fold_info(win_T* wp, int lnum);
    win_T *find_window_by_handle(int Window, Error *err);
    int compute_foldcolumn(win_T *wp, int col);
]])

local fillchars = vim.opt.fillchars:get()
local foldopen = fillchars.foldopen or icons.fold.FoldOpened
local foldclosed = fillchars.foldclose or icons.fold.FoldClosed
local foldsep = fillchars.foldsep or icons.fold.FoldSeparator

M.fold = {
    condition = function(self)
        return vim.opt.foldcolumn:get() ~= "0"
    end,
    provider = function(self)
        -- move to M.fold_indicator
        local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- get window handler
        local width = ffi.C.compute_foldcolumn(wp, 0)               -- get foldcolumn width
        -- get fold info of current line
        local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

        local str = ""
        if width ~= 0 then
            str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
            if foldinfo.level == 0 then
                str = str .. string.rep(" ", width)
            else
                local closed = foldinfo.lines > 0
                local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
                if first_level < 1 then
                    first_level = 1
                end

                for col = 1, width do
                    str = str
                        .. (
                            (vim.v.virtnum ~= 0 and foldsep)
                            or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
                            or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
                            or foldsep
                        )
                    if col == foldinfo.level then
                        str = str .. string.rep(" ", width - col)
                        break
                    end
                end
            end
        end
        return str .. "%*"
    end,
    on_click = {
        callback = function(...)
            local char = statuscolumn_clickargs(...).char
            local fillchars = vim.opt_local.fillchars:get()
            if char == (fillchars.foldopen or icons.fold.FoldOpened) then
                vim.cmd.normal({ "zc", bang = true })
            elseif char == (fillchars.foldcolse or icons.fold.FoldClosed) then
                vim.cmd.normal({ "zo", bang = true })
            end
        end,
        name = "heirline_fold_click",
    },
}

-- local function to resolve the first sign in the signcolumn
-- specifically for usage when `signcolumn=number`
local function resolve_sign(bufnr, lnum)
    local row = lnum - 1
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })
    local ret
    for _, extmark in pairs(extmarks) do
        local sign_def = extmark[4]
        if sign_def.sign_text and (not ret or (ret.priority < sign_def.priority)) then ret = sign_def end
    end
    if ret then return { text = ret.sign_text, texthl = ret.sign_hl_group } end
end

M.number = {
    condition = function(self)
        self.number, self.relativenumber = vim.opt.number:get(), vim.opt.relativenumber:get()
        return self.number or self.relativenumber
    end,
    provider = function(self)
        local lnum, relnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
        local number, relativenumber = self.number, self.relativenumber
        local bufnr = self and self.bufnr or 0
        local sign = vim.opt.signcolumn:get():find("nu") and resolve_sign(bufnr, lnum)
        local str
        if virtnum ~= 0 then
            str = "%="
        elseif sign then
            str = sign.text
            if sign.texthl then
                str = "%#" .. sign.texthl .. "#" .. str .. "%*"
            end
            str = "%=" .. str
        elseif not number and not relativenumber then
            str = "%="
        else
            local cur = relativenumber and (relnum > 0 and relnum or (number and lnum or 0)) or lnum
            str = "%=" .. cur
        end
        return str .. " "
    end,
    on_click = {
        callback = function(...)
            local args = statuscolumn_clickargs(...)
            if args.mods:find("c") then
                if utils.is_available("nvim-dap") then
                    require("dap").toggle_breakpoint()
                end
            end
        end,
        name = "heirline_line_click",
    },
}

local sign_handlers = {}

-- gitsigns handlers
local gitsigns_handler = function(_)
    local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
    if gitsigns_avail then
        vim.schedule(gitsigns.preview_hunk)
    end
end
for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Change", "Changedelete", "Delete" } do
    local name = "GitSigns" .. sign
    if not sign_handlers[name] then
        sign_handlers[name] = gitsigns_handler
    end
end

-- diagnostic handlers
local diagnostics_handler = function(args)
    if args.mods:find("c") then
        vim.schedule(vim.lsp.buf.code_action)
    else
        vim.schedule(vim.diagnostic.open_float)
    end
end
for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
    local name = "DiagnosticSign" .. sign
    if not sign_handlers[name] then
        sign_handlers[name] = diagnostics_handler
    end
end

-- DAP handlers
local dap_breakpoint_handler = function(_)
    local dap_avail, dap = pcall(require, "dap")
    if dap_avail then
        vim.schedule(dap.toggle_breakpoint)
    end
end
for _, sign in ipairs { "", "Rejected", "Condition" } do
    local name = "DapBreakpoint" .. sign
    if not sign_handlers[name] then
        sign_handlers[name] = dap_breakpoint_handler
    end
end

M.signcolumn = {
    condition = function(self)
        return vim.opt.signcolumn:get() ~= "no"
    end,
    provider = function(self)
        return "%s"
    end,
    on_click = {
        callback = function(...)
            local args = statuscolumn_clickargs(...)
            if args.sign then
                local handler = args.sign.name ~= "" and sign_handlers[args.sign.name]
                if not handler then
                    handler = sign_handlers[args.sign.namespace]
                end
                if not handler then
                    handler = sign_handlers[args.sign.texthl]
                end
                if handler then
                    handler(args)
                end
            end
        end,
        name = "heirline_sign_click",
    },
}

return M

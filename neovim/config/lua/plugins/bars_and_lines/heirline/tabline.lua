local bhu = require("plugins.bars_and_lines.heirline.utils")
local colors = require("utils.colors")
local icons = require("utils.icons")

local heirline_utils = require("heirline.utils")

local M = {}

M.tabline_offset = {
    condition = function(self)
        self.title = "Explorer"
        self.win = vim.api.nvim_tabpage_list_wins(0)[1]
        self.buf = vim.api.nvim_win_get_buf(self.win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = self.buf })
        local filetype = require("utils.filetype")
        return filetype.is_panel_filetype(ft, filetype.left_panel_filetype_list)
    end,
    provider = function(self)
        local width = vim.api.nvim_win_get_width(self.win)
        local pad = math.ceil((width - #self.title) / 2)
        return string.rep(" ", pad) .. self.title .. string.rep(" ", pad)
    end,
}

local tab = {
    init = function(self)
        self.win = vim.api.nvim_tabpage_get_win(self.tabpage)
        self.buf = vim.api.nvim_win_get_buf(self.win)
        self.filename = vim.api.nvim_buf_get_name(self.buf)
    end,
    on_click = {
        callback = function(_, minwid, _, button)
            if button == "m" then
                vim.schedule(function()
                    vim.api.nvim_command("tabclose " .. minwid)
                    vim.cmd.redrawtabline()
                end)
            else
                vim.api.nvim_command(minwid .. "tabnext")
            end
        end,
        minwid = function(self)
            return self.tabnr
        end,
        name = "heirline_tabline_buffer_callback",
    },

    require("plugins.bars_and_lines.heirline.file").file_icon,
    heirline_utils.insert(
        require("plugins.bars_and_lines.heirline.file").file_name,
        bhu.padding_before(
            bhu.insert_with_child_condition(
                {
                    condition = function(self)
                        return self.is_active
                    end,
                    update = { "BufEnter", "DiagnosticChanged" },
                },
                {
                    condition = function(self)
                        self.diagnostic_count = #vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
                        return self.diagnostic_count > 0
                    end,
                    provider = function(self)
                        return self.diagnostic_count
                    end,
                }
            )
        )
    ),
    bhu.padding_before(
        bhu.insert_with_child_condition(
            {
                condition = function(self)
                    return self.is_active
                end,
            },
            require("plugins.bars_and_lines.heirline.file").file_modified,
            require("plugins.bars_and_lines.heirline.file").file_readonly
        )
    ),
    bhu.padding_before({
        provider = icons.misc.close,
        hl = { fg = colors.colors.gray },
        on_click = {
            callback = function(_, minwid)
                vim.schedule(function()
                    vim.api.nvim_command("tabclose " .. minwid)
                    vim.cmd.redrawtabline()
                end)
            end,
            minwid = function(self)
                return self.tabnr
            end,
            name = "heirline_tabline_close_tab_callback",
        },
    }),
}

local function make_tablist(tab_component, left_trunc, right_trunc)
    left_trunc = left_trunc or { provider = icons.surround.chevron_left }
    right_trunc = right_trunc or { provider = icons.surround.chevron_right }

    left_trunc.on_click = {
        callback = function(self)
            self._buflist[1]._cur_page = self._cur_page - 1
            self._buflist[1]._force_page = true
            vim.cmd.redrawtabline()
        end,
        name = "heirline_tabline_prev",
    }
    right_trunc.on_click = {
        callback = function(self)
            self._buflist[1]._cur_page = self._cur_page + 1
            self._buflist[1]._force_page = true
            vim.cmd.redrawtabline()
        end,
        name = "heirline_tabline_next",
    }

    local tablist = {
        static = {
            _left_trunc = left_trunc,
            _right_trunc = right_trunc,
            _cur_page = 1,
            _force_page = false,
        },
        init = function(self)
            if vim.tbl_isempty(self._buflist) then
                self._buflist[#self._buflist + 1] = self
            end
            if not self.left_trunc then
                self.left_trunc = self:new(self._left_trunc)
            end
            if not self.right_trunc then
                self.right_trunc = self:new(self._right_trunc)
            end

            if not self._once then
                vim.api.nvim_create_autocmd({ "TabEnter" }, {
                    callback = function()
                        self._force_page = false
                    end,
                    desc = "Heirline release lock for next/prev buttons",
                })
                self._once = true
            end

            self.active_child = false

            local tabpages = vim.tbl_filter(function(tabnr)
                return vim.api.nvim_tabpage_is_valid(tabnr)
            end, vim.api.nvim_list_tabpages())

            for i, tabpage in ipairs(tabpages) do
                local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
                local child = self[i]
                if not (child and child.tabpage == tabpage) then
                    self[i] = self:new(tab_component, i)
                    child = self[i]
                    child.tabnr = tabnr
                    child.tabpage = tabpage
                end

                if tabpage == vim.api.nvim_get_current_tabpage() then
                    child.is_active = true
                    self.active_child = i
                else
                    child.is_active = false
                end
            end
            if #self > #tabpages then
                for i = #tabpages + 1, #self do
                    self[i] = nil
                end
            end
        end,
    }
    return tablist
end

M.tablist = make_tablist(
    bhu.surround_with_condition({ " ", " " }, nil, tab),
    { provider = icons.surround.chevron_left, hl = { fg = colors.colors.gray } },
    { provider = icons.surround.chevron_right, hl = { fg = colors.colors.gray } }
)

return M

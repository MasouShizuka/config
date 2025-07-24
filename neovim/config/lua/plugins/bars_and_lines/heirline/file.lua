local colors = require("utils.colors")
local icons = require("utils.icons")

local M = {}

M.file_encoding = {
    provider = function(self)
        local fileencoding = vim.api.nvim_get_option_value("fileencoding", { scope = "local" })
        local encoding = vim.api.nvim_get_option_value("encoding", { scope = "local" })
        local file_encoding
        if fileencoding ~= "" then
            file_encoding = fileencoding
        else
            file_encoding = encoding
        end
        return icons.misc.code_braces .. file_encoding:upper()
    end,
    update = { "BufEnter", "OptionSet" },
}

M.file_format = {
    provider = function(self)
        local fileformat = vim.api.nvim_get_option_value("fileformat", { scope = "local" })
        if fileformat == "dos" then
            return icons.platforms.windows .. "CRLF"
        else
            return icons.platforms.linux .. "LF"
        end
    end,
    update = { "BufEnter", "OptionSet" },
}

M.file_icon = {
    init = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        local filename = self.filename or vim.api.nvim_buf_get_name(buf)
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
        return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
        return { fg = self.icon_color }
    end,
}

M.file_indent = {
    init = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        local expandtab = vim.api.nvim_get_option_value("expandtab", { buf = buf })
        if expandtab then
            self.icon = icons.misc.bottom_square_bracket
        else
            self.icon = icons.misc.tab
        end
        self.tabstop = vim.api.nvim_get_option_value("tabstop", { buf = buf })
    end,
    provider = function(self)
        return self.icon .. self.tabstop
    end,
    update = { "BufEnter", "OptionSet" },
}

M.file_modified = {
    condition = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        return vim.api.nvim_get_option_value("modified", { buf = buf })
    end,
    provider = icons.dap.Breakpoint,
    hl = { fg = colors.colors.green },
    update = "BufModifiedSet",
}

M.file_name = {
    init = function(self)
        self.max_length = 30
        self.omit_str = "..."
    end,
    provider = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()

        local filename = self.filename or vim.api.nvim_buf_get_name(buf)
        if filename == "" then
            return "[No Name]"
        end

        filename = vim.fn.fnamemodify(filename, ":t")

        -- escape illegal character
        filename = filename:gsub("%%", "%%%%")

        if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
            filename, _ = vim.api.nvim_buf_get_name(buf):gsub(".*:", "")
        end

        local char_list = require("utils").get_char_from_string(filename)
        local char_count = #char_list
        if char_count > self.max_length then
            filename = self.omit_str .. table.concat(char_list, "", char_count - self.max_length + 1)
        end

        return filename
    end,
    hl = function(self)
        if self.tabpage and not self.is_active then
            return { fg = colors.colors.white }
        end

        local hl

        local error = require("plugins.bars_and_lines.heirline.diagnostic").get_diagnostic_severity("error")
        local warn = require("plugins.bars_and_lines.heirline.diagnostic").get_diagnostic_severity("warn")
        if error.condition(self) then
            hl = error.hl
        elseif warn.condition(self) then
            hl = warn.hl
        end

        if self.tabpage and self.is_active then
            if hl == nil then
                hl = { fg = colors.colors.purple }
            end
            hl.bold = true
        end

        return hl
    end,
}

M.file_readonly = {
    condition = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })
        local readonly = vim.api.nvim_get_option_value("readonly", { buf = buf })
        return not modifiable or readonly
    end,
    provider = function(self)
        if vim.api.nvim_get_option_value("buftype", { buf = self.buf }) == "terminal" then
            return icons.misc.terminal
        else
            return icons.misc.lock
        end
    end,
    hl = { fg = colors.colors.orange },
}

M.file_size = {
    provider = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        local filename = self.filename or vim.api.nvim_buf_get_name(buf)
        local suffix = { "B", "K", "M", "G", "T", "P", "E" }
        local fsize = vim.fn.getfsize(filename)
        fsize = (fsize < 0 and 0) or fsize
        if fsize < 1024 then
            return fsize .. suffix[1]
        end
        local i = math.floor((math.log(fsize) / math.log(1024)))
        return string.format("%.1f%s", fsize / (1024 ^ i), suffix[i + 1])
    end,
    update = { "BufEnter", "BufWrite" },
}

return M

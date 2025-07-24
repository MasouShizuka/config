local colors = require("utils.colors")

return {
    condition = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        self.ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        return package.loaded["lint"] and vim.tbl_contains(require("utils.lint").lint_filetype_list, self.ft)
    end,
    provider = function(self)
        local nvim_lint = require("lint")
        local icons = require("utils.icons")

        local icon
        if #nvim_lint.get_running() == 0 then
            icon = icons.misc.progress_check
        else
            icon = icons.misc.magnify_scan
        end

        local names = {}
        for _, linter in ipairs(nvim_lint._resolve_linter_by_ft(self.ft)) do
            names[#names + 1] = linter
        end

        return icon .. table.concat(names, ",")
    end,
    hl = { fg = colors.colors.red },
}

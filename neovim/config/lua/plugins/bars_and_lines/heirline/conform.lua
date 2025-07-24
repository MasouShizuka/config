local colors = require("utils.colors")

return {
    condition = function(self)
        local buf = self.buf or vim.api.nvim_get_current_buf()
        self.ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        return package.loaded["conform"] and vim.tbl_contains(require("utils.format").format_filetype_list, self.ft)
    end,
    provider = function(self)
        local names = {}
        for _, formatter in ipairs(require("conform").list_formatters(0)) do
            names[#names + 1] = formatter.name
        end
        return require("utils.icons").misc.format_list_text .. table.concat(names, ",")
    end,
    hl = { fg = colors.colors.yellow },
    update = "BufEnter",
}

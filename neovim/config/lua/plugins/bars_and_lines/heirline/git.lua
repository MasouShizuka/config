local bhu = require("plugins.bars_and_lines.heirline.utils")
local colors = require("utils.colors")

local M = {}

local function get_git_status(status, show_count)
    status = status:lower()

    local icons = require("utils.icons")

    local icon, hl
    if status == "added" then
        icon = icons.git.added
        hl = { fg = colors.colors.git_add }
    elseif status == "changed" then
        icon = icons.git.modified
        hl = { fg = colors.colors.git_change }
    elseif status == "removed" then
        icon = icons.git.deleted
        hl = { fg = colors.colors.git_delete }
    end

    return {
        condition = function(self)
            if vim.b.gitsigns_status_dict == nil then
                return false
            end

            self.count = vim.b.gitsigns_status_dict[status] or 0
            return self.count > 0
        end,
        provider = function(self)
            if show_count then
                return icon .. self.count
            else
                return icon
            end
        end,
        hl = hl,
    }
end

M.git_branch = {
    condition = function(self)
        if not require("heirline.conditions").is_git_repo then
            return false
        end

        self.status_dict = vim.b.gitsigns_status_dict
        return self.status_dict
    end,
    provider = function(self)
        return require("utils.icons").git.branch .. self.status_dict.head
    end,
    hl = { fg = colors.colors.orange },
}

M.git_status = bhu.insert_with_child_condition(
    {},
    bhu.padding_before(get_git_status("added", true)),
    bhu.padding_before(get_git_status("changed", true)),
    bhu.padding_before(get_git_status("removed", true))
)

return M

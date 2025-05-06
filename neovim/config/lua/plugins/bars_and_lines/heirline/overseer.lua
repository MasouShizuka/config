local bhu = require("plugins.bars_and_lines.heirline.utils")
local icons = require("utils.icons")

local function OverseerTasksForStatus(status)
    return {
        condition = function(self)
            return self.tasks[status]
        end,
        provider = function(self)
            return string.format("%s%d", self.symbols[status], #self.tasks[status])
        end,
        hl = function(self)
            return {
                fg = require("heirline.utils").get_highlight(string.format("Overseer%s", status)).fg,
            }
        end,
    }
end

return {
    condition = function()
        return package.loaded["overseer"]
    end,
    init = function(self)
        local tasks = require("overseer.task_list").list_tasks({ unique = true })
        local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
        self.tasks = tasks_by_status
    end,
    static = {
        symbols = {
            ["CANCELED"] = icons.dap.BreakpointRejected,
            ["FAILURE"] = icons.misc.close,
            ["SUCCESS"] = icons.misc.progress_check,
            ["RUNNING"] = icons.misc.refresh,
        },
    },

    bhu.padding_after(OverseerTasksForStatus("CANCELED")),
    bhu.padding_after(OverseerTasksForStatus("RUNNING")),
    bhu.padding_after(OverseerTasksForStatus("SUCCESS")),
    bhu.padding_after(OverseerTasksForStatus("FAILURE")),
}

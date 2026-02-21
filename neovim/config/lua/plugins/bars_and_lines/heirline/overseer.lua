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

local function OverseerTasksForRunning()
    local prev_is_running = false
    local spinner_name = "overseer_running"
    return {
        condition = function(self)
            local is_running = self.tasks["RUNNING"] ~= nil
            if require("utils").is_available("spinner.nvim") then
                if is_running ~= prev_is_running then
                    prev_is_running = is_running
                    if is_running then
                        require("spinner").start(spinner_name)
                    else
                        require("spinner").stop(spinner_name)
                    end
                end
            end
            return is_running
        end,
        init = function(self)
            if require("utils").is_available("spinner.nvim") then
                require("spinner").config(spinner_name, {
                    kind = "statusline",
                    pattern = "dotsCircle",
                })
            end
        end,
        provider = function(self)
            local symbol
            if require("utils").is_available("spinner.nvim") then
                symbol = require("spinner").render(spinner_name)
            else
                symbol = self.symbols["RUNNING"]
            end
            return string.format("%s%d", symbol, #self.tasks["RUNNING"])
        end,
        hl = function(self)
            return {
                fg = require("heirline.utils").get_highlight(string.format("Overseer%s", "RUNNING")).fg,
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
    bhu.padding_after(OverseerTasksForRunning()),
    bhu.padding_after(OverseerTasksForStatus("SUCCESS")),
    bhu.padding_after(OverseerTasksForStatus("FAILURE")),
}

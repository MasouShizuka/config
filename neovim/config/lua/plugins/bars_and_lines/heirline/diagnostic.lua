local bhu = require("plugins.bars_and_lines.heirline.utils")

local M = {}

M.get_diagnostic_severity = function(severity, show_count)
    severity = severity:upper()

    local colors = require("utils.colors")
    local icons = require("utils.icons")

    local icon, hl
    if severity == "ERROR" then
        icon = icons.diagnostics.Error
        hl = { fg = colors.colors.red }
    elseif severity == "WARN" then
        icon = icons.diagnostics.Warn
        hl = { fg = colors.colors.yellow }
    elseif severity == "INFO" then
        icon = icons.diagnostics.Info
        hl = { fg = colors.colors.blue }
    elseif severity == "HINT" then
        icon = icons.diagnostics.Hint
        hl = { fg = colors.colors.cyan }
    end

    return {
        condition = function(self)
            self.count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity] })
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

M.diagnostic = bhu.insert_with_child_condition(
    { update = { "BufEnter", "DiagnosticChanged" } },
    bhu.padding_before(M.get_diagnostic_severity("error", true)),
    bhu.padding_before(M.get_diagnostic_severity("warn", true)),
    bhu.padding_before(M.get_diagnostic_severity("info", true)),
    bhu.padding_before(M.get_diagnostic_severity("hint", true))
)

return M

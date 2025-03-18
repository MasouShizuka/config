local environment = require("utils.environment")

return {
    {
        "uga-rosa/ccc.nvim",
        cmd = {
            "CccPick",
            "CccConvert",
            "CccHighlighterEnable",
            "CccHighlighterDisable",
            "CccHighlighterToggle",
        },
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        opts = function()
            local mapping = require("ccc").mapping

            return {
                highlighter = {
                    auto_enable = true,
                },
                mappings = {
                    -- ["cr"] = mapping.complete,
                    -- ["q"] = mapping.quit,
                    -- ["i"] = mapping.cycle_input_mode,
                    -- ["o"] = mapping.cycle_output_mode,
                    -- ["r"] = mapping.reset_mode,
                    -- ["a"] = mapping.toggle_alpha,
                    -- ["g"] = mapping.toggle_prev_colors,
                    ["g"] = mapping.none,
                    ["p"] = mapping.toggle_prev_colors,
                    -- none = mapping.show_prev_colors,
                    -- none = mapping.hide_prev_colors,
                    -- ["w"] = mapping.goto_next,
                    -- ["b"] = mapping.goto_prev,
                    -- ["W"] = mapping.goto_tail,
                    -- ["B"] = mapping.goto_head,
                    -- ["l"] = mapping.increase1,
                    -- ["d"] = mapping.increase5,
                    -- [","] = mapping.increase10,
                    -- ["h"] = mapping.decrease1,
                    -- ["s"] = mapping.decrease5,
                    -- ["m"] = mapping.decrease10,
                    -- ["H"] = mapping.set0,
                    -- ["M"] = mapping.set50,
                    -- ["L"] = mapping.set100,
                },
            }
        end,
    },
}

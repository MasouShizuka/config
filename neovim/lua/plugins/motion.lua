return {
    {
        "chrisgrieser/nvim-spider",
        keys = {
            { "w",  function() require("spider").motion("w") end,  desc = "Next word",            mode = { "n", "x", "o" } },
            { "e",  function() require("spider").motion("e") end,  desc = "Next end of word",     mode = { "n", "x", "o" } },
            { "b",  function() require("spider").motion("b") end,  desc = "Previous word",        mode = { "n", "x", "o" } },
            { "ge", function() require("spider").motion("ge") end, desc = "Previous end of word", mode = { "n", "x", "o" } },
        },
        opts = {},
    },

    {
        "folke/flash.nvim",
        keys = {
            { "m", function() require("flash").jump() end, desc = "Flash",     mode = { "n", "x" } },
            { "/", desc = "Search forward",                mode = { "n", "x" } },
            { "?", desc = "Search backward",               mode = { "n", "x" } },
            { "f", desc = "Move to next char",             mode = { "n", "x" } },
            { "F", desc = "Move to previous char",         mode = { "n", "x" } },
            { "t", desc = "Move before next char",         mode = { "n", "x" } },
            { "T", desc = "Move before next char",         mode = { "n", "x" } },
        },
        opts = {
            search = {
                -- search/jump in all windows
                multi_window = false,
            },
            label = {
                -- allow uppercase labels
                uppercase = false,
                -- show the label after the match
                after = false,
                -- show the label before the match
                before = true,
            },
            -- You can override the default options for a specific mode.
            -- Use it with `require("flash").jump({mode = "forward"})`
            ---@type table<string, Flash.Config>
            modes = {
                -- options used when flash is activated through
                -- `f`, `F`, `t`, `T`, `;` and `,` motions
                char = {
                    -- dynamic configuration for ftFT motions
                    config = function(opts)
                        if vim.fn.mode(true):find("o") then
                            local autohide_operator_list = { "y", "d", "g@" }
                            for _, operator in ipairs(autohide_operator_list) do
                                if vim.v.operator == operator then
                                    opts.autohide = true
                                    break
                                end
                            end
                        else
                            if vim.v.count == 0 then
                                opts.jump_labels = true
                            else
                                opts.autohide = true
                            end
                        end
                    end,
                    -- When using jump labels, don't use these keys
                    -- This allows using those keys directly after the motion
                    label = { exclude = "hjkliardcx" },
                    highlight = {
                        backdrop = false,
                    },
                },
            },
        },
    },
}

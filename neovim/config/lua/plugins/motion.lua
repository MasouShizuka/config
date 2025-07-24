return {
    {
        "rainzm/flash-zh.nvim",
        dependencies = {
            {
                "folke/flash.nvim",
                keys = {
                    { "/", desc = "Search forward",        mode = { "n", "x" } },
                    { "?", desc = "Search backward",       mode = { "n", "x" } },
                    { "f", desc = "Move to next char",     mode = { "n", "x", "o" } },
                    { "F", desc = "Move to previous char", mode = { "n", "x", "o" } },
                    { "t", desc = "Move before next char", mode = { "n", "x", "o" } },
                    { "T", desc = "Move before next char", mode = { "n", "x", "o" } },
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
        },
        keys = {
            { "m", function() require("flash-zh").jump({ chinese_only = false }) end, desc = "Flash between Chinese", mode = { "n", "x", "o" } },
        },
        opts = {},
    },
}

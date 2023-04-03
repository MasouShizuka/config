vim.keymap.set("n", "gr", require("substitute").operator, { silent = true })
vim.keymap.set("n", "grr", require("substitute").line, { silent = true })
vim.keymap.set("x", "R", require("substitute").visual, { silent = true })
vim.keymap.set("n", "cx", require("substitute.exchange").operator, { silent = true })
vim.keymap.set("n", "cxx", require("substitute.exchange").line, { silent = true })
vim.keymap.set("x", "C", require("substitute.exchange").visual, { silent = true })
vim.keymap.set("n", "cxc", require("substitute.exchange").cancel, { silent = true })

require("substitute").setup(
    {
        on_substitute = nil,
        yank_substituted_text = false,
        highlight_substituted_text = {
            enabled = true,
            timer = 500,
        },
        range = {
            prefix = "s",
            prompt_current_text = false,
            confirm = false,
            complete_word = false,
            motion1 = false,
            motion2 = false,
            suffix = "",
        },
        exchange = {
            motion = false,
            use_esc_to_cancel = true,
        },
    }
)

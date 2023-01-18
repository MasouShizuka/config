require("cool-substitute").setup(
    {
        setup_keybindings = true,
        mappings = {
            start = "g!m", -- Mark word / region
            start_word = "gm", -- Mark word / region. Edit only full word
            start_and_edit = "g!M", -- Mark word / region and also edit
            start_and_edit_word = "gM", -- Mark word / region and also edit.  Edit only full word.
            apply_substitute_and_next = "m", -- Start substitution / Go to next substitution
            apply_substitute_and_prev = "M", -- same as M but backwards
            --   apply_substitute_all = "ga", -- Substitute all
            --   force_terminate_substitute = "g!!", -- Terminate macro (if some bug happens)
            --   terminate_substitute = "<esc>", -- Terminate macro
            --   skip_substitute = "<cr>", -- Skip this occurrence
            --   goto_next = "<C-j>", -- Go to next occurence
            --   goto_previous = "<C-k>", -- Go to previous occurrence
        },
        -- reg_char = "o", -- letter to save macro (Dont use number or uppercase here)
        -- mark_char = "t", -- mark the position at start of macro
        -- writing_substitution_color = "#ECBE7B", -- for status line
        -- applying_substitution_color = "#98be65", -- for status line
        -- edit_word_when_starting_with_substitute_key = true -- (press M to mark and edit when not executing anything anything)
    }
)

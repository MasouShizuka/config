require("cool-substitute").setup(
    {
        setup_keybindings = true,
        mappings = {
            --   start = "gm",                             -- Mark word / region
            start = "g!m",
            --   start_and_edit = "gM",                    -- Mark word / region and also edit
            start_and_edit = "g!M",
            --   start_and_edit_word = "g!M",              -- Mark word / region and also edit.  Edit only full word.
            start_and_edit_word = "gM",
            --   start_word = "g!m",                       -- Mark word / region. Edit only full word
            start_word = "gm",
            -- apply_substitute_and_next = "M",            -- Start substitution / Go to next substitution
            apply_substitute_and_next = ")",
            -- apply_substitute_and_prev = "<C-b>",        -- same as M but backwards
            apply_substitute_and_prev = "(",
            --   apply_substitute_all = "ga",              -- Substitute all
            apply_substitute_all = "g!a",
            force_terminate_substitute = "g!!",            -- Terminate macro (if some bug happens)
            redo_last_record = "g!r",
            terminate_substitute = "<esc>",                -- Terminate macro
            -- skip_substitute = "n",                      -- Skip this occurrence
            skip_substitute = "M",
            goto_next = "}",                               -- Go to next occurence
            goto_previous = "{",                           -- Go to previous occurrence
        },
        reg_char = "o",                                    -- letter to save macro (Dont use number or uppercase here)
        mark_char = "t",                                   -- mark the position at start of macro
        writing_substitution_color = "#ECBE7B",            -- for status line
        applying_substitution_color = "#98be65",           -- for status line
        edit_word_when_starting_with_substitute_key = true -- (press M to mark and edit when not executing anything anything)
    }
)

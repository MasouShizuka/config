local environment = require("utils.environment")

local M = {}

local remapped_terminal_emulators = {
    "WezTerm",
    "WindowsTerminal",
}

if vim.tbl_contains(remapped_terminal_emulators, vim.env.TERM_PROGRAM) then
    if environment.is_wsl then
        M = {
            ["<c-1>"] = "<f25>",
            ["<c-2>"] = "<f26>",
            ["<c-3>"] = "<f27>",
            ["<c-4>"] = "<f28>",
            ["<c-space>"] = "<f29>",
            ["<c-,>"] = "<f30>",
            ["<c-.>"] = "<f31>",
            ["<c-;>"] = "<f32>",
            ["<c-s-n>"] = "<f33>",
            ["<c-s-t>"] = "<f34>",
        }
    else
        M = {
            ["<c-1>"] = "<c-f1>",
            ["<c-2>"] = "<c-f2>",
            ["<c-3>"] = "<c-f3>",
            ["<c-4>"] = "<c-f4>",
            ["<c-space>"] = "<c-f5>",
            ["<c-,>"] = "<c-f6>",
            ["<c-.>"] = "<c-f7>",
            ["<c-;>"] = "<c-f8>",
            ["<c-s-n>"] = "<c-f9>",
            ["<c-s-t>"] = "<c-f10>",
        }
    end
else
    M = {
        ["<c-1>"] = "<c-1>",
        ["<c-2>"] = "<c-2>",
        ["<c-3>"] = "<c-3>",
        ["<c-4>"] = "<c-4>",
        ["<c-space>"] = "<c-space>",
        ["<c-,>"] = "<c-,>",
        ["<c-.>"] = "<c-.>",
        ["<c-;>"] = "<c-;>",
        ["<c-s-n>"] = "<c-s-n>",
        ["<c-s-t>"] = "<c-s-t>",
    }
end

return M

local environment = require("utils.environment")

local M

if environment.is_neovide then
    M = {
        ["<c-1>"] = "<c-1>",
        ["<c-2>"] = "<c-2>",
        ["<c-3>"] = "<c-3>",
        ["<c-4>"] = "<c-4>",
        ["<c-,>"] = "<c-,>",
        ["<c-.>"] = "<c-.>",
        ["<c-;>"] = "<c-;>",
        ["<c-s-n>"] = "<c-s-n>",
        ["<c-s-t>"] = "<c-s-t>",
    }
else
    M = {
        ["<c-1>"] = "<leader>k1",
        ["<c-2>"] = "<leader>k2",
        ["<c-3>"] = "<leader>k3",
        ["<c-4>"] = "<leader>k4",
        ["<c-,>"] = "<leader>k,",
        ["<c-.>"] = "<leader>k.",
        ["<c-;>"] = "<leader>k;",
        ["<c-s-n>"] = "<leader>kn",
        ["<c-s-t>"] = "<leader>kt",
    }
end

return M

--            ╭─────────────────────────────────────────────────────────╮
--            │                        COMMANDS                         │
--            ╰─────────────────────────────────────────────────────────╯

-- ── boxes ─────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("CBllbox", function(opts)
    require("comment-box").box({ position = "left", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned box with text left aligned",
})

vim.api.nvim_create_user_command("CBlcbox", function(opts)
    require("comment-box").box({ position = "left", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned box with text centered",
})

vim.api.nvim_create_user_command("CBlrbox", function(opts)
    require("comment-box").box({ position = "left", justification = "right", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned box with text right aligned",
})

vim.api.nvim_create_user_command("CBclbox", function(opts)
    require("comment-box").box({ position = "center", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered box with text left aligned",
})

vim.api.nvim_create_user_command("CBccbox", function(opts)
    require("comment-box").box({ position = "center", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered box with text centered",
})

vim.api.nvim_create_user_command("CBcrbox", function(opts)
    require("comment-box").box({ position = "center", justification = "right", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered box with text right aligned",
})

vim.api.nvim_create_user_command("CBrlbox", function(opts)
    require("comment-box").box({ position = "right", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned box with text left aligned",
})

vim.api.nvim_create_user_command("CBrcbox", function(opts)
    require("comment-box").box({ position = "right", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned box with text centered",
})

vim.api.nvim_create_user_command("CBrrbox", function(opts)
    require("comment-box").box({ position = "right", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned box with text right aligned",
})

vim.api.nvim_create_user_command("CBlabox", function(opts)
    require("comment-box").box({ position = "left", justification = "adapted", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned adapted box",
})

vim.api.nvim_create_user_command("CBcabox", function(opts)
    require("comment-box").box({ position = "center", justification = "adapted", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered adapted box",
})

vim.api.nvim_create_user_command("CBrabox", function(opts)
    require("comment-box").box({ position = "right", justification = "adapted", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned adapted box",
})

-- ── Utils ─────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("CBd", function(opts)
    require("comment-box").dbox(opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Remove a box or a titled line",
})

vim.api.nvim_create_user_command("CBy", function(opts)
    require("comment-box").yank(opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Yank the content of a box or a titled line",
})

-- ── Lines ─────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("CBline", function(opts)
    require("comment-box").line { position = "left", choice = opts.args }
end, {
    nargs = "?",
    desc = "Print a left aligned line",
})

vim.api.nvim_create_user_command("CBlline", function(opts)
    require("comment-box").line { position = "left", choice = opts.args }
end, {
    nargs = "?",
    desc = "Print a left aligned line",
})

vim.api.nvim_create_user_command("CBcline", function(opts)
    require("comment-box").line { position = "center", choice = opts.args }
end, {
    nargs = "?",
    desc = "Print a centered line",
})

vim.api.nvim_create_user_command("CBrline", function(opts)
    require("comment-box").line { position = "right", choice = opts.args }
end, {
    nargs = "?",
    desc = "Print a right aligned line",
})

-- ── Titled Lines ──────────────────────────────────────────────────────

vim.api.nvim_create_user_command("CBllline", function(opts)
    require("comment-box").titled_line({ position = "left", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned titled line with title left aligned",
})

vim.api.nvim_create_user_command("CBlcline", function(opts)
    require("comment-box").titled_line({ position = "left", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned titled line with title centered",
})

vim.api.nvim_create_user_command("CBlrline", function(opts)
    require("comment-box").titled_line({ position = "left", justification = "right", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a left aligned titled line with title right aligned",
})

vim.api.nvim_create_user_command("CBclline", function(opts)
    require("comment-box").titled_line({ position = "center", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered titled line with title right aligned",
})

vim.api.nvim_create_user_command("CBccline", function(opts)
    require("comment-box").titled_line({ position = "center", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered titled line with title centered",
})

vim.api.nvim_create_user_command("CBcrline", function(opts)
    require("comment-box").titled_line({ position = "center", justification = "right", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a centered titled line with title right aligned",
})

vim.api.nvim_create_user_command("CBrlline", function(opts)
    require("comment-box").titled_line({ position = "right", justification = "left", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned titled line with title left aligned",
})

vim.api.nvim_create_user_command("CBrcline", function(opts)
    require("comment-box").titled_line({ position = "right", justification = "center", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned titled line with title centered",
})

vim.api.nvim_create_user_command("CBrrline", function(opts)
    require("comment-box").titled_line({ position = "right", justification = "right", choice = opts.args }, {}, opts.line1, opts.line2)
end, {
    nargs = "?",
    range = 2,
    desc = "Print a right aligned titled line with title right aligned",
})

-- ── Catalog ───────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("CBcatalog", function()
    require("comment-box").catalog()
end, { desc = "Open the catalog" })

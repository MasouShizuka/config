local _load_config = ya.sync(function(state, opts)
    opts = opts or {}

    state.args = {
        bat = {
            "--number",
            "--color", "always",
            "--line-range", ":500",
        },
        fzf = {
            "--preview-window", "~5,+{2}+4/3,<80(up)",
        },
        rg = {
            "--smart-case",
            "--color=always",
            "--column",
        },
    }
    if type(opts.args) == "table" then
        if opts.args.bat then
            if type(opts.args.bat) == "string" then
                opts.args.bat = { opts.args.bat }
            end
            state.args.bat = opts.args.bat
        end
        if type(opts.args.fzf) == "table" then
            state.args.fzf = opts.args.fzf
        end
        if opts.args.rg then
            if type(opts.args.rg) == "string" then
                opts.args.rg = {}
            end
            state.args.rg = opts.args.rg
        end
    end
end)

local _get_config = ya.sync(function(state, name)
    return state[name]
end)

local state = ya.sync(function() return tostring(cx.active.current.cwd) end)

local function fail(s, ...) ya.notify { title = "Fzf", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
    local args = _get_config("args")
    local bat_args = args.bat
    local fzf_args = args.fzf
    local rg_args = args.rg

    local rg_args_str = ""
    for _, value in ipairs(rg_args) do
        rg_args_str = rg_args_str .. " " .. value
    end
    local reload = "reload:rg {q} " .. rg_args_str .. " || :"

    local bat_args_str = ""
    for _, value in ipairs(bat_args) do
        bat_args_str = bat_args_str .. " " .. value
    end
    local preview_cmd = "bat --highlight-line {2} {1} " .. bat_args_str

    -- https://junegunn.github.io/fzf/tips/ripgrep-integration/
    local cmd_args = {
        "--delimiter", ":",
        "--disabled",
        "--bind", "start:" .. reload,
        "--bind", "change:" .. reload,
        "--ansi",
        "--preview", preview_cmd,
    }
    for _, value in ipairs(fzf_args) do
        cmd_args[#cmd_args + 1] = value
    end

    local _permit = ya.hide()
    local cwd = state()

    local child, err =
        Command("fzf"):arg(cmd_args):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

    if not child then
        return fail("Spawn `rfzf` failed with error code %s. Do you have it installed?", err)
    end

    local output, err = child:wait_with_output()
    if not output then
        return fail("Cannot read `fzf` output, error code %s", err)
    elseif not output.status.success and output.status.code ~= 130 then
        return fail("`fzf` exited with error code %s", output.status.code)
    end

    local target = output.stdout:gsub("\n$", "")
    local start, _ = target:find(":")
    if start then
        target = string.sub(target, 1, start - 1)
    end
    if target ~= "" then
        ya.emit(target:match("[/\\]$") and "cd" or "reveal", { target })
    end
end

return {
    setup = function(_, opts)
        _load_config(opts)
    end,
    entry = entry,
}

local function splitAndGetFirst(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local sepStart, sepEnd = string.find(inputstr, sep)
    if sepStart then
        return string.sub(inputstr, 1, sepStart - 1)
    end
    return inputstr
end

local state = ya.sync(function()
    return tostring(cx.active.current.cwd)
end)

local function fail(s, ...)
    ya.notify({ title = "Fzf", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function entry(_, args)
    local _permit = ya.hide()
    local cwd = tostring(state())

    local preview_cmd = [===[line={2} && begin=$( if [[ $line -lt 7 ]]; then echo $((line-1)); else echo 6; fi ) && bat --highlight-line {2} --number --color always --theme TwoDark --line-range $((line-begin)):$((line+10)) {1}]===]

    local child, err =
        Command("fzf"):args({
            "--ansi", "--disabled",
            "--bind", "start:reload:rg --column --line-number --no-heading --color=always --smart-case {q}",
            "--bind", "change:reload:sleep 0.1; rg --column --line-number --no-heading --color=always --smart-case {q} || true",
            "--delimiter", ":",
            "--preview", preview_cmd,
        }):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

    if not child then
        return fail("Spawn `fzf` failed with error code %s. Do you have it installed?", err)
    end

    local output, err = child:wait_with_output()
    if not output then
        return fail("Cannot read `fzf` output, error code %s", err)
    elseif not output.status.success and output.status.code ~= 130 then
        return fail("`fzf` exited with error code %s", output.status.code)
    end

    local target = output.stdout:gsub("\n$", "")
    target = splitAndGetFirst(target, ":")
    if target ~= "" then
        ya.manager_emit(target:match("[/\\]$") and "cd" or "reveal", { target })
    end
end

return { entry = entry }

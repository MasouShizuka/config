--- @sync entry

return {
    entry = function(_, job)
        local parent = cx.active.parent
        if not parent then
            return
        end

        local arg = job.args[1]
        if not arg then
            return
        end

        local target_index
        local step = 0
        if type(arg) == "number" then
            step = arg
        elseif type(arg) == "string" then
            if arg == "next" then
                step = 1
            elseif arg == "prev" then
                step = -1
            elseif arg == "top" then
                target_index = 1
            elseif arg == "bot" then
                target_index = #parent.files
            end
        end

        if target_index == nil then
            target_index = (parent.cursor + step) % #parent.files + 1
        end
        local target = parent.files[target_index]
        if target and target.cha.is_dir then
            ya.emit("cd", { target.url })
        end
    end,
}

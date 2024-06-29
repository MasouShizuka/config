return {
    entry = function(_, args)
        local current = cx.active.current
        if #current.files > 1 then
            local new = (current.cursor + args[1]) % #current.files
            ya.manager_emit("arrow", { new - current.cursor })
        end
    end,
}

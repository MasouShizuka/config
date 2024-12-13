--- @sync entry

return {
    entry = function(_, job)
        local current = cx.active.current
        if #current.files > 1 then
            local new = (current.cursor + job.args[1]) % #current.files
            ya.manager_emit("arrow", { new - current.cursor })
        end
    end,
}

--- @sync entry

return {
    entry = function(_, job)
        local current = cx.active.current
        if #current.files > 1 then
            local new = (current.cursor + job.args[1]) % #current.files
            ya.mgr_emit("arrow", { new - current.cursor })
        end
    end,
}

--- @sync entry

return {
    entry = function(_, job)
        local path
        if job.args[1] == "cwd" then
            local cwd = cx.active.current.cwd
            if cwd then
                path = tostring(cx.active.current.cwd):gsub("/", "\\")
            end
        else
            local h = cx.active.current.hovered.url
            if h then
                path = tostring(h):gsub("/", "\\")
            end
        end

        if path then
            ya.emit("shell", { string.format([[start "" "%s"]], path), orphan = true })
        end
    end,
}

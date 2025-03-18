--- @sync entry

return {
    entry = function(_, job)
        if job.args[1] == "cwd" then
            ya.mgr_emit("shell", { "nvim", confirm = true, block = true })
        else
            local h = cx.active.current.hovered
            if h then
                if h.cha.is_dir then
                    ya.mgr_emit("enter", { hovered = true })
                    ya.mgr_emit("shell", { "nvim", confirm = true, block = true })
                else
                    ya.mgr_emit("shell", { string.format([[nvim "%s"]], tostring(h.url):gsub("\\", "/")), confirm = true, block = true })
                end
            end
        end
    end,
}

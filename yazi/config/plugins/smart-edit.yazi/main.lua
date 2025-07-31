--- @sync entry

return {
    entry = function(_, job)
        if job.args[1] == "cwd" then
            ya.emit("shell", { "nvim", block = true })
        else
            local h = cx.active.current.hovered
            if h then
                if h.cha.is_dir then
                    ya.emit("enter", { hovered = true })
                    ya.emit("shell", { "nvim", block = true })
                else
                    ya.emit("shell", { string.format([[nvim "%s"]], tostring(h.url):gsub("\\", "/")), block = true })
                end
            end
        end
    end,
}

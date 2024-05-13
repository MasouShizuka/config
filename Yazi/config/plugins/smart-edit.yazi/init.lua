return {
    entry = function(_, args)
        if args[1] == "cwd" then
            ya.manager_emit("shell", { "nvim", confirm = true, block = true })
        else
            local h = cx.active.current.hovered
            if h and h.cha.is_dir then
                ya.manager_emit("enter", { hovered = true })
                ya.manager_emit("shell", { "nvim", confirm = true, block = true })
            else
                ya.manager_emit("shell", { string.format([[nvim "%s"]], tostring(h.url):gsub("\\", "/")), confirm = true, block = true })
            end
        end
    end,
}

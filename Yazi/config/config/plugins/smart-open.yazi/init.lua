return {
    entry = function(_, args)
        local path
        if args[1] == "cwd" then
            local cwd = cx.active.current.cwd
            if cwd then
                path = tostring(cx.active.current.cwd):gsub("/", "\\")
            end
        else
            local h = cx.active.current.hovered.url
            if h then
                path = tostring(h):gsub("\\", "/")
            end
        end

        if path then
            ya.manager_emit("shell", { string.format([[cmd /c start "" "%s"]], path), confirm = true, orphan = true })
        end
    end,
}
local sort_linemode_map = {
    created = "ctime",
    modified = "mtime",
    size = "size",
}

return {
    entry = function(_, args)
        local by = args[1]
        if not by then
            return
        end
        local reverse = false
        if args[2] then
            reverse = true
        end

        ya.manager_emit("sort", { by, reverse = reverse, dir_first = true })

        local linemode = sort_linemode_map[by]
        if linemode == nil then
            linemode = "none"
        end
        ya.manager_emit("linemode", { linemode })
    end,
}

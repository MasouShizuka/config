return {
    entry = function()
        local h = cx.active.current.hovered
        if h then
            if h.cha.is_dir then
                ya.manager_emit("enter", {})
            else
                ya.manager_emit("open", { hovered = true })
            end
        end
    end,
}

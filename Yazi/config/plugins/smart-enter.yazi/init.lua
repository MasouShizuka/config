return {
    entry = function()
        local h = cx.active.current.hovered
        if h then
            if h.cha.is_dir then
                ya.manager_emit("enter", {})
            else
                -- yazi 自带的 open 命令无法打开 windows 平台的带有特殊符号的文件，例如：&
                -- 因此，windows 平台使用 start 命令打开文件
                os.execute(string.format([[start "" "%s"]], tostring(h.url):gsub("/", "\\")))
            end
        end
    end,
}

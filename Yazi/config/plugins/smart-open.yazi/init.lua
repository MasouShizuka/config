-- NOTE: windows 平台 lua 调用 os.execute 时 encoding 为 ANSI，对应不同语言的版本
-- 若代码文件为 UTF-8 （或者说与 ANSI 不同），则 os.execute 传入的字符串可能产生乱码
-- 因此需要更改 windows 的区域设置，选中 "使用 Unicode UTF-8"
return {
    entry = function(_, args)
        if args[1] == "cwd" then
            os.execute(string.format([[start "" "%s"]], tostring(cx.active.current.cwd):gsub("/", "\\")))
        else
            local h = cx.active.current.hovered
            if h and h.cha.is_dir then
                os.execute(string.format([[start "" "%s"]], tostring(h.url):gsub("/", "\\")))
            else
                ya.manager_emit("open", { hovered = true })
            end
        end
    end,
}

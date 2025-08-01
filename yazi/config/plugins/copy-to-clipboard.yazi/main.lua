--- @sync entry

return {
    entry = function(_, job)
        local selected = cx.active.selected
        if selected and #selected > 0 then
            local files = ""
            for _, value in pairs(selected) do
                files = string.format("%s $files.Add('%s');", files, tostring(value))
            end

            ya.emit("shell", {
                string.format(
                    [[powershell -Command "$files = [System.Collections.Specialized.StringCollection]::new();%s Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::SetFileDropList($files);"]],
                    files
                ),
                orphan = true
            })
        else
            local h = cx.active.current.hovered.url
            if h then
                ya.emit("shell", {
                    string.format(
                        [[powershell -Command "$files = [System.Collections.Specialized.StringCollection]::new(); $files.Add('%s'); Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::SetFileDropList($files);"]],
                        tostring(h)
                    ),
                    orphan = true
                })
            end
        end
    end,
}

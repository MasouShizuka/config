GetCurrentMonitorIndex() {
    CoordMode, Mouse, Screen
    MouseGetPos, mx, my
    SysGet, monitorsCount, MonitorCount

    Loop, %monitorsCount% {
        SysGet, monitor, Monitor, %A_Index%
        if (monitorLeft <= mx && mx <= monitorRight && monitorTop <= my && my <= monitorBottom) {
            Return A_Index
        }
    }
    Return 1
}

GetClientSize(ByRef w, ByRef h) {
    DetectHiddenWindows On
    Gui, +LastFound
    Gui, Show, Hide
    hwnd := WinExist()
    DetectHiddenWindows Off

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rect)
    w := NumGet(rect, 8, "int")
    h := NumGet(rect, 12, "int")
}

CoordXCenterScreen(CurrentMonitorIndex) {
    SysGet, Mon, Monitor, %CurrentMonitorIndex%
    Return ((MonRight - MonLeft) / 2) + MonLeft
}

CoordYCenterScreen(CurrentMonitorIndex) {
    SysGet, Mon, Monitor, %CurrentMonitorIndex%
    Return ((MonBottom - MonTop) / 2) + MonTop
}

GetCurrentMonitorCenter(ByRef x, ByRef y) {
    CurrentMonitorIndex := GetCurrentMonitorIndex()
    x := CoordXCenterScreen(CurrentMonitorIndex)
    y := CoordYCenterScreen(CurrentMonitorIndex)
}

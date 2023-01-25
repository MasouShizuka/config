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

GetClientSize(hwnd, ByRef w, ByRef h) {
    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rect)
    w := NumGet(rect, 8, "int")
    h := NumGet(rect, 12, "int")
}

CoordXCenterScreen(GUI_Width, CurrentMonitorIndex) {
    SysGet, Mon, Monitor, %CurrentMonitorIndex%
    Return ((MonRight - MonLeft - GUI_Width) / 2) + MonLeft
}

CoordYCenterScreen(GUI_Height, CurrentMonitorIndex) {
    SysGet, Mon, Monitor, %CurrentMonitorIndex%
    Return ((MonBottom - MonTop - GUI_Height ) / 2) + MonTop
}

GetCurrentMonitorCenter(ByRef x, ByRef y) {
    CurrentMonitorIndex := GetCurrentMonitorIndex()

    DetectHiddenWindows On
    Gui, +LastFound
    Gui, Show, Hide
    GUI_Hwnd := WinExist()
    GetClientSize(GUI_Hwnd, GUI_Width, GUI_Height)
    DetectHiddenWindows Off

    x := CoordXCenterScreen(GUI_Width, CurrentMonitorIndex)
    y := CoordYCenterScreen(GUI_Height, CurrentMonitorIndex)
}

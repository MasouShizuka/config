GetCurrentMonitorIndex() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    monitorsCount := SysGet(80)

    loop (monitorsCount) {
        MonitorGetWorkArea(A_Index, &Left, &Top, &Right, &Bottom)
        if (Left <= mx && mx <= Right && Top <= my && my <= Bottom) {
            Return A_Index
        }
    }
    Return 1
}

CoordXCenterScreen(CurrentMonitorIndex) {
    MonitorGetWorkArea(CurrentMonitorIndex, &Left, &Top, &Right, &Bottom)
    Return ((Right - Left) / 2) + Left
}

CoordYCenterScreen(CurrentMonitorIndex) {
    MonitorGetWorkArea(CurrentMonitorIndex, &Left, &Top, &Right, &Bottom)
    Return ((Bottom - Top) / 2) + Top
}

GetCurrentMonitorCenter(&x, &y) {
    CurrentMonitorIndex := GetCurrentMonitorIndex()
    x := CoordXCenterScreen(CurrentMonitorIndex)
    y := CoordYCenterScreen(CurrentMonitorIndex)
}

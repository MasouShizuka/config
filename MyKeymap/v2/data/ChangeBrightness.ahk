#SingleInstance Force
#NoTrayIcon
SetWorkingDir(A_ScriptDir)
TraySetIcon("../bin/icons/logo.ico")

#Include ../bin/lib/Monitor.ahk
#Include ../bin/lib/Utils.ahk
#Include ./monitor_center.ahk

class CLayout extends Gui {
    monitors := []
    currentIndex := 1
    monCount := SysGet(80)
    monitorCol := Monitor()
    defaultGuiWidth := 440
    monitorIcoSize := 170

    __New() {
        super.__New()
        super.Opt("+AlwaysOnTop +Owner +LastFound +Resize -MinimizeBox -MaximizeBox")
        super.Title := "显示器亮度调节"
        this.InitMonitors()
        this.ChangeSelectedMonitor()

        ; 添加下方帮助信息
        super.SetFont("s12")
        ; modified
        ; super.Add("text", "x10 y190 w290 h20", "EDSF调节亮度、WR切换显示器、C退出")
        super.Add("text", "x10 y190 w290 h20", "WSAD调节亮度、QE切换显示器、X退出")
        super.Add("text", "x10 y210 w" this.defaultGuiWidth " h20", "如果不起作用，可能是因为使用的显示器没有开启DDC/CI功能")
    }

    ; 初始化已使用的显示器信息
    InitMonitors() {
        isWin10 := StrCompare(A_OSVersion, "10.0.22000") < 0

        ; 获取已使用的显示器数量
        loop this.monCount {
            monIndex := A_Index
            ; 获取显示器当前亮度
            brightness := this.getBrightness(monIndex)

            ; 计算MonIcoText要显示的位置
            ; 当显示器图标无法沾满窗口默认大小时,让显示器图标剧中
            padding := 0
            if (this.monitorIcoSize * this.monCount < this.defaultGuiWidth) {
                padding := (this.defaultGuiWidth - (this.monitorIcoSize * this.monCount)) / 2
            }
            x := this.monitorIcoSize * (monIndex - 1) + padding
            monIco := super.Add("Text", "x" x " y0 w" this.monitorIcoSize " h" this.monitorIcoSize " 0x1", "🖥️")
            monIco.SetFont("s128 c000000")

            y := 52
            ; 是 Windows 10 则使用不同的 y 坐标
            if isWin10 {
                y := 66
            }

            ; 计算显示器亮度要显示的位置
            x := x + 52
            monBrightness := super.Add("Text", "x" x " y" y " w65 h40 0x1", brightness)
            monBrightness.SetFont("s32 cffffff")
            monBrightness.Opt("+BackgroundTrans")

            ; 将当前控件保存起来
            m := Map()
            m["ico"] := monIco
            m["brightness"] := monBrightness
            this.monitors.Push(m)
        }
    }

    ; 修改界面上的当前显示器
    ChangeSelectedMonitor(old := 1) {
        m := this.monitors.Get(old)
        m["ico"].SetFont("c000000")

        m := this.monitors.Get(this.currentIndex)
        m["ico"].SetFont("cff6688")
    }

    ; 上一个显示屏
    Previous() {
        if (this.currentIndex > 1) {
            this.changeSelectedMonitor(this.currentIndex--)
        }
    }

    ; 下一个显示屏
    Next() {
        if (this.currentIndex < this.monCount) {
            this.changeSelectedMonitor(this.currentIndex++)
        }
    }

    ; 加亮度
    IncBrightness(mon) {
        m := this.monitors.Get(this.currentIndex)
        val := m["brightness"].Value + mon
        if (val <= 100) {
            this.SetBrightness(val, this.currentIndex)
            m["brightness"].Value := val
        }
    }

    ; 减亮度
    DecBrightness(mon) {
        m := this.monitors.Get(this.currentIndex)
        val := m["brightness"].Value - mon
        if (val >= 0) {
            this.SetBrightness(val, this.currentIndex)
            m["brightness"].Value := val
        }
    }

    ; 显示GUI
    ShowGui() {
        ; modified
        ; super.Show()
        if (this.monitorIcoSize * this.monCount < this.defaultGuiWidth) {
            w := this.defaultGuiWidth
        } else {
            w := this.monitorIcoSize * this.monCount
        }
        h := 230
        GetCurrentMonitorCenter(&cx, &cy)
        x := cx - w / 2
        y := cy - h / 2
        super.Show(Format("w{} h{} x{} y{}", w, h, x, y))
        disableIME(super.Hwnd)
    }

    ; 获取屏幕亮度
    GetBrightness(monIndex) {
        brightness := ""
        try {
            brightness := this.monitorCol.GetBrightness(monIndex)["Current"]
        } catch Error as e {
            ; 使用wmi获取亮度
            For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
                brightness := property.CurrentBrightness
        }

        return brightness
    }

    ; 设置屏幕亮度
    SetBrightness(brightness, monIndex, timeout := 1) {
        try {
            this.monitorCol.setBrightness(brightness, monIndex)
        } catch Error as e {
            ; 使用wmi设置亮度
            For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
                property.WmiSetBrightness(timeout, brightness)
        }
    }
}

layout := CLayout()
layout.ShowGui()

SetTimer(IfLoseFocusThenExit, 100)
IfLoseFocusThenExit() {
    if ( not WinActive("ahk_id" layout.Hwnd)) {
        ExitApp
    }
}

OnMessage(0x100, WM_KEYDOWN)
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    switch (GetKeyName(Format("vk{:x}", wparam))) {
        ; modified
        ; case "w": layout.Previous()
        ; case "r": layout.Next()
        ; case "e": layout.IncBrightness(10)
        ; case "f": layout.IncBrightness(5)
        ; case "d": layout.DecBrightness(10)
        ; case "s": layout.DecBrightness(5)
        ; case "c": ExitApp
        case "q": layout.Previous()
        case "e": layout.Next()
        case "w": layout.IncBrightness(10)
        case "d": layout.IncBrightness(5)
        case "s": layout.DecBrightness(10)
        case "a": layout.DecBrightness(5)
        case "x": ExitApp
        case "Escape": ExitApp
    }

    return 0
}
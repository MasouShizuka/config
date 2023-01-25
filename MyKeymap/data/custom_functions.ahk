; 自定义的函数写在这个文件里,  然后能在 MyKeymap 中调用

sendSomeChinese() {
    send, {text}你好中文!
}

center_window() {
    If (!WinExist("A")) {
        Return
    }

    WinGetPos, X, Y, W, H
    CX := X + W / 2
    CY := Y + H / 2

    SysGet, MonitorCount, MonitorCount
    Loop, %MonitorCount% {
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
        If (CX >= MonitorWorkAreaLeft && CX <= MonitorWorkAreaRight && CY >= MonitorWorkAreaTop && CY <= MonitorWorkAreaBottom) {
            MW := (MonitorWorkAreaRight - MonitorWorkAreaLeft)
            MH := (MonitorWorkAreaBottom - MonitorWorkAreaTop)

            WinMove, MonitorWorkAreaLeft + (MW - W) / 2, MonitorWorkAreaTop + (MH - H) / 2
            Break
        }
    }
}

close_or_run_script(path) {
    StringReplace, path, path, /, \, All
    SplitPath, path, name

    DetectHiddenWindows On
    SetTitleMatchMode RegEx
    running_script := "i)" . name . ".* ahk_class AutoHotkey"
    If (WinExist(running_script)) {
        WinClose
        WinWaitClose, running_script, , 2
    } Else {
        Run, bin/ahk.exe %path%
    }
    DetectHiddenWindows Off
}

enter_mouse_mode() {
    global SLOWMODE
    SLOWMODE := true
    If (MouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    MouseMovePrompt.show("🖱️", 19, 17)
}

exit_mouse_mode() {
    global SLOWMODE
    global VERYSLOWMODE
    SLOWMODE := false
    VERYSLOWMODE := false
    Send, {Blind}{LButton Up}
    If (MouseMovePrompt) {
        MouseMovePrompt.hide()
    }
}

left_click_down() {
    Send, {Blind}{LButton Down}
}

left_click_up() {
    global SLOWMODE
    Send, {Blind}{LButton Up}
    SLOWMODE := false
    If (MouseMovePrompt) {
        MouseMovePrompt.hide()
    }
}

left_click_down_without_false() {
    Send, {Blind}{LButton Down}
}

left_click_up_without_false() {
    Send, {Blind}{LButton Up}
}

right_click_down(tempDisableRButton := false) {
    global SLOWMODE
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Down}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Down}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
}

right_click_up(tempDisableRButton := false) {
    global SLOWMODE
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Up}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Up}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
    If (MouseMovePrompt) {
        MouseMovePrompt.hide()
    }
}

right_click_down_without_false(tempDisableRButton := false) {
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Down}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Down}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

right_click_up_without_false(tempDisableRButton := false) {
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Up}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Up}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

fast_move_mouse(key, direction_x, direction_y) {
    global fastMoveSingle, fastMoveRepeat, moveDelay1, moveDelay2, SLOWMODE
    SLOWMODE := true
    one_x := direction_x *fastMoveSingle
    one_y := direction_y *fastMoveSingle
    repeat_x := direction_x *fastMoveRepeat
    repeat_y := direction_y *fastMoveRepeat
    MouseMove, %one_x% , %one_y%, 0, R
    If (MouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    MouseMovePrompt.show("🖱️", 19, 17)
    KeyWait, %key%, %moveDelay1%
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        If (MouseMovePrompt) {
            MouseMovePrompt.show("🖱️", 19, 17)
        }
        KeyWait, %key%, %moveDelay2%
    }
}

slow_move_mouse(key, direction_x, direction_y) {
    global slowMoveSingle, slowMoveRepeat, moveDelay1, moveDelay2
    one_x := direction_x * slowMoveSingle
    one_y := direction_y * slowMoveSingle
    repeat_x := direction_x * slowMoveRepeat
    repeat_y := direction_y * slowMoveRepeat
    MouseMove, %one_x% , %one_y%, 0, R
    If (MouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    MouseMovePrompt.show("🖱️", 19, 17)
    KeyWait, %key%, %moveDelay1%
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        if (MouseMovePrompt) {
            MouseMovePrompt.show("🖱️", 19, 17)
        }
        KeyWait, %key%, %moveDelay2%
    }
}

very_slow_move_mouse(key, direction_x, direction_y) {
    global moveDelay1, moveDelay2, VERYSLOWMODE
    VERYSLOWMODE := true
    one_x := direction_x
    one_y := direction_y
    repeat_x := direction_x
    repeat_y := direction_y
    MouseMove, %one_x% , %one_y%, 0, R
    If (MouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    MouseMovePrompt.show("🖱️", 19, 17)
    KeyWait, %key%, %moveDelay1%
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        If (MouseMovePrompt) {
            MouseMovePrompt.show("🖱️", 19, 17)
        }
        KeyWait, %key%, %moveDelay2%
    }
}

turn_off_monitor() {
    Sleep, 1000
    SendMessage 0x112, 0xF170, 2, , Program Manager
}

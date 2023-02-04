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



show_mouse_move_prompt() {
    If (MouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
        MouseMovePrompt.show("🖱️", 19, 17)
    }
}

hide_mouse_move_prompt() {
    global SLOWMODE := false
    global VERYSLOWMODE := false

    If (MouseMovePrompt) {
        MouseMovePrompt.hide()
    }
}

enter_mouse_mode() {
    global SLOWMODE := true
    show_mouse_move_prompt()
}

exit_mouse_mode() {
    Send, {Blind}{LButton Up}
    hide_mouse_move_prompt()
}

left_click_down() {
    Send, {Blind}{LButton Down}
}

left_click_up_without_hide_mouse_move_prompt() {
    Send, {Blind}{LButton Up}
}

left_click_up() {
    left_click_up_without_hide_mouse_move_prompt()
    hide_mouse_move_prompt()
}

right_click_down(tempDisableRButton := false) {
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Down}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Down}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

right_click_up_without_hide_mouse_move_prompt(tempDisableRButton := false) {
    If (!tempDisableRButton) {
        Send, {Blind}{RButton Up}
    } Else {
        setHotkeyStatus("RButton", false)
        Send, {Blind}{RButton Up}
        Sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

right_click_up(tempDisableRButton := false) {
    right_click_up_without_hide_mouse_move_prompt()
    hide_mouse_move_prompt()
}

middle_click_down() {
    Send, {Blind}{MButton Down}
}

middle_click_up_without_hide_mouse_move_prompt() {
    Send, {Blind}{MButton Up}
}

middle_click_up() {
    middle_click_up_without_hide_mouse_move_prompt()
    hide_mouse_move_prompt()
}

fast_move_mouse(key, direction_x, direction_y) {
    global fastMoveSingle, fastMoveRepeat, moveDelay1, moveDelay2, SLOWMODE
    SLOWMODE := true

    one_x := direction_x *fastMoveSingle
    one_y := direction_y *fastMoveSingle
    MouseMove, %one_x% , %one_y%, 0, R
    show_mouse_move_prompt()
    KeyWait, %key%, %moveDelay1%

    repeat_x := direction_x *fastMoveRepeat
    repeat_y := direction_y *fastMoveRepeat
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        show_mouse_move_prompt()
        KeyWait, %key%, %moveDelay2%
    }
}

slow_move_mouse(key, direction_x, direction_y) {
    global slowMoveSingle, slowMoveRepeat, moveDelay1, moveDelay2

    one_x := direction_x * slowMoveSingle
    one_y := direction_y * slowMoveSingle
    MouseMove, %one_x% , %one_y%, 0, R
    show_mouse_move_prompt()
    KeyWait, %key%, %moveDelay1%

    repeat_x := direction_x * slowMoveRepeat
    repeat_y := direction_y * slowMoveRepeat
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        show_mouse_move_prompt()
        KeyWait, %key%, %moveDelay2%
    }
}

very_slow_move_mouse(key, direction_x, direction_y) {
    global moveDelay1, moveDelay2, VERYSLOWMODE
    VERYSLOWMODE := true

    one_x := direction_x
    one_y := direction_y
    MouseMove, %one_x% , %one_y%, 0, R
    show_mouse_move_prompt()
    KeyWait, %key%, %moveDelay1%

    repeat_x := direction_x
    repeat_y := direction_y
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        show_mouse_move_prompt()
        KeyWait, %key%, %moveDelay2%
    }
}



global is_taskbar_hide := false

hide_taskbar() {
    If (is_taskbar_hide) {
        WinSet, Transparent, 255, ahk_class Shell_TrayWnd
        WinSet, Transparent, OFF, ahk_class Shell_TrayWnd
    } Else {
        WinSet, Transparent, 0, ahk_class Shell_TrayWnd
    }
    is_taskbar_hide := !is_taskbar_hide
}



is_EN(title:="A") {
    WinGet, hwnd, ID, A

    DetectHiddenWindows, On
    pid := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "UInt", 0)
    keyboard_layout := DllCall("GetKeyboardLayout", "UInt", pid, "UInt")
    DetectHiddenWindows, Off

    return keyboard_layout == 0x04090409
}

set_IME_language(language) {
    If (language == "CN") {
        keyboard_identifier := 0x08040804
    } Else {
        keyboard_identifier := 0x04090409
    }

    WinExist("A")
    ControlGetFocus, cgf
    PostMessage, 0x50, 0, %keyboard_identifier%, %cgf%
}

switch_IME() {
    is_EN := is_EN()
    If (is_EN) {
        set_IME_language("CN")
    } Else {
        set_IME_language("EN")
    }
}



turn_off_monitor() {
    Sleep, 1000
    SendMessage 0x112, 0xF170, 2, , Program Manager
}

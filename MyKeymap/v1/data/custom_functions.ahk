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


close_or_run_script(path, args:= "") {
    StringReplace, path, path, /, \, All
    SplitPath, path, name

    DetectHiddenWindows On
    SetTitleMatchMode RegEx
    running_script := "i)" . name . ".* ahk_class AutoHotkey"
    If (WinExist(running_script)) {
        WinClose
        WinWaitClose, running_script, , 2
    } Else {
        cmd := "bin/ahk.exe " . path . " " . args
        Run, %cmd%
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
    If (MouseMovePrompt) {
        MouseMovePrompt.hide()
    }
}

enter_mouse_mode() {
    global SLOWMODE := true
    show_mouse_move_prompt()
}

exit_mouse_mode() {
    global SLOWMODE := false, VERYSLOWMODE := false
    hide_mouse_move_prompt()
}

exit_mouse_mode_with_left_click_up() {
    exit_mouse_mode()
    Send, {Blind}{LButton Up}
}

left_click_down() {
    Send, {Blind}{LButton Down}
}

left_click_up_without_hide_mouse_move_prompt() {
    Send, {Blind}{LButton Up}
}

left_click_up() {
    left_click_up_without_hide_mouse_move_prompt()
    exit_mouse_mode()
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
    exit_mouse_mode()
}

middle_click_down() {
    Send, {Blind}{MButton Down}
}

middle_click_up_without_hide_mouse_move_prompt() {
    Send, {Blind}{MButton Up}
}

middle_click_up() {
    middle_click_up_without_hide_mouse_move_prompt()
    exit_mouse_mode()
}

move_mouse(key, direction := "left", mode := "fast") {
    global moveDelay1, moveDelay2

    direction_x := 0
    direction_y := 0
    If (direction == "up") {
        direction_y := -1
    } Else If (direction == "down") {
        direction_y := 1
    } Else If (direction == "left") {
        direction_x := -1
    } Else If (direction == "right") {
        direction_x := 1
    }

    move_single := 0
    move_repeat := 0
    If (mode == "fast") {
        global fastMoveSingle, fastMoveRepeat, SLOWMODE := true
        move_single := fastMoveSingle
        move_repeat := fastMoveRepeat
    } Else If (mode == "slow") {
        global slowMoveSingle, slowMoveRepeat, VERYSLOWMODE := false
        move_single := slowMoveSingle
        move_repeat := slowMoveRepeat
    } Else If (mode == "veryslow") {
        global SLOWMODE := false, VERYSLOWMODE := true
        move_single := 1
        move_repeat := 1
    }

    single_x := direction_x * move_single
    single_y := direction_y * move_single
    MouseMove, %single_x% , %single_y%, 0, R
    show_mouse_move_prompt()
    KeyWait, %key%, %moveDelay1%

    repeat_x := direction_x * move_repeat
    repeat_y := direction_y * move_repeat
    While, errorlevel != 0 {
        MouseMove, %repeat_x%, %repeat_y%, 0, R
        show_mouse_move_prompt()
        KeyWait, %key%, %moveDelay2%
    }
}


is_taskbar_hide := false

hide_taskbar() {
    global is_taskbar_hide
    If (is_taskbar_hide) {
        WinSet, Transparent, 255, ahk_class Shell_TrayWnd
        WinSet, Transparent, OFF, ahk_class Shell_TrayWnd
    } Else {
        WinSet, Transparent, 0, ahk_class Shell_TrayWnd
    }
    is_taskbar_hide := !is_taskbar_hide
}


keyboard_layout_list := [0x04090409, 0x08040804]

get_keyboard_layout(title:="A") {
    WinGet, hwnd, ID, A

    DetectHiddenWindows, On
    pid := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "UInt", 0)
    keyboard_layout := DllCall("GetKeyboardLayout", "UInt", pid, "UInt")
    DetectHiddenWindows, Off

    return keyboard_layout
}

set_keyboard_layout(keyboard_layout) {
    WinExist("A")
    ControlGetFocus, cgf
    PostMessage, 0x50, 0, %keyboard_layout%, %cgf%
}

switch_IME() {
    current_index := 0
    current_keyboard_layout := get_keyboard_layout()
    For index, keyboard_layout in keyboard_layout_list {
        If (keyboard_layout == current_keyboard_layout) {
            current_index = index
            Break
        }
    }

    index := current_index + 1
    If (index > keyboard_layout_list.Length()) {
        index := 1
    }
    set_keyboard_layout(keyboard_layout_list[index])
}


turn_off_monitor() {
    Sleep, 1000
    SendMessage 0x112, 0xF170, 2, , Program Manager
}

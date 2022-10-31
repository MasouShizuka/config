; 自定义的函数写在这个文件里



sendChinese() {
    send, {text}你好中文!
}

center_window() {
    WinExist("A")
    WinGetPos, , , sizeX, sizeY
    WinMove, (A_ScreenWidth / 2) - (sizeX / 2), (A_ScreenHeight / 2) - (sizeY / 2)
}

close_or_run_script(name, path:="") {
    DetectHiddenWindows On
    SetTitleMatchMode RegEx
    running_script := "i)" . name . ".* ahk_class AutoHotkey"
    if (WinExist(running_script)) {
        WinClose
        WinWaitClose, running_script, , 2
    } else {
        if (path == "") {
            path := "bin/custom/" . name
        }
        run, bin/ahk.exe %path%
    }
}

enter_mouse_mode() {
    global SLOWMODE
    SLOWMODE := true
    if (mouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    mouseMovePrompt.show("🖱️", 19, 17)
}

left_click_down() {
    send, {blind}{LButton Down}
}

left_click_up() {
    global SLOWMODE
    send, {blind}{LButton Up}
    SLOWMODE := false
    if (mouseMovePrompt) {
        mouseMovePrompt.hide()
    }
}

left_click_down_without_false() {
    send, {blind}{LButton Down}
}

left_click_up_without_false() {
    send, {blind}{LButton Up}
}

right_click_down(tempDisableRButton := false) {
    global SLOWMODE
    if (!tempDisableRButton) {
        send, {blind}{RButton Down}
    } else {
        setHotkeyStatus("RButton", false)
        send, {blind}{RButton Down}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
}

right_click_up(tempDisableRButton := false) {
    global SLOWMODE
    if (!tempDisableRButton) {
        send, {blind}{RButton Up}
    } else {
        setHotkeyStatus("RButton", false)
        send, {blind}{RButton Up}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
    if (mouseMovePrompt) {
        mouseMovePrompt.hide()
    }
}

right_click_down_without_false(tempDisableRButton := false) {
    if (!tempDisableRButton) {
        send, {blind}{RButton Down}
    } else {
        setHotkeyStatus("RButton", false)
        send, {blind}{RButton Down}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

right_click_up_without_false(tempDisableRButton := false) {
    if (!tempDisableRButton) {
        send, {blind}{RButton Up}
    } else {
        setHotkeyStatus("RButton", false)
        send, {blind}{RButton Up}
        sleep, 70
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
    mousemove, %one_x% , %one_y%, 0, R
    if (mouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0) {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if (mouseMovePrompt) {
            mouseMovePrompt.show("🖱️", 19, 17)
        }
        keywait, %key%, %moveDelay2%
    }
}

slow_move_mouse(key, direction_x, direction_y) {
    global slowMoveSingle, slowMoveRepeat, moveDelay1, moveDelay2
    one_x := direction_x * slowMoveSingle
    one_y := direction_y * slowMoveSingle
    repeat_x := direction_x * slowMoveRepeat
    repeat_y := direction_y * slowMoveRepeat
    mousemove, %one_x% , %one_y%, 0, R
    if (mouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0) {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if (mouseMovePrompt) {
            mouseMovePrompt.show("🖱️", 19, 17)
        }
        keywait, %key%, %moveDelay2%
    }
}

very_slow_move_mouse(key, direction_x, direction_y) {
    global moveDelay1, moveDelay2, VERYSLOWMODE
    VERYSLOWMODE := true
    one_x := direction_x
    one_y := direction_y
    repeat_x := direction_x
    repeat_y := direction_y
    mousemove, %one_x% , %one_y%, 0, R
    if (mouseMovePrompt) {
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
    }
    mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0) {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if (mouseMovePrompt) {
            mouseMovePrompt.show("🖱️", 19, 17)
        }
        keywait, %key%, %moveDelay2%
    }
}

exit_mouse_mode() {
    global SLOWMODE
    global VERYSLOWMODE
    SLOWMODE := false
    VERYSLOWMODE := false
    send {blind}{Lbutton up}
    if (mouseMovePrompt) {
        mouseMovePrompt.hide()
    }
}

turn_off_monitor() {
    sleep, 1000
    sendmessage 0x112, 0xF170, 2, , Program Manager
}

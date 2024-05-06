#Include ../bin/lib/InputTipWindow.ahk
#Include ../bin/lib/Functions.ahk

; 自定义的函数写在这个文件里,  然后能在 MyKeymap 中调用

sendSomeChinese() {
    Send("{text}你好中文!")
}


; IME

keyboard_layout_list := [0x04090409, 0x08040804]

get_keyboard_layout(title := "A") {
    try {
        hwnd := WinGetID("A")

        DetectHiddenWindows(true)
        pid := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "UInt", 0)
        keyboard_layout := DllCall("GetKeyboardLayout", "UInt", pid, "UInt")
        DetectHiddenWindows(false)

        return keyboard_layout
    }
}

set_keyboard_layout(keyboard_layout) {
    If (WinExist("A")) {
        cgf := ControlGetFocus("A")
        If (cgf) {
            PostMessage(0x50, 0, keyboard_layout, cgf)
        } Else {
            PostMessage(0x50, 0, keyboard_layout, , "A")
        }
    }
}

switch_IME() {
    current_index := 0
    current_keyboard_layout := get_keyboard_layout()
    For index, keyboard_layout in keyboard_layout_list {
        If (keyboard_layout == current_keyboard_layout) {
            current_index := index
            Break
        }
    }

    index := current_index + 1
    If (index > keyboard_layout_list.Length) {
        index := 1
    }
    set_keyboard_layout(keyboard_layout_list[index])
}


; Monitor

turn_off_monitor() {
    Sleep(1000)
    SendMessage(0x112, 0xF170, 2, , "Program Manager")
}


; Mouse

MouseMovePrompt := InputTipWindow("🖱️")
FASTMODE := false
SLOWMODE := false
VERYSLOWMODE := false
fastMoveSingle := 60
fastMoveRepeat := 60
slowMoveSingle := 10
slowMoveRepeat := 10
moveDelay1 := "T0.1"
moveDelay2 := "T0.01"
scrollOnceLineCount := 1
scrollDelay1 := "T0.2"
scrollDelay2 := "T0.03"

show_mouse_move_prompt() {
    If (WinExist("ahk_class AutoHotkeyGUI")) {
        WinSetAlwaysOnTop(true, "ahk_class AutoHotkeyGUI")
    }
    global MouseMovePrompt
    MouseMovePrompt.show("")
}

hide_mouse_move_prompt() {
    global MouseMovePrompt
    MouseMovePrompt.hide()
}

enter_mouse_mode() {
    global SLOWMODE := true
    show_mouse_move_prompt()
}

exit_mouse_mode() {
    global FASTMODE := false, SLOWMODE := false, VERYSLOWMODE := false
    hide_mouse_move_prompt()
}

exit_mouse_mode_with_left_click_up() {
    exit_mouse_mode()
    Send("{Blind}{LButton Up}")
}

click_down(button := "L") {
    Send("{Blind}{" . button . "Button Down}")
}

click_up_without_hide_mouse_move_prompt(button := "L") {
    Send("{Blind}{" . button . "Button Up}")
}

click_up(button := "L") {
    click_up_without_hide_mouse_move_prompt(button)
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
        global fastMoveSingle, fastMoveRepeat, FASTMODE := true, SLOWMODE := false, VERYSLOWMODE := false
        move_single := fastMoveSingle
        move_repeat := fastMoveRepeat
    } Else If (mode == "slow") {
        global slowMoveSingle, slowMoveRepeat, FASTMODE := false, VERYSLOWMODE := false
        move_single := slowMoveSingle
        move_repeat := slowMoveRepeat
    } Else If (mode == "veryslow") {
        global FASTMODE := false, SLOWMODE := false, VERYSLOWMODE := true
        move_single := 1
        move_repeat := 1
    }

    single_x := direction_x * move_single
    single_y := direction_y * move_single
    MouseMove(single_x, single_y, 0, "R")
    show_mouse_move_prompt()
    errorlevel := KeyWait(key, moveDelay1)

    repeat_x := direction_x * move_repeat
    repeat_y := direction_y * move_repeat
    While (!errorlevel) {
        MouseMove(repeat_x, repeat_y, 0, "R")
        show_mouse_move_prompt()
        errorlevel := KeyWait(key, moveDelay2)
    }
}

scroll_wheel(key, direction) {
    global scrollOnceLineCount, scrollDelay1, scrollDelay2

    WhichButton := ""
    If (direction == "up") {
        WhichButton := "WheelUp"
    } Else If (direction == "down") {
        WhichButton := "WheelDown"
    } Else If (direction == "left") {
        WhichButton := "WheelLeft"
    } Else If (direction == "right") {
        WhichButton := "WheelRight"
    }
    MouseClick(WhichButton, , , scrollOnceLineCount)
    errorlevel := keywait(key, scrollDelay1)

    while (!errorlevel) {
        MouseClick(WhichButton, , , scrollOnceLineCount)
        errorlevel := keywait(key, scrollDelay2)
    }
}


; Script

close_or_run_script(path, args := "") {
    path := StrReplace(path, "/", "\")
    SplitPath(path, &name)

    DetectHiddenWindows(true)
    SetTitleMatchMode("RegEx")
    running_script := "i)" . name . ".* ahk_class AutoHotkey"
    If (WinExist(running_script)) {
        WinClose
        WinWaitClose(running_script, , 2)
    } Else {
        cmd := "MyKeymap.exe " . path . " " . args
        RunWait(cmd)
    }
    DetectHiddenWindows(false)
}


; Taskbar

is_taskbar_hide := false

hide_taskbar() {
    global is_taskbar_hide
    If (is_taskbar_hide) {
        WinSetTransparent(255, "ahk_class Shell_TrayWnd")
        WinSetTransparent("Off", "ahk_class Shell_TrayWnd")
    } Else {
        WinSetTransparent(0, "ahk_class Shell_TrayWnd")
    }
    is_taskbar_hide := !is_taskbar_hide
}


; Window

center_window() {
    If (!WinExist("A")) {
        Return
    }

    WinGetPos(&X, &Y, &W, &H)
    CX := X + W / 2
    CY := Y + H / 2

    MonitorCount := SysGet(80)
    Loop (MonitorCount) {
        MonitorGetWorkArea(A_Index, &Left, &Top, &Right, &Bottom)
        If (CX >= Left && CX <= Right && CY >= Top && CY <= Bottom) {
            MW := (Right - Left)
            MH := (Bottom - Top)

            WinMove(Left + (MW - W) / 2, Top + (MH - H) / 2)
            Break
        }
    }
}

change_window_size(direction := "left", size := 40) {
    WinGetPos(&x, &y, &w, &h, "A")
    If (direction == "up") {
        h := h - size
    } Else If (direction == "down") {
        h := h + size
    } Else If (direction == "left") {
        w := w - size
    } Else If (direction == "right") {
        w := w + size
    }
    WinMove(x, y, w, h, "A")
}


; Map

*CapsLock Up:: {
    If (A_PriorKey == "CapsLock" && A_TimeSinceThisHotkey < 500) {
        Send("{Blind}{Esc}")
    }
}

#HotIf FASTMODE
*CapsLock Up:: {
    global FASTMODE := false
    global SLOWMODE := true
}
#HotIf

#HotIf GetKeyState("Capslock", "P") && GetKeyState("Alt", "P")
*W:: change_window_size("up", 60)
*S:: change_window_size("down", 60)
*A:: change_window_size("left", 60)
*D:: change_window_size("right", 60)
*I:: move_mouse("I", "up", "veryslow")
*J:: move_mouse("J", "left", "veryslow")
*K:: move_mouse("K", "down", "veryslow")
*L:: move_mouse("L", "right", "veryslow")
#HotIf

#HotIf GetKeyState("Capslock", "P")
*I:: move_mouse("I", "up", "fast")
*J:: move_mouse("J", "left", "fast")
*K:: move_mouse("K", "down", "fast")
*L:: move_mouse("L", "right", "fast")
*U:: scroll_wheel("U", "up")
*H:: scroll_wheel("H", "left")
*O:: scroll_wheel("O", "down")
*`;:: scroll_wheel(";", "right")
*N:: click_down("L")
*N Up:: click_up("L")
*M:: click_down("R")
*M Up:: click_up("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up("M")
*/:: MakeWindowDraggable()
#HotIf

#HotIf SLOWMODE
*W:: change_window_size("up", 10)
*S:: change_window_size("down", 10)
*A:: change_window_size("left", 10)
*D:: change_window_size("right", 10)
*I:: move_mouse("I", "up", "slow")
*J:: move_mouse("J", "left", "slow")
*K:: move_mouse("K", "down", "slow")
*L:: move_mouse("L", "right", "slow")
*U:: scroll_wheel("U", "up")
*H:: scroll_wheel("H", "left")
*O:: scroll_wheel("O", "down")
*`;:: scroll_wheel(";", "right")
*N:: click_down("L")
*N Up:: click_up_without_hide_mouse_move_prompt("L")
*M:: click_down("R")
*M Up:: click_up_without_hide_mouse_move_prompt("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up_without_hide_mouse_move_prompt("M")
*/:: MakeWindowDraggable()
*Esc:: exit_mouse_mode_with_left_click_up()
*Space:: exit_mouse_mode()
*CapsLock Up:: {
    If (A_PriorKey == "CapsLock" && A_TimeSinceThisHotkey < 500) {
        exit_mouse_mode_with_left_click_up()
    }
}
#HotIf

#HotIf VERYSLOWMODE
*W:: change_window_size("up", 1)
*S:: change_window_size("down", 1)
*A:: change_window_size("left", 1)
*D:: change_window_size("right", 1)
*I:: move_mouse("I", "up", "veryslow")
*J:: move_mouse("J", "left", "veryslow")
*K:: move_mouse("K", "down", "veryslow")
*L:: move_mouse("L", "right", "veryslow")
*U:: scroll_wheel("U", "up")
*H:: scroll_wheel("H", "left")
*O:: scroll_wheel("O", "down")
*`;:: scroll_wheel(";", "right")
*N:: click_down("L")
*N Up:: click_up_without_hide_mouse_move_prompt("L")
*M:: click_down("R")
*M Up:: click_up_without_hide_mouse_move_prompt("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up_without_hide_mouse_move_prompt("M")
*/:: MakeWindowDraggable()
*Esc:: exit_mouse_mode_with_left_click_up()
*Space:: exit_mouse_mode()
*CapsLock Up:: {
    If (A_PriorKey == "CapsLock" && A_TimeSinceThisHotkey < 500) {
        exit_mouse_mode_with_left_click_up()
    }
}
#HotIf

#Include ../bin/lib/Functions.ahk
#Include ../bin/lib/InputTipWindow.ahk
#Include ../bin/lib/KeymapManager.ahk

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


; Script

close_or_run_script(path, args := "") {
    path := StrReplace(path, "/", "\")
    SplitPath(path, &name)

    DetectHiddenWindows(true)
    SetTitleMatchMode("RegEx")
    running_script := name . " ahk_class AutoHotkey"
    If (WinExist(running_script)) {
        WinClose
        WinWaitClose(running_script, , 2)
    } Else {
        cmd := "MyKeymap.exe " . path . " " . args
        RunWait(cmd)
    }
    DetectHiddenWindows(false)
}


; Task Switch

task_switch() {
    Send("^!{tab}")
    KeymapManager.SetLockRequest(TaskSwitchKeymap("w", "s", "a", "d", "x", "space"), false, false)
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
        If (CX >= Left and CX <= Right and CY >= Top and CY <= Bottom) {
            MW := (Right - Left)
            MH := (Bottom - Top)

            WinMove(Left + (MW - W) / 2, Top + (MH - H) / 2)
            Break
        }
    }
}


; Map

global mouse_direction := Map(
    "up", "i",
    "down", "k",
    "left", "j",
    "right", "l",
)

global scroll_direction := Map(
    "up", "u",
    "down", "o",
    "left", "y",
    "right", "p",
)

global window_direction := Map(
    "up", "w",
    "down", "s",
    "left", "a",
    "right", "d",
)

FASTMODE := false
SLOWMODE := false
VERYSLOWMODE := false

global MouseMovePrompt := InputTipWindow("🖱️")

global fast_move_single := 60
global fast_move_repeat := 60
global slow_move_single := 10
global slow_move_repeat := 10
global move_delay1 := "T0.1"
global move_delay2 := "T0.01"

global click_count := 1
global scroll_delay1 := "T0.2"
global scroll_delay2 := "T0.03"

global fast_resize_delta := 40
global slow_resize_delta := 10

show_mouse_move_prompt() {
    If (WinExist("ahk_class AutoHotkeyGUI")) {
        WinSetAlwaysOnTop(true, "ahk_class AutoHotkeyGUI")
    }
    MouseMovePrompt.show("")
}

hide_mouse_move_prompt() {
    MouseMovePrompt.hide()
}

enter_mouse_mode() {
    global SLOWMODE := true
    show_mouse_move_prompt()
}

exit_mouse_mode() {
    global FASTMODE := false
    global SLOWMODE := false
    global VERYSLOWMODE := false
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

get_mouse_move_state() {
    x := 0
    y := 0

    If (GetKeyState(mouse_direction["left"], "P") || GetKeyState(mouse_direction["right"], "P")) {
        If (GetKeyState(mouse_direction["left"], "P")) {
            x := -1
        } Else {
            x := 1
        }
    }

    If (GetKeyState(mouse_direction["up"], "P") || GetKeyState(mouse_direction["down"], "P")) {
        If (GetKeyState(mouse_direction["up"], "P")) {
            y := -1
        } Else {
            y := 1
        }
    }

    return {x: x, y: y}
}

move_mouse(key, move_single := 0, move_repeat := 0) {
    key := StrReplace(key, "*")

    mouse_move_state := get_mouse_move_state()
    single_x := mouse_move_state.x * move_single
    single_y := mouse_move_state.y * move_single

    MouseMove(single_x, single_y, 0, "R")
    show_mouse_move_prompt()
    errorlevel := KeyWait(key, move_delay1)

    While (!errorlevel) {
        mouse_move_state := get_mouse_move_state()
        repeat_x := mouse_move_state.x * move_repeat
        repeat_y := mouse_move_state.y * move_repeat

        MouseMove(repeat_x, repeat_y, 0, "R")
        show_mouse_move_prompt()
        errorlevel := KeyWait(key, move_delay2)
    }
}

fast_move_mouse(key) {
    global FASTMODE := true
    global SLOWMODE := false
    global VERYSLOWMODE := false
    move_mouse(key, fast_move_single, fast_move_repeat)
}

slow_move_mouse(key) {
    global FASTMODE := false
    global VERYSLOWMODE := false
    move_mouse(key, slow_move_single, slow_move_repeat)
}

veryslow_move_mouse(key) {
    global FASTMODE := false
    global SLOWMODE := false
    global VERYSLOWMODE := true
    move_mouse(key, 1, 1)
}

get_scroll_button() {
    WhichButton := ""
    If (GetKeyState(scroll_direction["up"], "P")) {
        WhichButton := "WheelUp"
    } Else If (GetKeyState(scroll_direction["down"], "P")) {
        WhichButton := "WheelDown"
    } Else If (GetKeyState(scroll_direction["left"], "P")) {
        WhichButton := "WheelLeft"
    } Else If (GetKeyState(scroll_direction["right"], "P")) {
        WhichButton := "WheelRight"
    }

    return WhichButton
}

scroll(key) {
    key := StrReplace(key, "*")

    WhichButton := get_scroll_button()
    MouseClick(WhichButton, , , click_count)
    errorlevel := keywait(key, scroll_delay1)

    while (!errorlevel) {
        WhichButton := get_scroll_button()
        MouseClick(WhichButton, , , click_count)
        errorlevel := keywait(key, scroll_delay2)
    }
}

get_window_resize_status() {
    w := 0
    h := 0

    If (GetKeyState(window_direction["left"], "P") || GetKeyState(window_direction["right"], "P")) {
        If (GetKeyState(window_direction["left"], "P")) {
            w := 1
        } Else {
            w := -1
        }
    }

    If (GetKeyState(window_direction["up"], "P") || GetKeyState(window_direction["down"], "P")) {
        If (GetKeyState(window_direction["up"], "P")) {
            h := 1
        } Else {
            h := -1
        }
    }

    return {w: w, h: h}
}

resize_window(size := 40) {
    WinGetPos(&x, &y, &w, &h, "A")

    window_resize_status := get_window_resize_status()
    w := w - window_resize_status.w * size
    h := h - window_resize_status.h * size

    WinMove(x, y, w, h, "A")
}

fast_resize_window(key) {
    resize_window(fast_resize_delta)
}

slow_resize_window(key) {
    resize_window(slow_resize_delta)
}

veryslow_resize_window(key) {
    resize_window(1)
}

*Esc Up::
*CapsLock Up:: {
    If ((A_PriorKey == "Escape" or A_PriorKey == "CapsLock") and A_TimeSinceThisHotkey < 500) {
        Send("{Blind}{Esc}")
    }
}

#HotIf FASTMODE
*Esc Up::
*CapsLock Up:: {
    global FASTMODE := false
    global SLOWMODE := true
}
#HotIf

#HotIf (GetKeyState("Esc", "P") or GetKeyState("Capslock", "P")) and GetKeyState("Alt", "P")
#HotIf

HotIf '(GetKeyState("Esc", "P") or GetKeyState("Capslock", "P")) and GetKeyState("Alt", "P")'
For key, value in mouse_direction {
    Hotkey("*" . value, veryslow_move_mouse)
}
For key, value in window_direction {
    Hotkey("*" . value, fast_resize_window)
}
HotIf

#HotIf GetKeyState("Esc", "P") or GetKeyState("Capslock", "P")
*N:: click_down("L")
*N Up:: click_up("L")
*M:: click_down("R")
*M Up:: click_up("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up("M")
*/:: MakeWindowDraggable()
#HotIf

HotIf 'GetKeyState("Esc", "P") or GetKeyState("Capslock", "P")'
For key, value in mouse_direction {
    Hotkey("*" . value, fast_move_mouse)
}
For key, value in scroll_direction {
    Hotkey("*" . value, scroll)
}
HotIf

#HotIf SLOWMODE
*N:: click_down("L")
*N Up:: click_up_without_hide_mouse_move_prompt("L")
*M:: click_down("R")
*M Up:: click_up_without_hide_mouse_move_prompt("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up_without_hide_mouse_move_prompt("M")
*/:: MakeWindowDraggable()
*Space:: exit_mouse_mode()
*Esc Up::
*CapsLock Up:: {
    If ((A_PriorKey == "Escape" or A_PriorKey == "CapsLock") and A_TimeSinceThisHotkey < 500) {
        exit_mouse_mode_with_left_click_up()
    }
}
#HotIf

HotIf 'SLOWMODE'
For key, value in mouse_direction {
    Hotkey("*" . value, slow_move_mouse)
}
For key, value in scroll_direction {
    Hotkey("*" . value, scroll)
}
For key, value in window_direction {
    Hotkey("*" . value, slow_resize_window)
}
HotIf

#HotIf VERYSLOWMODE
*N:: click_down("L")
*N Up:: click_up_without_hide_mouse_move_prompt("L")
*M:: click_down("R")
*M Up:: click_up_without_hide_mouse_move_prompt("R")
*,:: click_down("L")
*.:: click_down("M")
*. Up:: click_up_without_hide_mouse_move_prompt("M")
*/:: MakeWindowDraggable()
*Space:: exit_mouse_mode()
*Esc Up::
*CapsLock Up:: {
    If ((A_PriorKey == "Escape" or A_PriorKey == "CapsLock") and A_TimeSinceThisHotkey < 500) {
        exit_mouse_mode_with_left_click_up()
    }
}
#HotIf

HotIf 'VERYSLOWMODE'
For key, value in mouse_direction {
    Hotkey("*" . value, veryslow_move_mouse)
}
For key, value in scroll_direction {
    Hotkey("*" . value, scroll)
}
For key, value in window_direction {
    Hotkey("*" . value, veryslow_resize_window)
}
HotIf

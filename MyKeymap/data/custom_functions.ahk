; 自定义的函数写在这个文件里



sendChinese() {
    send, {text}你好中文!
}

center_window()
{
    DllCall("SetThreadDpiAwarenessContext", "ptr", -1, "ptr")

    ; WinExist win will set "A" to default window
    WinExist("A")
    SetWinDelay, 0
    WinGet, state, MinMax
    if state
        WinRestore
    WinGetPos, x, y, w, h
    ; Determine which monitor contains the center of the window.
    ms := wp_GetMonitorAt(x+w/2, y+h/2)
    ; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    msw := msRight - msLeft
    msh := msBottom - msTop
    ; win_w := msw * 0.67
    ; win_h := (msw * 10 / 16) * 0.7
    ; win_w := Min(win_w, win_h * 1.54)
    win_w := w
    win_h := h
    win_x := msLeft + (msw - win_w) / 2
    win_y := msTop + (msh - win_h) / 2
    winmove,,, %win_x%, %win_y%, %win_w%, %win_h%
    DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
}

close_or_run_script(name)
{
    DetectHiddenWindows On
    SetTitleMatchMode RegEx
    IfWinExist, i)%name%.* ahk_class AutoHotkey
    {
        WinClose
        WinWaitClose, i)%name%.* ahk_class AutoHotkey, , 2
        If ErrorLevel
            return "Unable to close " . name
        else
            return "Closed " . name
    }
    else
        path := "bin\custom\" name
        run, bin\ahk.exe %path%
        return name . " run"
}

enter_mouse_mode()
{
    global SLOWMODE
    SLOWMODE := true
    if mouseMovePrompt
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
        mouseMovePrompt.show("🖱️", 19, 17)
}

left_click_down()
{
    send,  {blind}{LButton Down}
}

left_click_up()
{
    global SLOWMODE
    send,  {blind}{LButton Up}
    SLOWMODE := false
    if mouseMovePrompt
        mouseMovePrompt.hide()
}

left_click_down_without_false() 
{
    send,  {blind}{LButton Down}
}

left_click_up_without_false() 
{
    send,  {blind}{LButton Up}
}

right_click_down(tempDisableRButton := false) 
{
    global SLOWMODE
    if (!tempDisableRButton)
        send,  {blind}{RButton Down}
    else {
        setHotkeyStatus("RButton", false)
        send,  {blind}{RButton Down}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
}

right_click_up(tempDisableRButton := false) 
{
    global SLOWMODE
    if (!tempDisableRButton)
        send,  {blind}{RButton Up}
    else {
        setHotkeyStatus("RButton", false)
        send,  {blind}{RButton Up}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
    SLOWMODE := false
    if mouseMovePrompt
        mouseMovePrompt.hide()
}

right_click_down_without_false(tempDisableRButton := false) 
{
    if (!tempDisableRButton)
        send,  {blind}{RButton Down}
    else {
        setHotkeyStatus("RButton", false)
        send,  {blind}{RButton Down}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

right_click_up_without_false(tempDisableRButton := false) 
{
    if (!tempDisableRButton)
        send,  {blind}{RButton Up}
    else {
        setHotkeyStatus("RButton", false)
        send,  {blind}{RButton Up}
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
    if mouseMovePrompt
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
        mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0)
    {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if mouseMovePrompt
            mouseMovePrompt.show("🖱️", 19, 17)
        keywait,  %key%,  %moveDelay2%
    }
}

slow_move_mouse(key, direction_x, direction_y) {
    global slowMoveSingle, slowMoveRepeat, moveDelay1, moveDelay2
    one_x := direction_x * slowMoveSingle
    one_y := direction_y * slowMoveSingle
    repeat_x := direction_x * slowMoveRepeat
    repeat_y := direction_y * slowMoveRepeat
    mousemove, %one_x% , %one_y%, 0, R
    if mouseMovePrompt
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
        mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0)
    {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if mouseMovePrompt
            mouseMovePrompt.show("🖱️", 19, 17)
        keywait,  %key%,  %moveDelay2%
    }
}

very_slow_move_mouse(key, direction_x, direction_y)
{
    global moveDelay1, moveDelay2, VERYSLOWMODE
    VERYSLOWMODE := true
    one_x := direction_x
    one_y := direction_y
    repeat_x := direction_x
    repeat_y := direction_y
    mousemove, %one_x% , %one_y%, 0, R
    if mouseMovePrompt
        WinSet, AlwaysOnTop, On, ahk_class AutoHotkeyGUI
        mouseMovePrompt.show("🖱️", 19, 17)
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0)
    {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        if mouseMovePrompt
            mouseMovePrompt.show("🖱️", 19, 17)
        keywait,  %key%,  %moveDelay2%
    }
}

exit_very_slow_mode() 
{
    global VERYSLOWMODE
    VERYSLOWMODE := false
    send {blind}{Lbutton up}
    if mouseMovePrompt
        mouseMovePrompt.hide()
}

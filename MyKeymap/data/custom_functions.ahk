; 自定义的函数写在这个文件里


helloWorld()
{
    tip("hello world!")
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

enterMouseMode() 
{
    global SLOWMODE
    SLOWMODE := true
}

leftClickWithoutFalse() 
{
    send,  {blind}{LButton}
}

rightClickWithoutFalse(tempDisableRButton := false) 
{
    if (!tempDisableRButton)
        send,  {blind}{RButton}
    else {
        setHotkeyStatus("RButton", false)
        send,  {blind}{RButton}
        sleep, 70
        setHotkeyStatus("RButton", true)
    }
}

very_slow_move_mouse(key, direction_x, direction_y)
{
    global moveDelay1, moveDelay2 
    one_x := direction_x
    one_y := direction_y
    repeat_x := direction_x
    repeat_y := direction_y
    mousemove, %one_x% , %one_y%, 0, R
    keywait, %key%, %moveDelay1%
    while (errorlevel != 0)
    {
        mousemove, %repeat_x%, %repeat_y%, 0, R
        keywait,  %key%,  %moveDelay2%
    }
}
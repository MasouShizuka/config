#SingleInstance Force
#NoTrayIcon
Persistent
OnExit((*) => unhide_mouse())

show_cursor_duration := 3000

show_cursor_status := true
last_time := A_TickCount - show_cursor_duration
MouseGetPos(&last_x, &last_y)

SetTimer(check_idle, 250)
check_idle() {
    global last_x, last_y, last_time, show_cursor_status, show_cursor_duration
    MouseGetPos(&x, &y)
    if (x != last_x || y != last_y) {
        unhide_mouse()
        show_cursor_status := true
        last_x := x, last_y := y
        last_time := A_TickCount
    } else if (A_TickCount >= last_time + show_cursor_duration && show_cursor_status) {
        hide_mosue()
        show_cursor_status := false
    }
}

hide_mosue() {
    show_mouse(false)
}

unhide_mouse() {
    show_mouse(true)
}

;-------------------------------------------------------------------------------
show_mouse(bShow := true) { ; show/hide the mouse cursor
    ;-------------------------------------------------------------------------------
    ; WINAPI: SystemParametersInfo, CreateCursor, CopyImage, SetSystemCursor
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648385.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648395.aspx
    ;---------------------------------------------------------------------------
    static BlankCursor := false, CleanUp := { base: { __Delete: "show_Mouse" } }
    static CursorList := "32512, 32513, 32514, 32515, 32516, 32640, 32641"
        . ",32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651"
    local CursorHandle

    if (bShow) ; shortcut for showing the mouse cursor, also RESETS MOUSE on exit
        ; https://autohotkey.com/boards/viewtopic.php?p=173756#p173756
        Return DllCall(
            "SystemParametersInfo"      ; dll returns BOOL
            , "UInt", 0x57              ; UINT  uiAction    (SPI_SETCURSORS)
            , "UInt", 0                 ; UINT  uiParam
            , "Ptr", 0                  ; PVOID pvParam
            , "UInt", 0                 ; UINT  fWinIni
        )

    if (!BlankCursor) { ; create BlankCursor only once
        BlankCursor := DllCall(
            "CreateCursor"                         ; dll returns HCURSOR
            , "Ptr", 0                             ; HINSTANCE  hInst
            , "Int", 0                             ; int        xHotSpot
            , "Int", 0                             ; int        yHotSpot
            , "Int", 32                            ; int        nWidth
            , "Int", 32                            ; int        nHeight
            , "Ptr", Buffer(32 * 4, 0xFF)          ; const VOID *pvANDPlane
            , "Ptr", Buffer(32 * 4, 0)             ; const VOID *pvXORPlane
            , "Ptr"                                ; return HCURSOR
        )
    }

    ; set all system cursors to blank, each needs a new copy
    loop parse, CursorList, ",", A_Space {
        ; Loop, Parse, CursorList, ` , , %A_Space% {
        CursorHandle := DllCall(
            "CopyImage"                ; dll returns HANDLE
            , "Ptr", BlankCursor       ; HANDLE hImage
            , "UInt", 2                ; UINT   uType      (IMAGE_CURSOR)
            , "Int", 0                 ; int    cxDesired
            , "Int", 0                 ; int    cyDesired
            , "UInt", 0                ; UINT   fuFlags
            , "Ptr"                    ; return HANDLE
        )

        DllCall(
            "SetSystemCursor"          ; dll returns BOOL
            , "Ptr", CursorHandle      ; HCURSOR hcur
            , "UInt", A_Loopfield      ; DWORD   id
        )
    }
}

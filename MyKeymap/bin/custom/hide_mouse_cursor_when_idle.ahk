#Persistent
OnExit("RestoreCursor")

Show_Cursor_Duration := 3000

MouseGetPos, Last_X, Last_Y
Last_Time := A_TickCount - Show_Cursor_Duration
Show_Cursor_Status := True
SetTimer, Check_Idle, 250
Check_Idle:
    MouseGetPos, X, Y
    If (X != Last_X || Y != Last_Y) {
        RestoreCursor()
        Show_Cursor_Status := True
        Last_X := X, Last_Y := Y
        Last_Time := A_TickCount
    } Else If (A_TickCount >= Last_Time + Show_Cursor_Duration && Show_Cursor_Status) {
        SetCursorBlank()
        Show_Cursor_Status := False
    }
Return

SetCursorBlank() {
    SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
    ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
    ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
    ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

    VarSetCapacity(AndMask, 32*4, 0xFF), VarSetCapacity(XorMask, 32*4, 0)

    Loop, Parse, SystemCursors, `,
    {
        Type = BlankCursor
        %Type%%A_Index% := DllCall("CreateCursor", Uint, 0, Int, 0, Int, 0, Int, 32, Int, 32, Uint, &AndMask, Uint, &XorMask)
        CursorHandle := DllCall("CopyImage", Uint, %Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0)
        DllCall("SetSystemCursor", Uint,CursorHandle, Int, SubStr(A_Loopfield, 1, 5))
    }
}

RestoreCursor() {
    SPI_SETCURSORS := 0x57
    DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
}

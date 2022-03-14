Interval := 3000
MouseGetPos, Last_X, Last_Y
Last_Move := A_TickCount - Interval
Show_Cursor := True

#Persistent
OnExit("RestoreCursor")

Loop
{
    MouseGetPos, Mouse_X, Mouse_Y
    if (Mouse_X != Last_X || Mouse_Y != Last_Y)
    {
        RestoreCursor()
        Show_Cursor := True
        Last_X := Mouse_X, Last_Y := Mouse_Y
        Last_Move := A_TickCount
    }
    else if (A_TickCount >= Last_Move + Interval && Show_Cursor == True)
    {
        SetCursorBlank()
        Show_Cursor := False
    }
}

SetCursorBlank()
{
    SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
    ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
    ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
    ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

    VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )

    Loop, Parse, SystemCursors, `,
    {
        Type = BlankCursor
        %Type%%A_Index% := DllCall( "CreateCursor"
        , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
        CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
        DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
    }
}

RestoreCursor()
{
    SPI_SETCURSORS := 0x57
    DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

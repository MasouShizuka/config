Last_Move := A_TickCount
State := True

set_cursor_blank()
Loop
{
	MouseGetPos, Mouse_X, Mouse_Y
	If(Mouse_X != Last_X || Mouse_Y != Last_Y)
	{
		If(State == False)
            restore_cursors()
		State := True
		Last_Move := A_TickCount
	}
	If(A_TickCount > Last_Move + 3000 && State == True) ;Change the 3000 to the desired time...
	{
        set_cursor_blank()
		State := False
	}
	Last_X := Mouse_X, Last_Y := Mouse_Y
}

; Ensure the cursor is made visible when the script exits.
#Persistent
    OnExit, ShowCursor
return

; Shows the mouse cursor
ShowCursor:
restore_cursors()
ExitApp

set_cursor_blank()
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

restore_cursors()
{
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

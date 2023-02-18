; #Warn  ; Enable warnings to assist with detecting common errors.
; #Warn, UseUnsetLocal, off
; #Warn, LocalSameAsGlobal, off
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
#NoTrayIcon
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
Menu, Tray, Icon, logo.ico
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

#include %A_ScriptDir%/tray_icon.ahk
#include %A_ScriptDir%/monitor_center.ahk

global trayicon_info := TrayIcon_GetInfo()
global num_tray := trayicon_info.MaxIndex()
global selected := 1
global is_left := True
global title_left := "激活托盘程序：左键"
global title_right := "激活托盘程序：右键"
global help := "`tjk 上下移动、h 切换左右键、l 单击所选键、x 退出"

Gui, +LastFound
Gui New, +HwndGuiHwnd +Resize
Gui, Font, s16, Sarasa Mono SC Nerd Font

Gui, Add, ListView, r%num_tray% w644 vMyListView, Name|Pid
LV_ModifyCol(1, 512)
LV_ModifyCol(2, 128)
LV_ModifyCol(2, "Integer")

ImageListID1 := IL_Create(10)
LV_SetImageList(ImageListID1)

GuiControl, -Redraw, MyListView
Loop, % num_tray {
    IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", trayicon_info[A_Index].hicon) + 1
    LV_Add("Icon" . IconNumber, trayicon_info[A_Index].process, trayicon_info[A_Index].pid)
}
GuiControl, +Redraw, MyListView

LV_Modify(1, "Focus")
LV_Modify(1, "Select")

OnMessage(0x100, "WM_KEYDOWN")
GetClientSize(w, h)
GetCurrentMonitorCenter(cx, cy)
x := cx - w / 2
y := cy - h / 2
Gui, Show, x%x% y%y%, %title_left%%help%
disableIME(GuiHwnd)
SetTimer, IfLoseFocusThenExit, 700
Return

WM_KEYDOWN(wParam, lParam) {
    switch (GetKeyName(Format("vk{:x}", wParam))) {
    case "j": next()
    case "k": previous()
    case "h": switch_button()
    case "l": click()
    case "x": ExitApp
    default:
        ; sleep 500
        Return 0
    }
    Return 0
}

next() {
    If (selected < num_tray) {
        selected += 1
    } Else {
        selected := 1
    }
    LV_Modify(0, "-Select")
    LV_Modify(selected, "Focus")
    LV_Modify(selected, "Select")
}

previous() {
    If (selected > 1) {
        selected -= 1
    } Else {
        selected := num_tray
    }
    LV_Modify(0, "-Select")
    LV_Modify(selected, "Focus")
    LV_Modify(selected, "Select")
}

switch_button() {
    is_left := not is_left
    If (is_left) {
        Gui, Show,, %title_left%%help%
    } Else {
        Gui, Show,, %title_right%%help%
    }
}

click() {
    process_name := trayicon_info[selected].process
    If (is_left) {
        TrayIcon_Button(process_name, "L", False)
    } Else {
        TrayIcon_Button(process_name, "R", False)
    }
}

disableIME(hwnd) {
    ControlGetFocus, controlName, ahk_id %hwnd%
    ControlGet, controlHwnd, Hwnd,, %controlName%, A
    DllCall("Imm32\ImmAssociateContext", "ptr", controlHwnd, "ptr", 0, "ptr")
}

IfLoseFocusThenExit() {
    global GuiHwnd
    If (!WinActive("ahk_id " GuiHwnd)) {
        ExitApp
    }
}

GuiClose:
ExitApp
Return

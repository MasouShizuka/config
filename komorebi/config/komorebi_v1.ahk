#SingleInstance Force
#NoTrayIcon

#Persistent
OnExit("komorebic_stop")

EnvGet, localappdata, LOCALAPPDATA

ProcessCloseAll(PIDOrName) {
    Loop {
        Process, Close, % PIDOrName
        Process, Exist, % PIDOrName  ; 在一些情况下提高稳定性.
    } Until not ErrorLevel
}

komorebic_stop() {
    ProcessCloseAll("yasb.exe")

    RunWait, komorebic.exe stop, , Hide

    FileRemoveDir, %localappdata%  "/komorebi", 1
}


; ╭───────╮
; │ Start │
; ╰───────╯

FileCreateDir, %localappdata%  "/komorebi"
RunWait, komorebic.exe start --config komorebi.json --await-configuration, , Hide


; ╭─────────╮
; │ Monitor │
; ╰─────────╯

global main_monitor := 0

global monitor_key_value := { "o": 0
                            , "i": 1
                            , "u": 2 }

global focus_monitor_prefix := "!"
For key, value in monitor_key_value {
    Hotkey, % focus_monitor_prefix . key, focus_monitor
}

global send_to_monitor_prefix := "!+"
For key, value in monitor_key_value {
    Hotkey, % send_to_monitor_prefix . key, send_to_monitor
}


; ╭───────────╮
; │ Workspace │
; ╰───────────╯

global workspace_key_value := { 1: 0
                              , 2: 1
                              , 3: 2
                              , 4: 3
                              , 5: 4
                              , 6: 5
                              , 7: 6 }

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey, % focus_monitor_workspace_prefix . key, focus_monitor_workspace
}

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey, % send_to_monitor_workspace_prefix . key, send_to_monitor_workspace
}


; ╭────────────────────────╮
; │ Complete Configuration │
; ╰────────────────────────╯

RunWait, komorebic.exe complete-configuration, , Hide

ProcessCloseAll("yasb.exe")
Run, %A_ScriptDir%/yasb/yasb.exe, , Hide


; ╭─────────╮
; │ Keybind │
; ╰─────────╯

!q::
    RunWait, komorebic.exe close, , Hide
Return

!+q::
    RunWait, komorebic.exe stop, , Hide
Return

!left::
    RunWait, komorebic.exe focus left, , Hide
Return

!right::
    RunWait, komorebic.exe focus right, , Hide
Return

!up::
    RunWait, komorebic.exe focus up, , Hide
Return

!down::
    RunWait, komorebic.exe focus down, , Hide
Return

!+left::
    RunWait, komorebic.exe move left, , Hide
Return

!+right::
    RunWait, komorebic.exe move right, , Hide
Return

!+up::
    RunWait, komorebic.exe move up, , Hide
Return

!+down::
    RunWait, komorebic.exe move down, , Hide
Return

!j::
    RunWait, komorebic.exe cycle-focus next, , Hide
Return

!k::
    RunWait, komorebic.exe cycle-focus previous, , Hide
Return

!+j::
    RunWait, komorebic.exe cycle-move next, , Hide
Return

!+k::
    RunWait, komorebic.exe cycle-move previous, , Hide
Return

!h::
    RunWait, komorebic.exe resize-axis horizontal decrease, , Hide
Return

!l::
    RunWait, komorebic.exe resize-axis horizontal increase, , Hide
Return

!+h::
    RunWait, komorebic.exe resize-axis vertical decrease, , Hide
Return

!+l::
    RunWait, komorebic.exe resize-axis vertical increase, , Hide
Return

focus_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    RunWait, komorebic.exe focus-monitor-workspace %main_monitor% %num%, , Hide
Return

send_to_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    RunWait, komorebic.exe send-to-monitor-workspace %main_monitor% %num%, , Hide
Return

focus_monitor:
    key := SubStr(A_ThisHotkey, StrLen(focus_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait, komorebic.exe focus-monitor %value%, , Hide
Return

send_to_monitor:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait, komorebic.exe send-to-monitor %value%, , Hide
Return

; +-------+-----+
; |       |     |
; |       +--+--+
; |       |  |--|
; +-------+--+--+
!b::
    RunWait, komorebic.exe change-layout bsp, , Hide
Return

; +--+--+--+--+
; |  |  |  |  |
; |  |  |  |  |
; |  |  |  |  |
; +--+--+--+--+
!c::
    RunWait, komorebic.exe change-layout columns, , Hide
Return

; +-----------+
; |-----------|
; |-----------|
; |-----------|
; +-----------+
!r::
    RunWait, komorebic.exe change-layout rows, , Hide
Return

; +-------+-----+
; |       |     |
; |       +-----+
; |       |     |
; +-------+-----+
!+c::
    RunWait, komorebic.exe change-layout vertical-stack, , Hide
Return

; +------+------+
; |             |
; |------+------+
; |      |      |
; +------+------+
!+r::
    RunWait, komorebic.exe change-layout horizontal-stack, , Hide
Return

; +-----+-----------+-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; +-----+-----------+-----+
!+m::
    RunWait, komorebic.exe change-layout ultrawide-vertical-stack, , Hide
Return

; +-----+-----+   +---+---+---+   +---+---+---+   +---+---+---+
; |     |     |   |   |   |   |   |   |   |   |   |   |   |   |
; |     |     |   |   |   |   |   |   |   |   |   |   |   +---+
; +-----+-----+   |   +---+---+   +---+---+---+   +---+---|   |
; |     |     |   |   |   |   |   |   |   |   |   |   |   +---+
; |     |     |   |   |   |   |   |   |   |   |   |   |   |   |
; +-----+-----+   +---+---+---+   +---+---+---+   +---+---+---+
;   4 windows       5 windows       6 windows       7 windows
!g::
    RunWait, komorebic.exe change-layout grid, , Hide
Return

!+Capslock::
!+Esc::
    RunWait, komorebic.exe toggle-pause, , Hide
Return

!Capslock::
!Esc::
    RunWait, komorebic.exe toggle-tiling, , Hide
Return

!+f::
    RunWait, komorebic.exe toggle-float, , Hide
Return

!m::
    RunWait, komorebic.exe toggle-monocle, , Hide
Return

!f::
    RunWait, komorebic.exe toggle-maximize, , Hide
Return

!d::
    RunWait, komorebic.exe minimize, , Hide
Return

!x::
    RunWait, komorebic.exe flip-layout horizontal, , Hide
Return

!y::
    RunWait, komorebic.exe flip-layout vertical, , Hide
Return

!+e::
    RunWait, komorebic.exe promote, , Hide
Return

!e::
    RunWait, komorebic.exe promote-focus, , Hide
Return

!n::
    RunWait, komorebic.exe retile, , Hide
Return

!t::
    RunWait, komorebic.exe manage, , Hide
Return

!+t::
    RunWait, komorebic.exe unmanage, , Hide
Return

!+b::
    ProcessCloseAll("yasb.exe")
    Run, %A_ScriptDir%/yasb/yasb.exe, , Hide
Return

!Enter::
    Run, wezterm.exe, , Hide
Return

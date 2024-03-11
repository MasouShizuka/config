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



; ╭────────────────╮
; │ Start komorebi │
; ╰────────────────╯

FileCreateDir, %localappdata%  "/komorebi"
RunWait, komorebic.exe start --await-configuration, , Hide



; ╭─────────╮
; │ Setting │
; ╰─────────╯

RunWait, komorebic.exe window-hiding-behaviour cloak, , Hide

RunWait, komorebic.exe cross-monitor-move-behaviour insert, , Hide

RunWait, komorebic.exe active-window-border enable, , Hide
RunWait, komorebic.exe active-window-border-colour 66 165 245 --window-kind single, , Hide
RunWait, komorebic.exe active-window-border-colour 256 165 66 --window-kind stack, , Hide
RunWait, komorebic.exe active-window-border-colour 255 51 153 --window-kind monocle, , Hide
RunWait, komorebic.exe active-window-border-width 6, , Hide

RunWait, komorebic.exe focus-follows-mouse disable --implementation windows, , Hide
RunWait, komorebic.exe mouse-follows-focus enable, , Hide



; ╭─────────╮
; │ Monitor │
; ╰─────────╯

SysGet, monitor_count, MonitorCount
global main_monitor := monitor_count - 1

global monitor_key_value := { "u": 0
                            , "i": 1
                            , "o": 2 }

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

global workspace_key_value := { 1: [0, " "]
                              , 2: [1, " "]
                              , 3: [2, " "]
                              , 4: [3, " "]
                              , 5: [4, " "]
                              , 6: [5, " "]
                              , 7: [6, " "] }
global workspace_num := workspace_key_value.Length()

global container_padding := 4
global workspace_padding := 4

RunWait, komorebic.exe ensure-workspaces %main_monitor% %workspace_num%, , Hide

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey, % focus_monitor_workspace_prefix . key, focus_monitor_workspace
}

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey, % send_to_monitor_workspace_prefix . key, send_to_monitor_workspace
}

For key, value in workspace_key_value {
    num := value[1]
    icon := value[2]
    RunWait, komorebic.exe workspace-name %main_monitor% %num% `"%icon%`", , Hide
}

For key, value in workspace_key_value {
    num := value[1]
    RunWait, komorebic.exe container-padding %main_monitor% %num% %container_padding%, , Hide
    RunWait, komorebic.exe workspace-padding %main_monitor% %num% %workspace_padding%, , Hide
}
For key, value in monitor_key_value {
    If (value != main_monitor) {
        RunWait, komorebic.exe container-padding %value% 0 %container_padding%, , Hide
        RunWait, komorebic.exe workspace-padding %value% 0 %workspace_padding%, , Hide
    }
}

RunWait, komorebic.exe workspace-rule exe "QQ.exe" %main_monitor% 2, , Hide
RunWait, komorebic.exe workspace-rule exe "WeChat.exe" %main_monitor% 2, , Hide
RunWait, komorebic.exe workspace-rule exe "cloudmusic.exe" %main_monitor% 3, , Hide
RunWait, komorebic.exe workspace-rule exe "foobar2000.exe" %main_monitor% 3, , Hide
RunWait, komorebic.exe workspace-rule exe "Thunder.exe" %main_monitor% 4, , Hide
RunWait, komorebic.exe workspace-rule exe "nekoray.exe" %main_monitor% 5, , Hide



; ╭─────╮
; │ APP │
; ╰─────╯

RunWait, komorebic.exe float-rule class "ExplorerBrowserControl", , Hide
RunWait, komorebic.exe float-rule class "jsplitter_panel_container", , Hide
RunWait, komorebic.exe float-rule class "OperationStatusWindow", , Hide
RunWait, komorebic.exe float-rule class "SessionDragWnd", , Hide
RunWait, komorebic.exe float-rule class "TApplication", , Hide

RunWait, komorebic.exe float-rule title "Hotkey sink", , Hide

RunWait, komorebic.exe float-rule exe "ahk.exe", , Hide
RunWait, komorebic.exe float-rule exe "ApplicationFrameHost.exe", , Hide
RunWait, komorebic.exe float-rule exe "Clash Verge.exe", , Hide
RunWait, komorebic.exe float-rule exe "copyq.exe", , Hide
RunWait, komorebic.exe float-rule exe "Flow.Launcher.exe", , Hide
RunWait, komorebic.exe float-rule exe "MyKeymap.exe", , Hide
RunWait, komorebic.exe float-rule exe "yasb.exe", , Hide

RunWait, komorebic.exe manage-rule exe "QQ.exe", , Hide
RunWait, komorebic.exe manage-rule exe "TE64.exe", , Hide
RunWait, komorebic.exe manage-rule exe "WeChat.exe", , Hide
RunWait, komorebic.exe manage-rule exe "wezterm-gui.exe", , Hide

RunWait, komorebic.exe identify-tray-application exe "Clash Verge.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "copyq.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "QQ.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "RemindMe.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "ShareX.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "Steam++.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "WeChat.exe", , Hide

RunWait, komorebic.exe identify-border-overflow-application exe "cloudmusic.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "Code.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "QQ.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "vivaldi.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "WeChat.exe", , Hide

RunWait, komorebic.exe float-rule class "_WwB", , Hide
RunWait, komorebic.exe identify-layered-application exe "EXCEL.EXE", , Hide
RunWait, komorebic.exe identify-layered-application exe "POWERPNT.EXE", , Hide
RunWait, komorebic.exe identify-layered-application exe "WINWORD.EXE", , Hide



; ╭────────────────╮
; │ Start komorebi │
; ╰────────────────╯

RunWait, komorebic.exe complete-configuration, , Hide

ProcessCloseAll("yasb.exe")
Run, %A_ScriptDir%/yasb.exe, , Hide



; ╭─────────╮
; │ Keybind │
; ╰─────────╯

!q::
    RunWait, komorebic.exe close, , Hide
Return

!+q::
    RunWait, komorebic.exe stop, , Hide
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
    num := workspace_key_value[key][1]
    RunWait, komorebic.exe focus-monitor-workspace %main_monitor% %num%, , Hide
Return

send_to_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key][1]
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
    ; WinMinimize, A
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
    Run, %A_ScriptDir%/yasb.exe, , Hide
Return

#SingleInstance Force

#Persistent
OnExit("komorebic_stop")

komorebic_stop() {
    RunWait, komorebic.exe stop, , Hide

    Run, rm ~/komorebic.sock, , Hide
    Run, rm -rf ~/AppData/Local/komorebi, , Hide

    Return
}



;##################
;# Start komorebi #
;##################

RunWait, komorebic.exe start --await-configuration, , Hide



;###########
;# Setting #
;###########

; Configure the invisible border dimensions
RunWait, komorebic.exe invisible-borders 7 0 14 7, , Hide

; Enable hot reloading of changes to this file
RunWait, komorebic.exe watch-configuration enable, , Hide

; Default to cloaking windows when switching workspaces
RunWait, komorebic.exe window-hiding-behaviour cloak, , Hide

; Set cross-monitor move behaviour to insert instead of swap
RunWait, komorebic.exe cross-monitor-move-behaviour insert, , Hide

; Enable Active Window Border
RunWait, komorebic.exe active-window-border enable, , Hide
RunWait, komorebic.exe active-window-border-colour 66 165 245 --window-kind single, , Hide
RunWait, komorebic.exe active-window-border-colour 256 165 66 --window-kind stack, , Hide
RunWait, komorebic.exe active-window-border-colour 255 51 153 --window-kind monocle, , Hide
RunWait, komorebic.exe active-window-border-width 14, , Hide

; Configure focus related with mouse
RunWait, komorebic.exe focus-follows-mouse disable --implementation windows, , Hide
RunWait, komorebic.exe mouse-follows-focus enable, , Hide



;###########
;# Monitor #
;###########

SysGet, monitor_count, MonitorCount
global main_monitor := monitor_count - 1

global monitor_key_value := {"u": 0, "i": 1, "o": 2}

global focus_monitor_prefix := "!"
For key, value in monitor_key_value {
    Hotkey, % focus_monitor_prefix . key, focus_monitor
}

global send_to_monitor_prefix := "!+"
For key, value in monitor_key_value {
    Hotkey, % send_to_monitor_prefix . key, send_to_monitor
}



;#############
;# Workspace #
;#############

global workspace_key_value := {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6}
global workspace_icons := [""" """, """ """, """ """, """ """, """ """, """ """, """ """]
global workspace_num := workspace_key_value.Length()

global container_padding := 10
global workspace_padding := 10

; Ensure there are 7 workspaces created on monitor 0
; RunWait, komorebic.exe ensure-workspaces 0 7, , Hide
RunWait, komorebic.exe ensure-workspaces %main_monitor% %workspace_num%, , Hide

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey, % focus_monitor_workspace_prefix . key, focus_monitor_workspace
}

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey, % send_to_monitor_workspace_prefix . key, send_to_monitor_workspace
}

; Give the workspaces some optional names
; RunWait, komorebic.exe workspace-name 0 0 bsp, , Hide
; RunWait, komorebic.exe workspace-name 0 1 columns, , Hide
; RunWait, komorebic.exe workspace-name 0 2 thicc, , Hide
; RunWait, komorebic.exe workspace-name 0 3 matrix, , Hide
; RunWait, komorebic.exe workspace-name 0 4 floaty, , Hide
For key, value in workspace_key_value {
    icon := workspace_icons[value + 1]
    RunWait, komorebic.exe workspace-name %main_monitor% %value% %icon%, , Hide
}

; Set the padding of the different workspaces
; RunWait, komorebic.exe container-padding 0 1 30, , Hide
; RunWait, komorebic.exe workspace-padding 0 1 30, , Hide
; RunWait, komorebic.exe workspace-padding 0 2 200, , Hide
; RunWait, komorebic.exe container-padding 0 3 0, , Hide
; RunWait, komorebic.exe workspace-padding 0 3 0, , Hide
For key, value in workspace_key_value {
    RunWait, komorebic.exe container-padding %main_monitor% %value% %container_padding%, , Hide
    RunWait, komorebic.exe workspace-padding %main_monitor% %value% %workspace_padding%, , Hide
}
For key, value in monitor_key_value {
    If (value != main_monitor) {
        RunWait, komorebic.exe container-padding %value% 0 %container_padding%, , Hide
        RunWait, komorebic.exe workspace-padding %value% 0 %workspace_padding%, , Hide
    }
}

; Set the layouts of different workspaces
; RunWait, komorebic.exe workspace-layout 0 1 columns, , Hide

; Set the floaty layout to not tile any windows
; RunWait, komorebic.exe workspace-tiling 0 4 disable, , Hide

; Always show chat apps on the second workspace
; RunWait, komorebic.exe workspace-rule exe slack.exe 0 1, , Hide
; RunWait, komorebic.exe workspace-rule exe Discord.exe 0 1, , Hide
RunWait, komorebic.exe workspace-rule exe "QQ.exe" %main_monitor% 2, , Hide
RunWait, komorebic.exe workspace-rule exe "WeChat.exe" %main_monitor% 2, , Hide
RunWait, komorebic.exe workspace-rule exe "cloudmusic.exe" %main_monitor% 3, , Hide
RunWait, komorebic.exe workspace-rule exe "foobar2000.exe" %main_monitor% 3, , Hide
RunWait, komorebic.exe workspace-rule exe "Thunder.exe" %main_monitor% 5, , Hide



;#######
;# APP #
;#######

; Always float, matching on class
; RunWait, komorebic.exe float-rule class SunAwtDialog, , Hide
; RunWait, komorebic.exe float-rule class TaskManagerWindow, , Hide
RunWait, komorebic.exe float-rule class "ExplorerBrowserControl", , Hide
RunWait, komorebic.exe float-rule class "jsplitter_panel_container", , Hide
RunWait, komorebic.exe float-rule class "OperationStatusWindow", , Hide
RunWait, komorebic.exe float-rule class "SessionDragWnd", , Hide
RunWait, komorebic.exe float-rule class "TApplication", , Hide
; Always float, matching on title
; RunWait, komorebic.exe float-rule title "Control Panel", , Hide
; RunWait, komorebic.exe float-rule title Calculator, , Hide
RunWait, komorebic.exe float-rule title "Hotkey sink", , Hide
; Always float, matching on executable name
; RunWait, komorebic.exe float-rule exe Wally.exe, , Hide
; RunWait, komorebic.exe float-rule exe wincompose.exe, , Hide
; RunWait, komorebic.exe float-rule exe 1Password.exe, , Hide
RunWait, komorebic.exe float-rule exe "ahk.exe", , Hide
RunWait, komorebic.exe float-rule exe "ApplicationFrameHost.exe", , Hide
RunWait, komorebic.exe float-rule exe "Clash Verge.exe", , Hide
RunWait, komorebic.exe float-rule exe "copyq.exe", , Hide
RunWait, komorebic.exe float-rule exe "Flow.Launcher.exe", , Hide
RunWait, komorebic.exe float-rule exe "yasb.exe", , Hide

; Always manage forcibly these applications that don't automatically get picked up by komorebi
; RunWait, komorebic.exe manage-rule exe TIM.exe, , Hide
RunWait, komorebic.exe manage-rule exe "QQ.exe", , Hide
RunWait, komorebic.exe manage-rule exe "TE64.exe", , Hide
RunWait, komorebic.exe manage-rule exe "WeChat.exe", , Hide

; Identify applications that close to the tray
; RunWait, komorebic.exe identify-tray-application exe Discord.exe, , Hide
RunWait, komorebic.exe identify-tray-application exe "Clash Verge.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "copyq.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "QQ.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "RemindMe.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "ShareX.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "Steam++.exe", , Hide
RunWait, komorebic.exe identify-tray-application exe "WeChat.exe", , Hide

; Identify applications that have overflowing borders
; RunWait, komorebic.exe identify-border-overflow-application exe Discord.exe, , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "alacritty.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "Code.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "QQ.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "vivaldi.exe", , Hide
RunWait, komorebic.exe identify-border-overflow-application exe "WeChat.exe", , Hide

; Office
RunWait, komorebic.exe float-rule class "_WwB", , Hide
RunWait, komorebic.exe identify-layered-application exe "EXCEL.EXE", , Hide
RunWait, komorebic.exe identify-layered-application exe "POWERPNT.EXE", , Hide
RunWait, komorebic.exe identify-layered-application exe "WINWORD.EXE", , Hide



;##################
;# Start komorebi #
;##################

; Allow komorebi to start managing windows
RunWait, komorebic.exe complete-configuration, , Hide

; Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide
Run, %A_ScriptDir%/yasb.exe, , Hide



;###########
;# Keybind #
;###########

!q::
    ; WinClose, A
    RunWait, komorebic.exe close, , Hide
Return

!+q::
    RunWait, komorebic.exe stop, , Hide
Return

; Change the focused window, Alt + Vim direction keys (HJKL)
; !h::
; RunWait, komorebic.exe focus left, , Hide
; return

; !j::
; RunWait, komorebic.exe focus down, , Hide
; return

; !k::
; RunWait, komorebic.exe focus up, , Hide
; return

; !l::
; RunWait, komorebic.exe focus right, , Hide
; return

!j::
    RunWait, komorebic.exe cycle-focus next, , Hide
Return

!k::
    RunWait, komorebic.exe cycle-focus previous, , Hide
Return

; Move the focused window in a given direction, Alt + Shift + Vim direction keys (HJKL)
; !+h::
; RunWait, komorebic.exe move left, , Hide
; return

; !+j::
; RunWait, komorebic.exe move down, , Hide
; return

; !+k::
; RunWait, komorebic.exe move up, , Hide
; return

; !+l::
; RunWait, komorebic.exe move right, , Hide
; return

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

; Stack the focused window in a given direction
; !+Left::
; RunWait, komorebic.exe stack left, , Hide
; return

; !+Down::
; RunWait, komorebic.exe stack down, , Hide
; return

; !+Up::
; RunWait, komorebic.exe stack up, , Hide
; return

; !+Right::
; RunWait, komorebic.exe stack right, , Hide
; return

; !+]::
; RunWait, komorebic.exe cycle-stack next, , Hide
; return

; !+[::
; RunWait, komorebic.exe cycle-stack previous, , Hide
; return

; Unstack the focused window
; !+d::
; RunWait, komorebic.exe unstack, , Hide
; return

; Switch to workspace
focus_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    value := workspace_key_value[key]
    RunWait, komorebic.exe focus-monitor-workspace %main_monitor% %value%, , Hide
Return

; Move window to workspace
send_to_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    value := workspace_key_value[key]
    RunWait, komorebic.exe send-to-monitor-workspace %main_monitor% %value%, , Hide
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

; Switch to the default bsp tiling layout
; famous binary space partition
; -------------
; |     |     |
; |     |------
; |     |  |  |
; -------------
!b::
    RunWait, komorebic.exe change-layout bsp, , Hide
Return

; Switch to an equal-width, max-height column layout
; max-height column layout on the main workspace
; -------------
; |   |   |   |
; |   |   |   |
; -------------
!c::
    RunWait, komorebic.exe change-layout columns, , Hide
Return

; Switch to an equal-height, max-width column layout
; max-width column layout on the main workspace
; ------------
; |          |
; ------------
; |          |
; ------------
; |          |
; ------------
!r::
    RunWait, komorebic.exe change-layout rows, , Hide
Return

; -----------
; |    |    |
; |    |-----
; |    |    |
; |    |-----
; |    |    |
; -----------
!+c::
    RunWait, komorebic.exe change-layout vertical-stack, , Hide
Return

; ----------------
; |              |
; ----------------
; |    |    |    |
; ----------------
!+r::
    RunWait, komorebic.exe change-layout horizontal-stack, , Hide
Return

; ------------
; |  |    |  |
; |  |    |---
; |  |    |  |
; |  |    |---
; |  |    |  |
; ------------
!+m::
    RunWait, komorebic.exe change-layout ultrawide-vertical-stack, , Hide
Return

; Pause responding to any window events or komorebic commands
!+Capslock::
!+Esc::
    RunWait, komorebic.exe toggle-pause, , Hide
Return

!Capslock::
!Esc::
    RunWait, komorebic.exe toggle-tiling, , Hide
Return

; Float the focused window
!+f::
    RunWait, komorebic.exe toggle-float, , Hide
Return

; Toggle the Monocle layout for the focused window
!m::
    RunWait, komorebic.exe toggle-monocle, , Hide
Return

; Toggle native maximize for the focused window
!f::
    WinGet, MX, MinMax, A
    If (MX) {
        WinRestore, A
    } Else {
        WinMaximize, A
    }
Return

!d::
    ; WinMinimize, A
    RunWait, komorebic.exe minimize, , Hide
Return

; Flip horizontally
!x::
    RunWait, komorebic.exe flip-layout horizontal, , Hide
Return

; Flip vertically
!y::
    RunWait, komorebic.exe flip-layout vertical, , Hide
Return

; Promote the focused window to the top of the tree
!+e::
    RunWait, komorebic.exe promote, , Hide
Return

!e::
    RunWait, komorebic.exe promote-focus, , Hide
Return

; Force a retile if things get janky
!n::
    RunWait, komorebic.exe retile, , Hide
Return

!t::
    RunWait, komorebic.exe manage, , Hide
Return

!+t::
    RunWait, komorebic.exe unmanage, , Hide
Return

; Reload ~/komorebi.ahk
; !o::
; RunWait, komorebic.exe reload-configuration, , Hide
; return

!+b::
    ; Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide
    Run, %A_ScriptDir%/yasb.exe, , Hide
Return

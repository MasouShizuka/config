#SingleInstance Force

; You can generate a fresh version of this file with "komorebic ahk-library"
#Include %A_ScriptDir%/komorebic.lib.ahk

#Persistent
OnExit("komorebic_stop")

komorebic_stop() {
    Stop()

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
InvisibleBorders(7, 0, 14, 7)

; Enable hot reloading of changes to this file
WatchConfiguration("enable")

; Default to minimizing windows when switching workspaces
WindowHidingBehaviour("cloak")

; Set cross-monitor move behaviour to insert instead of swap
CrossMonitorMoveBehaviour("insert")

; Enable Active Window Border
ActiveWindowBorder("enable")
ActiveWindowBorderColour(66, 165, 245, "single")
ActiveWindowBorderWidth(14)

; Configure focus related with mouse
FocusFollowsMouse("disable", "windows")
MouseFollowsFocus("enable")



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
global workspace_icon := [""" """, """ """, """ """, """ """, """ """, """ """, """ """]

global container_padding := 10
global workspace_padding := 10

; Ensure there are 7 workspaces created on monitor 0
; Run, komorebic.exe ensure-workspaces 0 7, , Hide
EnsureWorkspaces(main_monitor, workspace_key_value.Length())

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey, % focus_monitor_workspace_prefix . key, focus_monitor_workspace
}

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey, % send_to_monitor_workspace_prefix . key, send_to_monitor_workspace
}

; Give the workspaces some optional names
; Run, komorebic.exe workspace-name 0 0 bsp, , Hide
; Run, komorebic.exe workspace-name 0 1 columns, , Hide
; Run, komorebic.exe workspace-name 0 2 thicc, , Hide
; Run, komorebic.exe workspace-name 0 3 matrix, , Hide
; Run, komorebic.exe workspace-name 0 4 floaty, , Hide
For key, value in workspace_key_value {
    WorkspaceName(main_monitor, value, workspace_icon[value + 1])
}

; Set the padding of the different workspaces
; Run, komorebic.exe container-padding 0 1 30, , Hide
; Run, komorebic.exe workspace-padding 0 1 30, , Hide
; Run, komorebic.exe workspace-padding 0 2 200, , Hide
; Run, komorebic.exe container-padding 0 3 0, , Hide
; Run, komorebic.exe workspace-padding 0 3 0, , Hide
For key, value in workspace_key_value {
    ContainerPadding(main_monitor, value, container_padding)
    WorkspacePadding(main_monitor, value, workspace_padding)
}
For key, value in monitor_key_value {
    If (value != main_monitor) {
        ContainerPadding(value, 0, container_padding)
        WorkspacePadding(value, 0, workspace_padding)
    }
}

; Set the layouts of different workspaces
; Run, komorebic.exe workspace-layout 0 1 columns, , Hide

; Set the floaty layout to not tile any windows
; Run, komorebic.exe workspace-tiling 0 4 disable, , Hide

; Always show chat apps on the second workspace
; Run, komorebic.exe workspace-rule exe slack.exe 0 1, , Hide
; Run, komorebic.exe workspace-rule exe Discord.exe 0 1, , Hide
WorkspaceRule("exe", "QQ.exe", main_monitor, 2)
WorkspaceRule("exe", "WeChat.exe", main_monitor, 2)
WorkspaceRule("exe", "cloudmusic.exe", main_monitor, 3)
WorkspaceRule("exe", "foobar2000.exe", main_monitor, 3)
WorkspaceRule("exe", "mpv.exe", main_monitor, 4)
WorkspaceRule("exe", "Thunder.exe", main_monitor, 5)



;#######
;# APP #
;#######

; Always float, matching on class
; Run, komorebic.exe float-rule class SunAwtDialog, , Hide
; Run, komorebic.exe float-rule class TaskManagerWindow, , Hide
FloatRule("class", "ExplorerBrowserControl")
FloatRule("class", "jsplitter_panel_container")
FloatRule("class", "SessionDragWnd")
FloatRule("class", "TApplication")
; Always float, matching on title
; Run, komorebic.exe float-rule title "Control Panel", , Hide
; Run, komorebic.exe float-rule title Calculator, , Hide
FloatRule("title", "Hotkey sink")
; Always float, matching on executable name
; Run, komorebic.exe float-rule exe Wally.exe, , Hide
; Run, komorebic.exe float-rule exe wincompose.exe, , Hide
; Run, komorebic.exe float-rule exe 1Password.exe, , Hide
FloatRule("exe", "ahk.exe")
FloatRule("exe", "ApplicationFrameHost.exe")
FloatRule("exe", "Clash Verge.exe")
FloatRule("exe", "copyq.exe")
FloatRule("exe", "Flow.Launcher.exe")

; Always manage forcibly these applications that don't automatically get picked up by komorebi
; Run, komorebic.exe manage-rule exe TIM.exe, , Hide
ManageRule("exe", "foobar2000.exe")
ManageRule("exe", "mpv.exe")
ManageRule("exe", "QQ.exe")
ManageRule("exe", "TE64.exe")
ManageRule("exe", "WeChat.exe")

; Identify applications that close to the tray
; Run, komorebic.exe identify-tray-application exe Discord.exe, , Hide
IdentifyTrayApplication("exe", "Clash Verge.exe")
IdentifyTrayApplication("exe", "copyq.exe")
IdentifyTrayApplication("exe", "QQ.exe")
IdentifyTrayApplication("exe", "RemindMe.exe")
IdentifyTrayApplication("exe", "ShareX.exe")
IdentifyTrayApplication("exe", "Steam++.exe")
IdentifyTrayApplication("exe", "WeChat.exe")

; Identify applications that have overflowing borders
; Run, komorebic.exe identify-border-overflow-application exe Discord.exe, , Hide
IdentifyBorderOverflowApplication("exe", "Code.exe")
IdentifyBorderOverflowApplication("exe", "QQ.exe")
IdentifyBorderOverflowApplication("exe", "vivaldi.exe")
IdentifyBorderOverflowApplication("exe", "WeChat.exe")

; Office
FloatRule("class", "_WwB")
IdentifyLayeredApplication("exe", "EXCEL.EXE")
IdentifyLayeredApplication("exe", "POWERPNT.EXE")
IdentifyLayeredApplication("exe", "WINWORD.EXE")



;##################
;# Start komorebi #
;##################

; Allow komorebi to start managing windows
CompleteConfiguration()

Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide



;###########
;# Keybind #
;###########

!q::
    ; WinClose, A
    Close()
Return

!+q::
    Stop()
Return

; Change the focused window, Alt + Vim direction keys (HJKL)
; !h::
; Focus("left")
; return

; !j::
; Focus("down")
; return

; !k::
; Focus("up")
; return

; !l::
; Focus("right")
; return

!j::
    CycleFocus("next")
Return

!k::
    CycleFocus("previous")
Return

; Move the focused window in a given direction, Alt + Shift + Vim direction keys (HJKL)
; !+h::
; Move("left")
; return

; !+j::
; Move("down")
; return

; !+k::
; Move("up")
; return

; !+l::
; Move("right")
; return

!+j::
    CycleMove("next")
Return

!+k::
    CycleMove("previous")
Return

!h::
    ResizeAxis("horizontal", "decrease")
Return

!l::
    ResizeAxis("horizontal", "increase")
Return

!+h::
    ResizeAxis("vertical", "decrease")
Return

!+l::
    ResizeAxis("vertical", "increase")
Return

; Stack the focused window in a given direction
; !+Left::
; Run, komorebic.exe stack left, , Hide
; return

; !+Down::
; Run, komorebic.exe stack down, , Hide
; return

; !+Up::
; Run, komorebic.exe stack up, , Hide
; return

; !+Right::
; Run, komorebic.exe stack right, , Hide
; return

; !+]::
; Run, komorebic.exe cycle-stack next, , Hide
; return

; !+[::
; Run, komorebic.exe cycle-stack previous, , Hide
; return

; Unstack the focused window
; !+d::
; Run, komorebic.exe unstack, , Hide
; return

; Switch to workspace
focus_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    value := workspace_key_value[key]
    FocusMonitorWorkspace(main_monitor, value)
Return

; Move window to workspace
send_to_monitor_workspace:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    value := workspace_key_value[key]
    SendToMonitorWorkspace(main_monitor, value)
Return

focus_monitor:
    key := SubStr(A_ThisHotkey, StrLen(focus_monitor_prefix) + 1)
    value := monitor_key_value[key]
    FocusMonitor(value)
Return

send_to_monitor:
    key := SubStr(A_ThisHotkey, StrLen(send_to_monitor_prefix) + 1)
    value := monitor_key_value[key]
    SendToMonitor(value)
Return

; Switch to the default bsp tiling layout
; famous binary space partition
; -------------
; |     |     |
; |     |------
; |     |  |  |
; -------------
!b::
    ChangeLayout("bsp")
Return

; Switch to an equal-width, max-height column layout
; max-height column layout on the main workspace
; -------------
; |   |   |   |
; |   |   |   |
; -------------
!c::
    ChangeLayout("columns")
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
    ChangeLayout("rows")
Return

; -----------
; |    |    |
; |    |-----
; |    |    |
; |    |-----
; |    |    |
; -----------
!+c::
    ChangeLayout("vertical-stack")
Return

; ----------------
; |              |
; ----------------
; |    |    |    |
; ----------------
!+r::
    ChangeLayout("horizontal-stack")
Return

; ------------
; |  |    |  |
; |  |    |---
; |  |    |  |
; |  |    |---
; |  |    |  |
; ------------
!+m::
    ChangeLayout("ultrawide-vertical-stack")
Return

; Pause responding to any window events or komorebic commands
!+Capslock::
!+Esc::
    TogglePause()
Return

!Capslock::
!Esc::
    ToggleTiling()
Return

; Float the focused window
!+f::
    ToggleFloat()
Return

; Toggle the Monocle layout for the focused window
!m::
    ToggleMonocle()
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
    Minimize()
Return

; Flip horizontally
!x::
    FlipLayout("horizontal")
Return

; Flip vertically
!y::
    FlipLayout("vertical")
Return

; Promote the focused window to the top of the tree
!+e::
    Promote()
Return

!e::
    PromoteFocus()
Return

; Force a retile if things get janky
!n::
    Retile()
Return

!t::
    Manage()
Return

!+t::
    Unmanage()
Return

; Reload ~/komorebi.ahk
; !o::
; Run, komorebic.exe reload-configuration, , Hide
; return

!+b::
    Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide
Return

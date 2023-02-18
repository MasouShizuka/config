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

SysGet, monitor_count, MonitorCount
global main_monitor := monitor_count - 1

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



;#############
;# Workspace #
;#############

; Ensure there are 7 workspaces created on monitor 0
; Run, komorebic.exe ensure-workspaces 0 7, , Hide
EnsureWorkspaces(main_monitor, 7)

; Give the workspaces some optional names
; Run, komorebic.exe workspace-name 0 0 bsp, , Hide
; Run, komorebic.exe workspace-name 0 1 columns, , Hide
; Run, komorebic.exe workspace-name 0 2 thicc, , Hide
; Run, komorebic.exe workspace-name 0 3 matrix, , Hide
; Run, komorebic.exe workspace-name 0 4 floaty, , Hide
WorkspaceName(main_monitor, 0, """ """)
WorkspaceName(main_monitor, 1, """ """)
WorkspaceName(main_monitor, 2, """ """)
WorkspaceName(main_monitor, 3, """ """)
WorkspaceName(main_monitor, 4, """ """)
WorkspaceName(main_monitor, 5, """ """)
WorkspaceName(main_monitor, 6, """ """)

; Set the padding of the different workspaces
; Run, komorebic.exe container-padding 0 1 30, , Hide
; Run, komorebic.exe workspace-padding 0 1 30, , Hide
; Run, komorebic.exe workspace-padding 0 2 200, , Hide
; Run, komorebic.exe container-padding 0 3 0, , Hide
; Run, komorebic.exe workspace-padding 0 3 0, , Hide

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
!1::
    FocusMonitorWorkspace(main_monitor, 0)
Return

!2::
    FocusMonitorWorkspace(main_monitor, 1)
Return

!3::
    FocusMonitorWorkspace(main_monitor, 2)
Return

!4::
    FocusMonitorWorkspace(main_monitor, 3)
Return

!5::
    FocusMonitorWorkspace(main_monitor, 4)
Return

!6::
    FocusMonitorWorkspace(main_monitor, 5)
Return

!7::
    FocusMonitorWorkspace(main_monitor, 6)
Return

; Move window to workspace
!+1::
    SendToMonitorWorkspace(main_monitor, 0)
Return

!+2::
    SendToMonitorWorkspace(main_monitor, 1)
Return

!+3::
    SendToMonitorWorkspace(main_monitor, 2)
Return

!+4::
    SendToMonitorWorkspace(main_monitor, 3)
Return

!+5::
    SendToMonitorWorkspace(main_monitor, 4)
Return

!+6::
    SendToMonitorWorkspace(main_monitor, 5)
Return

!+7::
    SendToMonitorWorkspace(main_monitor, 6)
Return

!u::
    FocusMonitor(0)
Return

!i::
    FocusMonitor(1)
Return

!o::
    FocusMonitor(2)
Return

!+u::
    SendToMonitor(0)
Return

!+i::
    SendToMonitor(1)
Return

!+o::
    SendToMonitor(2)
Return

; Switch to the default bsp tiling layout
!b::
    ChangeLayout("bsp")
Return

; Switch to an equal-width, max-height column layout
!c::
    ChangeLayout("columns")
Return

; Switch to an equal-height, max-width column layout
!r::
    ChangeLayout("rows")
Return

!+c::
    ChangeLayout("vertical-stack")
Return

!+r::
    ChangeLayout("horizontal-stack")
Return

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

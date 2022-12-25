#SingleInstance Force

; You can generate a fresh version of this file with "komorebic ahk-library"
#Include %A_ScriptDir%\komorebic.lib.ahk

#Persistent
OnExit("komorebic_stop")
komorebic_stop() {
    if (is_taskbar_hide) {
        unhide_taskbar()
    }
    Stop()
    Run, rm ~/komorebic.sock, , Hide
    Run, rm -rf ~/AppData/Local/komorebi, , Hide
    return
}



hide_taskbar() {
    WinSet, Transparent, 0, ahk_class Shell_TrayWnd
}
unhide_taskbar() {
    WinSet, Transparent, 255, ahk_class Shell_TrayWnd
    WinSet, Transparent, OFF, ahk_class Shell_TrayWnd
}
global is_taskbar_hide := false



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
WindowHidingBehaviour("minimize")

; Set cross-monitor move behaviour to insert instead of swap
CrossMonitorMoveBehaviour("insert")

; Enable Active Window Border
ActiveWindowBorder("enable")
ActiveWindowBorderColour(66, 165, 245, "single")

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
FloatRule("class", "TApplication")
; Always float, matching on title
; Run, komorebic.exe float-rule title "Control Panel", , Hide
; Run, komorebic.exe float-rule title Calculator, , Hide
FloatRule("title", "Hotkey sink")
; Always float, matching on executable name
; Run, komorebic.exe float-rule exe Wally.exe, , Hide
; Run, komorebic.exe float-rule exe wincompose.exe, , Hide
; Run, komorebic.exe float-rule exe 1Password.exe, , Hide
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
IdentifyBorderOverflowApplication("exe", "cloudmusic.exe")
IdentifyBorderOverflowApplication("exe", "Code.exe")
IdentifyBorderOverflowApplication("exe", "QQ.exe")
IdentifyBorderOverflowApplication("exe", "ShareX.exe")
IdentifyBorderOverflowApplication("exe", "vivaldi.exe")
IdentifyBorderOverflowApplication("exe", "WeChat.exe")

; Office
FloatRule("class", "_WwB")
IdentifyBorderOverflowApplication("exe", "EXCEL.EXE")
IdentifyBorderOverflowApplication("exe", "POWERPNT.EXE")
IdentifyBorderOverflowApplication("exe", "WINWORD.EXE")
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
WinClose, A
return

!+q::
Stop()
return

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
return

!k::
CycleFocus("previous")
return

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
return

!+k::
CycleMove("previous")
return

!h::
ResizeAxis("horizontal", "decrease")
return

!l::
ResizeAxis("horizontal", "increase")
return

!+h::
ResizeAxis("vertical", "decrease")
return

!+l::
ResizeAxis("vertical", "increase")
return

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
; Run, komorebic.exe focus-workspace 0, , Hide
FocusMonitorWorkspace(main_monitor, 0)
return

!2::
; Run, komorebic.exe focus-workspace 1, , Hide
FocusMonitorWorkspace(main_monitor, 1)
return

!3::
; Run, komorebic.exe focus-workspace 2, , Hide
FocusMonitorWorkspace(main_monitor, 2)
return

!4::
; Run, komorebic.exe focus-workspace 3, , Hide
FocusMonitorWorkspace(main_monitor, 3)
return

!5::
; Run, komorebic.exe focus-workspace 4, , Hide
FocusMonitorWorkspace(main_monitor, 4)
return

!6::
; Run, komorebic.exe focus-workspace 5, , Hide
FocusMonitorWorkspace(main_monitor, 5)
return

!7::
; Run, komorebic.exe focus-workspace 6, , Hide
FocusMonitorWorkspace(main_monitor, 6)
return

; Move window to workspace
!+1::
; Run, komorebic.exe send-to-workspace 0, , Hide
SendToMonitorWorkspace(main_monitor, 0)
return

!+2::
; Run, komorebic.exe send-to-workspace 1, , Hide
SendToMonitorWorkspace(main_monitor, 1)
return

!+3::
; Run, komorebic.exe send-to-workspace 2, , Hide
SendToMonitorWorkspace(main_monitor, 2)
return

!+4::
; Run, komorebic.exe send-to-workspace 3, , Hide
SendToMonitorWorkspace(main_monitor, 3)
return

!+5::
; Run, komorebic.exe send-to-workspace 4, , Hide
SendToMonitorWorkspace(main_monitor, 4)
return

!+6::
; Run, komorebic.exe send-to-workspace 5, , Hide
SendToMonitorWorkspace(main_monitor, 5)
return

!+7::
; Run, komorebic.exe send-to-workspace 6, , Hide
SendToMonitorWorkspace(main_monitor, 6)
return

!u::
FocusMonitor(0)
return

!i::
FocusMonitor(1)
return

!o::
FocusMonitor(2)
return

!+u::
SendToMonitor(0)
return

!+i::
SendToMonitor(1)
return

!+o::
SendToMonitor(2)
return

; Switch to the default bsp tiling layout
!b::
; Run, komorebic.exe workspace-layout 0 0 bsp, , Hide
ChangeLayout("bsp")
return

; Switch to an equal-width, max-height column layout
!c::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
ChangeLayout("columns")
return

; Switch to an equal-height, max-width column layout
!r::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
ChangeLayout("rows")
return

!+c::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
ChangeLayout("vertical-stack")
return

!+r::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
ChangeLayout("horizontal-stack")
return

!+m::
ChangeLayout("ultrawide-vertical-stack")
return

; Pause responding to any window events or komorebic commands
!+Capslock::
!+Esc::
TogglePause()
return

!Capslock::
!Esc::
ToggleTiling()
return

; Float the focused window
!+f::
ToggleFloat()
return

; Toggle the Monocle layout for the focused window
!m::
ToggleMonocle()
return

; Toggle native maximize for the focused window
!f::
WinGet, MX, MinMax, A
if (MX) {
    WinRestore, A
} else {
    WinMaximize, A
}
return

!d::
WinMinimize, A
return

; Flip horizontally
!x::
FlipLayout("horizontal")
return

; Flip vertically
!y::
FlipLayout("vertical")
return

; Promote the focused window to the top of the tree
!+e::
Promote()
return

!e::
PromoteFocus()
return

; Force a retile if things get janky
!n::
Retile()
return

!t::
Manage()
return

!+t::
Unmanage()
return

; Reload ~/komorebi.ahk
; !o::
; Run, komorebic.exe reload-configuration, , Hide
; return

!+b::
Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide
return

!z::
if (is_taskbar_hide) {
    unhide_taskbar()
} else {
    hide_taskbar()
}
is_taskbar_hide := !is_taskbar_hide
return

#SingleInstance Force

#Persistent
OnExit("komorebic_stop")
komorebic_stop() {
    Run, komorebic.exe stop, , Hide
    if (is_taskbar_hide) {
        unhide_taskbar()
    }
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

Run, komorebic.exe start --await-configuration, , Hide
Sleep, 3000



;###########
;# Setting #
;###########

global main_monitor := 0
SysGet, monitor_count, MonitorCount
if (monitor_count > 1) {
    main_monitor := monitor_count - 1
}

; Configure the invisible border dimensions
Run, komorebic.exe invisible-borders 7 0 14 7, , Hide

; Enable hot reloading of changes to this file
Run, komorebic.exe watch-configuration enable, , Hide

; Window hiding behavior
Run, komorebic.exe window-hiding-behaviour minimize, , Hide

; Enable Active Window Border
Run, komorebic.exe active-window-border enable, , Hide
Run, komorebic.exe active-window-border-colour 214 172 255 --window-kind single, Hide

; Configure focus related with mouse
Run, komorebic.exe focus-follows-mouse disable, , Hide
Run, komorebic.exe mouse-follows-focus enable, , Hide



;#############
;# Workspace #
;#############

; Ensure there are 7 workspaces created on monitor 0
; Run, komorebic.exe ensure-workspaces 0 7, , Hide
Run, komorebic.exe ensure-workspaces %main_monitor% 7, , Hide

; Give the workspaces some optional names
; Run, komorebic.exe workspace-name 0 0 bsp, , Hide
; Run, komorebic.exe workspace-name 0 1 columns, , Hide
; Run, komorebic.exe workspace-name 0 2 thicc, , Hide
; Run, komorebic.exe workspace-name 0 3 matrix, , Hide
; Run, komorebic.exe workspace-name 0 4 floaty, , Hide
Run, komorebic.exe workspace-name %main_monitor% 0 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 1 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 2 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 3 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 4 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 5 " ", , Hide
Run, komorebic.exe workspace-name %main_monitor% 6 " ", , Hide

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
Run, komorebic.exe workspace-rule exe QQ.exe %main_monitor% 2, , Hide
Run, komorebic.exe workspace-rule exe WeChat.exe %main_monitor% 2, , Hide
Run, komorebic.exe workspace-rule exe cloudmusic.exe %main_monitor% 3, , Hide
Run, komorebic.exe workspace-rule exe foobar2000.exe %main_monitor% 3, , Hide
Run, komorebic.exe workspace-rule exe mpv.exe %main_monitor% 4, , Hide
Run, komorebic.exe workspace-rule exe Thunder.exe %main_monitor% 5, , Hide



;#######
;# APP #
;#######

; Always float, matching on class
; Run, komorebic.exe float-rule class SunAwtDialog, , Hide
; Run, komorebic.exe float-rule class TaskManagerWindow, , Hide
Run, komorebic.exe float-rule class ExplorerBrowserControl, , Hide
; Always float, matching on title
; Run, komorebic.exe float-rule title "Control Panel", , Hide
; Run, komorebic.exe float-rule title Calculator, , Hide
Run, komorebic.exe float-rule title "Hotkey sink", , Hide
; Always float, matching on executable name
; Run, komorebic.exe float-rule exe Wally.exe, , Hide
; Run, komorebic.exe float-rule exe wincompose.exe, , Hide
; Run, komorebic.exe float-rule exe 1Password.exe, , Hide
Run, komorebic.exe float-rule exe ApplicationFrameHost.exe, , Hide
Run, komorebic.exe float-rule exe "Clash Verge.exe", , Hide
Run, komorebic.exe float-rule exe copyq.exe, , Hide
Run, komorebic.exe float-rule exe Flow.Launcher.exe, , Hide

; Always manage forcibly these applications that don't automatically get picked up by komorebi
; Run, komorebic.exe manage-rule exe TIM.exe, , Hide
Run, komorebic.exe manage-rule exe foobar2000.exe, , Hide
Run, komorebic.exe manage-rule exe mpv.exe, , Hide
Run, komorebic.exe manage-rule exe QQ.exe, , Hide
Run, komorebic.exe manage-rule exe TE64.exe, , Hide
Run, komorebic.exe manage-rule exe WeChat.exe, , Hide

; Identify applications that close to the tray
; Run, komorebic.exe identify-tray-application exe Discord.exe, , Hide
Run, komorebic.exe identify-tray-application exe "Clash Verge.exe", , Hide
Run, komorebic.exe identify-tray-application exe copyq.exe, , Hide
Run, komorebic.exe identify-tray-application exe QQ.exe, , Hide
Run, komorebic.exe identify-tray-application exe RemindMe.exe, , Hide
Run, komorebic.exe identify-tray-application exe ShareX.exe, , Hide
Run, komorebic.exe identify-tray-application exe Steam++.exe, , Hide
Run, komorebic.exe identify-tray-application exe WeChat.exe, , Hide

; Identify applications that have overflowing borders
; Run, komorebic.exe identify-border-overflow-application exe Discord.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe cloudmusic.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe Code.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe QQ.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe ShareX.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe vivaldi.exe, , Hide
Run, komorebic.exe identify-border-overflow-application exe WeChat.exe, , Hide

; Office
Run, komorebic.exe float-rule exe WINWORD.EXE, , Hide
Run, komorebic.exe float-rule exe POWERPNT.EXE, , Hide
Run, komorebic.exe float-rule exe EXCEL.EXE, , Hide
; Run, komorebic.exe float-rule class _WwB, , Hide
; Run, komorebic.exe identify-border-overflow-application exe WINWORD.EXE, , Hide
; Run, komorebic.exe identify-border-overflow-application exe POWERPNT.EXE, , Hide
; Run, komorebic.exe identify-border-overflow-application exe EXCEL.EXE, , Hide
; Run, komorebic.exe identify-layered-application exe WINWORD.EXE, , Hide
; Run, komorebic.exe identify-layered-application exe POWERPNT.EXE, , Hide
; Run, komorebic.exe identify-layered-application exe EXCEL.EXE, , Hide



;##################
;# Start komorebi #
;##################

Run, komorebic.exe complete-configuration, , Hide
Run, pythonw %A_ScriptDir%/yasb/src/main.py, , Hide



;###########
;# Keybind #
;###########

!q::
WinClose, A
return

!+q::
Run, komorebic.exe stop, , Hide
return

; Change the focused window, Alt + Vim direction keys
; !h::
; Run, komorebic.exe focus left, , Hide
; return

; !j::
; Run, komorebic.exe focus down, , Hide
; return

; !k::
; Run, komorebic.exe focus up, , Hide
; return

; !l::
; Run, komorebic.exe focus right, , Hide
; return

!j::
Run, komorebic.exe cycle-focus next, , Hide
return

!k::
Run, komorebic.exe cycle-focus previous, , Hide
return

; Move the focused window in a given direction, Alt + Shift + Vim direction keys
; !+h::
; Run, komorebic.exe move left, , Hide
; return

; !+j::
; Run, komorebic.exe move down, , Hide
; return

; !+k::
; Run, komorebic.exe move up, , Hide
; return

; !+l::
; Run, komorebic.exe move right, , Hide
; return

!+j::
Run, komorebic.exe cycle-move next, , Hide
return

!+k::
Run, komorebic.exe cycle-move previous, , Hide
return

!h::
Run, komorebic.exe resize-axis horizontal decrease, , Hide
return

!l::
Run, komorebic.exe resize-axis horizontal increase, , Hide
return

!+h::
Run, komorebic.exe resize-axis vertical decrease, , Hide
return

!+l::
Run, komorebic.exe resize-axis vertical increase, , Hide
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
Run, komorebic.exe focus-monitor-workspace %main_monitor% 0, , Hide
return

!2::
; Run, komorebic.exe focus-workspace 1, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 1, , Hide
return

!3::
; Run, komorebic.exe focus-workspace 2, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 2, , Hide
return

!4::
; Run, komorebic.exe focus-workspace 3, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 3, , Hide
return

!5::
; Run, komorebic.exe focus-workspace 4, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 4, , Hide
return

!6::
; Run, komorebic.exe focus-workspace 5, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 5, , Hide
return

!7::
; Run, komorebic.exe focus-workspace 6, , Hide
Run, komorebic.exe focus-monitor-workspace %main_monitor% 6, , Hide
return

; Move window to workspace
!+1::
; Run, komorebic.exe send-to-workspace 0, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 0, , Hide
return

!+2::
; Run, komorebic.exe send-to-workspace 1, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 1, , Hide
return

!+3::
; Run, komorebic.exe send-to-workspace 2, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 2, , Hide
return

!+4::
; Run, komorebic.exe send-to-workspace 3, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 3, , Hide
return

!+5::
; Run, komorebic.exe send-to-workspace 4, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 4, , Hide
return

!+6::
; Run, komorebic.exe send-to-workspace 5, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 5, , Hide
return

!+7::
; Run, komorebic.exe send-to-workspace 6, , Hide
Run, komorebic.exe send-to-monitor-workspace %main_monitor% 6, , Hide
return

!u::
Run, komorebic.exe focus-monitor 0, , Hide
return

!i::
Run, komorebic.exe focus-monitor 1, , Hide
return

!o::
Run, komorebic.exe focus-monitor 2, , Hide
return

!+u::
Run, komorebic.exe send-to-monitor 0, , Hide
return

!+i::
Run, komorebic.exe send-to-monitor 1, , Hide
return

!+o::
Run, komorebic.exe send-to-monitor 2, , Hide
return

; Switch to the default bsp tiling layout
!b::
; Run, komorebic.exe workspace-layout 0 0 bsp, , Hide
Run, komorebic.exe change-layout bsp, , Hide
return

; Switch to an equal-width, max-height column layout
!c::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
Run, komorebic.exe change-layout columns, , Hide
return

; Switch to an equal-height, max-width column layout
!r::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
Run, komorebic.exe change-layout rows, , Hide
return

!+c::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
Run, komorebic.exe change-layout vertical-stack, , Hide
return

!+r::
; Run, komorebic.exe workspace-layout 0 0 columns, , Hide
Run, komorebic.exe change-layout horizontal-stack, , Hide
return

!+m::
Run, komorebic.exe change-layout ultrawide-vertical-stack, , Hide
return

; Pause responding to any window events or komorebic commands
!+esc::
Run, komorebic.exe toggle-pause, , Hide
return

!esc::
Run, komorebic.exe toggle-tiling, , Hide
return

; Float the focused window
!+f::
Run, komorebic.exe toggle-float, , Hide
return

; Toggle the Monocle layout for the focused window
!m::
Run, komorebic.exe toggle-monocle, , Hide
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
Run, komorebic.exe flip-layout horizontal, , Hide
return

; Flip vertically
!y::
Run, komorebic.exe flip-layout vertical, , Hide
return

; Promote the focused window to the top of the tree
!+e::
Run, komorebic.exe promote, , Hide
return

!e::
Run, komorebic.exe promote-focus, , Hide
return

; Force a retile if things get janky
!n::
Run, komorebic.exe retile, , Hide
return

!t::
Run, komorebic.exe manage, , Hide
return

!+t::
Run, komorebic.exe unmanage, , Hide
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

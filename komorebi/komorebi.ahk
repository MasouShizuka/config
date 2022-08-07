#SingleInstance Force

global komorebi_path := "D:/Tools/komorebi/"

#Persistent
OnExit("komorebic_stop")
komorebic_stop()
{
    Run, %komorebi_path%komorebic.exe stop, , Hide
    return
}

global process_name_list := ["TE64.exe"]
refresh_window()
{
    WinGet, Active_Process, ProcessName, A
    for index, process_name in process_name_list
    {
        if (Active_Process = process_name)
        {
            A_prev := A
            Gui, Color, EEAA99
            Gui +LastFound
            WinSet, TransColor, EEAA99
            Gui, Show
            Gui, Destroy
            WinActivate, A_prev
            break
        }
    }
}

; Start komorebi
Run, %komorebi_path%komorebic.exe start, , Hide
Sleep, 3000



;###########
;# Setting #
;###########

; Configure the invisible border dimensions
Run, %komorebi_path%komorebic.exe invisible-borders 7 0 14 7, , Hide

; Enable hot reloading of changes to this file
Run, %komorebi_path%komorebic.exe watch-configuration enable, , Hide

; Window hiding behavior
Run, %komorebi_path%komorebic.exe window-hiding-behaviour minimize, , Hide

; Configure focus related with mouse
Run, %komorebi_path%komorebic.exe focus-follows-mouse disable, , Hide
Run, %komorebi_path%komorebic.exe mouse-follows-focus enable, , Hide



;#############
;# Workspace #
;#############

; Ensure there are 7 workspaces created on monitor 0
Run, %komorebi_path%komorebic.exe ensure-workspaces 0 7, , Hide

; Give the workspaces some optional names
; Run, %komorebi_path%komorebic.exe workspace-name 0 0 bsp, , Hide
; Run, %komorebi_path%komorebic.exe workspace-name 0 1 columns, , Hide
; Run, %komorebi_path%komorebic.exe workspace-name 0 2 thicc, , Hide
; Run, %komorebi_path%komorebic.exe workspace-name 0 3 matrix, , Hide
; Run, %komorebi_path%komorebic.exe workspace-name 0 4 floaty, , Hide
Run, bash %komorebi_path%komorebi_workspace.sh, , Hide
Run, bash %komorebi_path%komorebi_yasb.sh, , Hide

; Set the padding of the different workspaces
; Run, %komorebi_path%komorebic.exe container-padding 0 1 30, , Hide
; Run, %komorebi_path%komorebic.exe workspace-padding 0 1 30, , Hide
; Run, %komorebi_path%komorebic.exe workspace-padding 0 2 200, , Hide
; Run, %komorebi_path%komorebic.exe container-padding 0 3 0, , Hide
; Run, %komorebi_path%komorebic.exe workspace-padding 0 3 0, , Hide

; Set the layouts of different workspaces
; Run, %komorebi_path%komorebic.exe workspace-layout 0 1 columns, , Hide

; Set the floaty layout to not tile any windows
; Run, %komorebi_path%komorebic.exe workspace-tiling 0 4 disable, , Hide

; Always show chat apps on the second workspace
; Run, %komorebi_path%komorebic.exe workspace-rule exe slack.exe 0 1, , Hide
; Run, %komorebi_path%komorebic.exe workspace-rule exe Discord.exe 0 1, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe vivaldi.exe 0 1, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe QQ.exe 0 2, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe WeChat.exe 0 2, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe cloudmusic.exe 0 3, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe foobar2000.exe 0 3, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe mpv.exe 0 4, , Hide
Run, %komorebi_path%komorebic.exe workspace-rule exe Thunder.exe 0 5, , Hide



;#######
;# APP #
;#######

; Always float, matching on class
; Run, %komorebi_path%komorebic.exe float-rule class SunAwtDialog, , Hide
; Run, %komorebi_path%komorebic.exe float-rule class TaskManagerWindow, , Hide
; Always float, matching on title
; Run, %komorebi_path%komorebic.exe float-rule title "Control Panel", , Hide
; Run, %komorebi_path%komorebic.exe float-rule title Calculator, , Hide
; Always float, matching on executable name
; Run, %komorebi_path%komorebic.exe float-rule exe Wally.exe, , Hide
; Run, %komorebi_path%komorebic.exe float-rule exe wincompose.exe, , Hide
; Run, %komorebi_path%komorebic.exe float-rule exe 1Password.exe, , Hide
Run, %komorebi_path%komorebic.exe float-rule exe ApplicationFrameHost.exe, , Hide
Run, %komorebi_path%komorebic.exe float-rule exe "Clash Verge.exe", , Hide
Run, %komorebi_path%komorebic.exe float-rule exe copyq.exe, , Hide
Run, %komorebi_path%komorebic.exe float-rule exe Flow.Launcher.exe, , Hide

; Always manage forcibly these applications that don't automatically get picked up by komorebi
; Run, %komorebi_path%komorebic.exe manage-rule exe TIM.exe, , Hide
Run, %komorebi_path%komorebic.exe manage-rule exe QQ.exe, , Hide
Run, %komorebi_path%komorebic.exe manage-rule exe WeChat.exe, , Hide
Run, %komorebi_path%komorebic.exe manage-rule exe foobar2000.exe, , Hide
Run, %komorebi_path%komorebic.exe manage-rule exe mpv.exe, , Hide

; Identify applications that close to the tray
; Run, %komorebi_path%komorebic.exe identify-tray-application exe Discord.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe "Clash Verge.exe", , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe copyq.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe Flow.Launcher.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe ShareX.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe Steam++.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe QQ.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe WeChat.exe, , Hide
Run, %komorebi_path%komorebic.exe identify-tray-application exe foobar2000.exe, , Hide

; Identify applications that have overflowing borders
; Run, %komorebi_path%komorebic.exe identify-border-overflow exe Discord.exe, , Hide



;###########
;# Keybind #
;###########

!q::
WinClose, A
return

!+q::
Run, %komorebi_path%komorebic.exe stop, , Hide
return

; Change the focused window, Alt + Vim direction keys
; !h::
; Run, %komorebi_path%komorebic.exe focus left, , Hide
; return

; !j::
; Run, %komorebi_path%komorebic.exe focus down, , Hide
; return

; !k::
; Run, %komorebi_path%komorebic.exe focus up, , Hide
; return

; !l::
; Run, %komorebi_path%komorebic.exe focus right, , Hide
; return

!j::
Run, %komorebi_path%komorebic.exe cycle-focus next, , Hide
Sleep 200
refresh_window()
return

!k::
Run, %komorebi_path%komorebic.exe cycle-focus previous, , Hide
Sleep 200
refresh_window()
return

; Move the focused window in a given direction, Alt + Shift + Vim direction keys
; !+h::
; Run, %komorebi_path%komorebic.exe move left, , Hide
; return

; !+j::
; Run, %komorebi_path%komorebic.exe move down, , Hide
; return

; !+k::
; Run, %komorebi_path%komorebic.exe move up, , Hide
; return

; !+l::
; Run, %komorebi_path%komorebic.exe move right, , Hide
; return

!+j::
Run, %komorebi_path%komorebic.exe cycle-move next, , Hide
Sleep 200
refresh_window()
return

!+k::
Run, %komorebi_path%komorebic.exe cycle-move previous, , Hide
Sleep 200
refresh_window()
return

!h::
Run, %komorebi_path%komorebic.exe resize-axis horizontal decrease, , Hide
return

!l::
Run, %komorebi_path%komorebic.exe resize-axis horizontal increase, , Hide
return

!+h::
Run, %komorebi_path%komorebic.exe resize-axis vertical decrease, , Hide
return

!+l::
Run, %komorebi_path%komorebic.exe resize-axis vertical increase, , Hide
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
; Run, %komorebi_path%komorebic.exe cycle-stack next, , Hide
; return

; !+[::
; Run, %komorebi_path%komorebic.exe cycle-stack previous, , Hide
; return

; Unstack the focused window
; !+d::
; Run, %komorebi_path%komorebic.exe unstack, , Hide
; return

; Switch to workspace
!1::
Run, %komorebi_path%komorebic.exe focus-workspace 0, , Hide
Sleep 1000
refresh_window()
return

!2::
Run, %komorebi_path%komorebic.exe focus-workspace 1, , Hide
Sleep 1000
refresh_window()
return

!3::
Run, %komorebi_path%komorebic.exe focus-workspace 2, , Hide
Sleep 1000
refresh_window()
return

!4::
Run, %komorebi_path%komorebic.exe focus-workspace 3, , Hide
Sleep 1000
refresh_window()
return

!5::
Run, %komorebi_path%komorebic.exe focus-workspace 4, , Hide
Sleep 1000
refresh_window()
return

!6::
Run, %komorebi_path%komorebic.exe focus-workspace 5, , Hide
Sleep 1000
refresh_window()
return

!7::
Run, %komorebi_path%komorebic.exe focus-workspace 6, , Hide
Sleep 1000
refresh_window()
return

; Move window to workspace
!+1::
Run, %komorebi_path%komorebic.exe send-to-workspace 0, , Hide
return

!+2::
Run, %komorebi_path%komorebic.exe send-to-workspace 1, , Hide
return

!+3::
Run, %komorebi_path%komorebic.exe send-to-workspace 2, , Hide
return

!+4::
Run, %komorebi_path%komorebic.exe send-to-workspace 3, , Hide
return

!+5::
Run, %komorebi_path%komorebic.exe send-to-workspace 4, , Hide
return

!+6::
Run, %komorebi_path%komorebic.exe send-to-workspace 5, , Hide
return

!+7::
Run, %komorebi_path%komorebic.exe send-to-workspace 6, , Hide
return

!u::
Run, %komorebi_path%komorebic.exe cycle-monitor next, , Hide
return

!i::
Run, %komorebi_path%komorebic.exe cycle-monitor previous, , Hide
return

!+u::
Run, %komorebi_path%komorebic.exe send-to-monitor 0, , Hide
return

!+i::
Run, %komorebi_path%komorebic.exe send-to-monitor 1, , Hide
return

; Switch to the default bsp tiling layout
!b::
; Run, %komorebi_path%komorebic.exe workspace-layout 0 0 bsp, , Hide
Run, %komorebi_path%komorebic.exe change-layout bsp, , Hide
return

; Switch to an equal-width, max-height column layout
!c::
; Run, %komorebi_path%komorebic.exe workspace-layout 0 0 columns, , Hide
Run, %komorebi_path%komorebic.exe change-layout columns, , Hide
return

; Switch to an equal-height, max-width column layout
!r::
; Run, %komorebi_path%komorebic.exe workspace-layout 0 0 columns, , Hide
Run, %komorebi_path%komorebic.exe change-layout rows, , Hide
return

!+c::
; Run, %komorebi_path%komorebic.exe workspace-layout 0 0 columns, , Hide
Run, %komorebi_path%komorebic.exe change-layout vertical-stack, , Hide
return

!+r::
; Run, %komorebi_path%komorebic.exe workspace-layout 0 0 columns, , Hide
Run, %komorebi_path%komorebic.exe change-layout horizontal-stack, , Hide
return

!+m::
Run, %komorebi_path%komorebic.exe change-layout ultrawide-vertical-stack, , Hide
return

; Pause responding to any window events or komorebic commands, Alt + P
!+esc::
Run, %komorebi_path%komorebic.exe toggle-pause, , Hide
return

!esc::
Run, %komorebi_path%komorebic.exe toggle-tiling, , Hide
return

; Float the focused window, Alt + T
!+t::
Run, %komorebi_path%komorebic.exe toggle-float, , Hide
return

; Toggle the Monocle layout for the focused window, Alt + Shift + F
!m::
Run, %komorebi_path%komorebic.exe toggle-monocle, , Hide
return

; Toggle native maximize for the focused window, Alt + Shift + =
!f::
Run, %komorebi_path%komorebic.exe toggle-maximize, , Hide
Run, %komorebi_path%komorebic.exe toggle-pause, , Hide
Run, %komorebi_path%komorebic.exe toggle-maximize, , Hide
return

!d::
WinMinimize, A
return

; Flip horizontally, Alt + X
!x::
Run, %komorebi_path%komorebic.exe flip-layout horizontal, , Hide
return

; Flip vertically, Alt + Y
!y::
Run, %komorebi_path%komorebic.exe flip-layout vertical, , Hide
return

; Promote the focused window to the top of the tree, Alt + Shift + Enter
!e::
Run, %komorebi_path%komorebic.exe promote, , Hide
return

; Force a retile if things get janky, Alt + Shift + R
!n::
Run, %komorebi_path%komorebic.exe retile, , Hide
return

!t::
Run, %komorebi_path%komorebic.exe manage, , Hide
Run, %komorebi_path%komorebic.exe cycle-focus next, , Hide
return

; Reload ~/komorebi.ahk, Alt + O
; !o::
; Run, %komorebi_path%komorebic.exe reload-configuration, , Hide
; return

!+b::
Run, bash %komorebi_path%komorebi_yasb.sh, , Hide
return

#SingleInstance Force
#NoTrayIcon

Persistent
OnExit((*) => komorebic_stop())

localappdata := EnvGet("LOCALAPPDATA")

komorebic_stop() {
    While (ProcessExist("yasb.exe")) {
        ProcessClose("yasb.exe")
    }

    RunWait("komorebic.exe stop", , "Hide")

    DirDelete(localappdata . "/komorebi", true)
}


; ╭────────────────╮
; │ Start komorebi │
; ╰────────────────╯

DirCreate(localappdata . "/komorebi")
RunWait("komorebic.exe start --await-configuration", , "Hide")


; ╭─────────╮
; │ Setting │
; ╰─────────╯

RunWait("komorebic.exe invisible-borders 7 0 14 7", , "Hide")

RunWait("komorebic.exe watch-configuration enable", , "Hide")

RunWait("komorebic.exe window-hiding-behaviour cloak", , "Hide")

RunWait("komorebic.exe cross-monitor-move-behaviour insert", , "Hide")

RunWait("komorebic.exe active-window-border enable", , "Hide")
RunWait("komorebic.exe active-window-border-colour 66 165 245 --window-kind single", , "Hide")
RunWait("komorebic.exe active-window-border-colour 256 165 66 --window-kind stack", , "Hide")
RunWait("komorebic.exe active-window-border-colour 255 51 153 --window-kind monocle", , "Hide")
RunWait("komorebic.exe active-window-border-width 14", , "Hide")

RunWait("komorebic.exe focus-follows-mouse disable --implementation windows", , "Hide")
RunWait("komorebic.exe mouse-follows-focus enable", , "Hide")


; ╭─────────╮
; │ Monitor │
; ╰─────────╯

monitor_count := SysGet(80)
global main_monitor := monitor_count - 1

global monitor_key_value := Map(
    "u", 0,
    "i", 1,
    "o", 2
)

global focus_monitor_prefix := "!"
For key, value in monitor_key_value {
    Hotkey(focus_monitor_prefix . key, focus_monitor)
}

global send_to_monitor_prefix := "!+"
For key, value in monitor_key_value {
    Hotkey(send_to_monitor_prefix . key, send_to_monitor)
}


; ╭───────────╮
; │ Workspace │
; ╰───────────╯

global workspace_key_value := Map(
    "1", [0, " "],
    "2", [1, " "],
    "3", [2, " "],
    "4", [3, " "],
    "5", [4, " "],
    "6", [5, " "],
    "7", [6, " "]
)

global container_padding := 10
global workspace_padding := 10

RunWait(Format("komorebic.exe ensure-workspaces {} {}", main_monitor, workspace_key_value.Count), , "Hide")
For key, value in workspace_key_value {
    RunWait(Format("komorebic.exe workspace-name {} {} `"{}`"", main_monitor, value[1], value[2]), , "Hide")
}

For key, value in workspace_key_value {
    RunWait(Format("komorebic.exe container-padding {} {} {}", main_monitor, value[1], container_padding), , "Hide")
    RunWait(Format("komorebic.exe workspace-padding {} {} {}", main_monitor, value[1], workspace_padding), , "Hide")
}
For key, value in monitor_key_value {
    If (value != main_monitor) {
        RunWait(Format("komorebic.exe container-padding {} 0 {}", value, container_padding), , "Hide")
        RunWait(Format("komorebic.exe workspace-padding {} 0 {}", value, workspace_padding), , "Hide")
    }
}

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey(focus_monitor_workspace_prefix . key, focus_monitor_workspace)
}

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey(send_to_monitor_workspace_prefix . key, send_to_monitor_workspace)
}

RunWait(Format("komorebic.exe workspace-rule exe `"QQ.exe`" {} 2", main_monitor), , "Hide")
RunWait(Format("komorebic.exe workspace-rule exe `"WeChat.exe`" {} 2", main_monitor), , "Hide")
RunWait(Format("komorebic.exe workspace-rule exe `"cloudmusic.exe`" {} 3", main_monitor), , "Hide")
RunWait(Format("komorebic.exe workspace-rule exe `"foobar2000.exe`" {} 3", main_monitor), , "Hide")
RunWait(Format("komorebic.exe workspace-rule exe `"Thunder.exe`" {} 4", main_monitor), , "Hide")
RunWait(Format("komorebic.exe workspace-rule exe `"nekoray.exe`" {} 5", main_monitor), , "Hide")


; ╭─────╮
; │ APP │
; ╰─────╯

RunWait("komorebic.exe float-rule class `"ExplorerBrowserControl`"", , "Hide")
RunWait("komorebic.exe float-rule class `"jsplitter_panel_container`"", , "Hide")
RunWait("komorebic.exe float-rule class `"OperationStatusWindow`"", , "Hide")
RunWait("komorebic.exe float-rule class `"SessionDragWnd`"", , "Hide")
RunWait("komorebic.exe float-rule class `"TApplication`"", , "Hide")

RunWait("komorebic.exe float-rule title `"Hotkey sink`"", , "Hide")

RunWait("komorebic.exe float-rule exe `"ahk.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"ApplicationFrameHost.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"Clash Verge.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"copyq.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"Flow.Launcher.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"MyKeymap.exe`"", , "Hide")
RunWait("komorebic.exe float-rule exe `"yasb.exe`"", , "Hide")

RunWait("komorebic.exe manage-rule exe `"QQ.exe`"", , "Hide")
RunWait("komorebic.exe manage-rule exe `"TE64.exe`"", , "Hide")
RunWait("komorebic.exe manage-rule exe `"WeChat.exe`"", , "Hide")
RunWait("komorebic.exe manage-rule exe `"wezterm-gui.exe`"", , "Hide")

RunWait("komorebic.exe identify-tray-application exe `"Clash Verge.exe`"", , "Hide")
RunWait("komorebic.exe identify-tray-application exe `"copyq.exe`"", , "Hide")
RunWait("komorebic.exe identify-tray-application exe `"QQ.exe`"", , "Hide")
RunWait("komorebic.exe identify-tray-application exe `"RemindMe.exe`"", , "Hide")
RunWait("komorebic.exe identify-tray-application exe `"ShareX.exe`"", , "Hide")
RunWait("komorebic.exe identify-tray-application exe `"WeChat.exe`"", , "Hide")

RunWait("komorebic.exe identify-border-overflow-application exe `"cloudmusic.exe`"", , "Hide")
RunWait("komorebic.exe identify-border-overflow-application exe `"Code.exe`"", , "Hide")
RunWait("komorebic.exe identify-border-overflow-application exe `"neovide.exe`"", , "Hide")
RunWait("komorebic.exe identify-border-overflow-application exe `"QQ.exe`"", , "Hide")
RunWait("komorebic.exe identify-border-overflow-application exe `"WeChat.exe`"", , "Hide")

RunWait("komorebic.exe float-rule class `"_WwB`"", , "Hide")
RunWait("komorebic.exe identify-layered-application exe `"EXCEL.EXE`"", , "Hide")
RunWait("komorebic.exe identify-layered-application exe `"POWERPNT.EXE`"", , "Hide")
RunWait("komorebic.exe identify-layered-application exe `"WINWORD.EXE`"", , "Hide")


; ╭────────────────╮
; │ Start komorebi │
; ╰────────────────╯

RunWait("komorebic.exe complete-configuration", , "Hide")

While (ProcessExist("yasb.exe")) {
    ProcessClose("yasb.exe")
}
Run(Format("{}/yasb.exe", A_ScriptDir), , "Hide")


; ╭─────────╮
; │ Keybind │
; ╰─────────╯

!q:: {
    ; WinClose, A
    RunWait("komorebic.exe close", , "Hide")
}

!+q:: {
    RunWait("komorebic.exe stop", , "Hide")
}

!j:: {
    RunWait("komorebic.exe cycle-focus next", , "Hide")
}

!k:: {
    RunWait("komorebic.exe cycle-focus previous", , "Hide")
}

!+j:: {
    RunWait("komorebic.exe cycle-move next", , "Hide")
}

!+k:: {
    RunWait("komorebic.exe cycle-move previous", , "Hide")
}

!h:: {
    RunWait("komorebic.exe resize-axis horizontal decrease", , "Hide")
}

!l:: {
    RunWait("komorebic.exe resize-axis horizontal increase", , "Hide")
}

!+h:: {
    RunWait("komorebic.exe resize-axis vertical decrease", , "Hide")
}

!+l:: {
    RunWait("komorebic.exe resize-axis vertical increase", , "Hide")
}

focus_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key][1]
    RunWait(Format("komorebic.exe focus-monitor-workspace {} {}", main_monitor, num), , "Hide")
}

send_to_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key][1]
    RunWait(Format("komorebic.exe send-to-monitor-workspace {} {}", main_monitor, num), , "Hide")
}

focus_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait(Format("komorebic.exe focus-monitor {}", value), , "Hide")
}

send_to_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait(Format("komorebic.exe send-to-monitor {}", value), , "Hide")
}

; -------------
; |     |     |
; |     |------
; |     |  |  |
; -------------
!b:: {
    RunWait("komorebic.exe change-layout bsp", , "Hide")
}

; -------------
; |   |   |   |
; |   |   |   |
; -------------
!c:: {
    RunWait("komorebic.exe change-layout columns", , "Hide")
}

; ------------
; |          |
; ------------
; |          |
; ------------
; |          |
; ------------
!r:: {
    RunWait("komorebic.exe change-layout rows", , "Hide")
}

; -----------
; |    |    |
; |    |-----
; |    |    |
; |    |-----
; |    |    |
; -----------
!+c:: {
    RunWait("komorebic.exe change-layout vertical-stack", , "Hide")
}

; ----------------
; |              |
; ----------------
; |    |    |    |
; ----------------
!+r:: {
    RunWait("komorebic.exe change-layout horizontal-stack", , "Hide")
}

; ------------
; |  |    |  |
; |  |    |---
; |  |    |  |
; |  |    |---
; |  |    |  |
; ------------
!+m:: {
    RunWait("komorebic.exe change-layout ultrawide-vertical-stack", , "Hide")
}

!+Capslock::
!+Esc:: {
    RunWait("komorebic.exe toggle-pause", , "Hide")
}

!Capslock::
!Esc:: {
    RunWait("komorebic.exe toggle-tiling", , "Hide")
}

!+f:: {
    RunWait("komorebic.exe toggle-float", , "Hide")
}

!m:: {
    RunWait("komorebic.exe toggle-monocle", , "Hide")
}

!f:: {
    RunWait("komorebic.exe toggle-maximize", , "Hide")
}

!d:: {
    RunWait("komorebic.exe minimize", , "Hide")
}

!x:: {
    RunWait("komorebic.exe flip-layout horizontal", , "Hide")
}

!y:: {
    RunWait("komorebic.exe flip-layout vertical", , "Hide")
}

!+e:: {
    RunWait("komorebic.exe promote", , "Hide")
}

!e:: {
    RunWait("komorebic.exe promote-focus", , "Hide")
}

!n:: {
    RunWait("komorebic.exe retile", , "Hide")
}

!t:: {
    RunWait("komorebic.exe manage", , "Hide")
}

!+t:: {
    RunWait("komorebic.exe unmanage", , "Hide")
}

!+b:: {
    ; Run(Format("pythonw {}/yasb/src/main.py", A_ScriptDir),  , "Hide")
    While (ProcessExist("yasb.exe")) {
        ProcessClose("yasb.exe")
    } Else {
        Run(Format("{}/yasb.exe", A_ScriptDir), , "Hide")
    }
}
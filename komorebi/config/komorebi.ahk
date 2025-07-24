#SingleInstance Force
#NoTrayIcon

Persistent
OnExit((*) => komorebic_stop())

; localappdata := EnvGet("LOCALAPPDATA")

komorebic_stop() {
    RunWait("komorebic.exe stop", , "Hide")

    While (ProcessExist("komorebi-bar.exe")) {
        ProcessClose("komorebi-bar.exe")
    }

    ; DirDelete(localappdata . "/komorebi", true)
}


; ╭───────╮
; │ Start │
; ╰───────╯

; DirCreate(localappdata . "/komorebi")
RunWait("komorebic.exe start --config komorebi.json --await-configuration --bar", , "Hide")


; ╭─────────╮
; │ Monitor │
; ╰─────────╯

global main_monitor := 0

global monitor_key_value := Map(
    "o", 0,
    "i", 1,
    "u", 2
)

global send_to_monitor_prefix := "!+"
For key, value in monitor_key_value {
    Hotkey(send_to_monitor_prefix . key, send_to_monitor)
}

global focus_monitor_prefix := "!"
For key, value in monitor_key_value {
    Hotkey(focus_monitor_prefix . key, focus_monitor)
}


; ╭───────────╮
; │ Workspace │
; ╰───────────╯

global workspace_key_value := Map(
    "1", 0,
    "2", 1,
    "3", 2,
    "4", 3,
    "5", 4,
    "6", 5,
    "7", 6
)

global send_to_monitor_workspace_prefix := "!+"
For key, value in workspace_key_value {
    Hotkey(send_to_monitor_workspace_prefix . key, send_to_monitor_workspace)
}

global focus_monitor_workspace_prefix := "!"
For key, value in workspace_key_value {
    Hotkey(focus_monitor_workspace_prefix . key, focus_monitor_workspace)
}


; ╭────────────────────────╮
; │ Complete Configuration │
; ╰────────────────────────╯

RunWait("komorebic.exe complete-configuration", , "Hide")


; ╭────────────╮
; │ Keybinding │
; ╰────────────╯

!left:: {
    RunWait("komorebic.exe focus left", , "Hide")
}

!right:: {
    RunWait("komorebic.exe focus right", , "Hide")
}

!up:: {
    RunWait("komorebic.exe focus up", , "Hide")
}

!down:: {
    RunWait("komorebic.exe focus down", , "Hide")
}

!+left:: {
    RunWait("komorebic.exe move left", , "Hide")
}

!+right:: {
    RunWait("komorebic.exe move right", , "Hide")
}

!+up:: {
    RunWait("komorebic.exe move up", , "Hide")
}

!+down:: {
    RunWait("komorebic.exe move down", , "Hide")
}

!d:: {
    RunWait("komorebic.exe minimize", , "Hide")
}

!q:: {
    RunWait("komorebic.exe close", , "Hide")
}

!+q:: {
    WinKill("A")
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

send_to_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait(Format("komorebic.exe send-to-monitor {}", value), , "Hide")
}

send_to_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    RunWait(Format("komorebic.exe send-to-monitor-workspace {} {}", main_monitor, num), , "Hide")
}

focus_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_prefix) + 1)
    value := monitor_key_value[key]
    RunWait(Format("komorebic.exe focus-monitor {}", value), , "Hide")
}

focus_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    RunWait(Format("komorebic.exe focus-monitor-workspace {} {}", main_monitor, num), , "Hide")
}

; +-------+-----+
; |       |     |
; |       +--+--+
; |       |  |--|
; +-------+--+--+
!b:: {
    RunWait("komorebic.exe change-layout bsp", , "Hide")
}

; +--+--+--+--+
; |  |  |  |  |
; |  |  |  |  |
; |  |  |  |  |
; +--+--+--+--+
!c:: {
    RunWait("komorebic.exe change-layout columns", , "Hide")
}

; +-----------+
; |-----------|
; |-----------|
; |-----------|
; +-----------+
!r:: {
    RunWait("komorebic.exe change-layout rows", , "Hide")
}

; +-------+-----+
; |       |     |
; |       +-----+
; |       |     |
; +-------+-----+
!+c:: {
    RunWait("komorebic.exe change-layout vertical-stack", , "Hide")
}

; +------+------+
; |             |
; |------+------+
; |      |      |
; +------+------+
!+r:: {
    RunWait("komorebic.exe change-layout horizontal-stack", , "Hide")
}

; +-----+-----------+-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; +-----+-----------+-----+
!+m:: {
    RunWait("komorebic.exe change-layout ultrawide-vertical-stack", , "Hide")
}

; +-----+-----+   +---+---+---+   +---+---+---+   +---+---+---+
; |     |     |   |   |   |   |   |   |   |   |   |   |   |   |
; |     |     |   |   |   |   |   |   |   |   |   |   |   +---+
; +-----+-----+   |   +---+---+   +---+---+---+   +---+---|   |
; |     |     |   |   |   |   |   |   |   |   |   |   |   +---+
; |     |     |   |   |   |   |   |   |   |   |   |   |   |   |
; +-----+-----+   +---+---+---+   +---+---+---+   +---+---+---+
;   4 windows       5 windows       6 windows       7 windows
!g:: {
    RunWait("komorebic.exe change-layout grid", , "Hide")
}

!+g:: {
    RunWait("komorebic.exe change-layout scrolling", , "Hide")
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

!+w:: {
    RunWait("komorebic.exe toggle-workspace-layer", , "Hide")
}

!+Capslock::
!+Esc:: {
    RunWait("komorebic.exe toggle-pause", , "Hide")
}

!Capslock::
!Esc:: {
    RunWait("komorebic.exe toggle-tiling", , "Hide")
}

!w:: {
    RunWait("komorebic.exe toggle-float", , "Hide")
}

!m:: {
    RunWait("komorebic.exe toggle-monocle", , "Hide")
}

!f:: {
    RunWait("komorebic.exe toggle-maximize", , "Hide")
}

!z:: {
    RunWait("komorebic.exe toggle-lock", , "Hide")
}

!t:: {
    RunWait("komorebic.exe manage", , "Hide")
}

!+t:: {
    RunWait("komorebic.exe unmanage", , "Hide")
}

!Enter:: {
    Run("wezterm.exe", , "Hide")
}

#SingleInstance Force
#NoTrayIcon

Persistent
OnExit((*) => komorebic_stop())

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

komorebic_stop() {
    Komorebic("stop")

    While (ProcessExist("komorebi-bar.exe")) {
        ProcessClose("komorebi-bar.exe")
    }
}


; ╭───────╮
; │ Start │
; ╰───────╯

Komorebic("start --config komorebi.json --await-configuration --bar")


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

Komorebic("complete-configuration")


; ╭────────────╮
; │ Keybinding │
; ╰────────────╯

!d:: {
    Komorebic("minimize")
}

!q:: {
    Komorebic("close")
}

!j:: {
    Komorebic("cycle-focus next")
}

!k:: {
    Komorebic("cycle-focus previous")
}

!+j:: {
    Komorebic("cycle-move next")
}

!+k:: {
    Komorebic("cycle-move previous")
}

!left:: {
    Komorebic("stack left")
}

!right:: {
    Komorebic("stack right")
}

!up:: {
    Komorebic("stack up")
}

!down:: {
    Komorebic("stack down")
}

!;:: {
    Komorebic("unstack")
}

!l:: {
    Komorebic("cycle-stack next")
}

!h:: {
    Komorebic("cycle-stack previous")
}

!+l:: {
    Komorebic("cycle-stack-index next")
}

!+h:: {
    Komorebic("cycle-stack-index previous")
}

!=:: {
    Komorebic("resize-axis horizontal increase")
}

!-:: {
    Komorebic("resize-axis horizontal decrease")
}

!+=:: {
    Komorebic("resize-axis vertical increase")
}

!+-:: {
    Komorebic("resize-axis vertical decrease")
}

send_to_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_prefix) + 1)
    value := monitor_key_value[key]
    Komorebic(Format("send-to-monitor {}", value))
}

send_to_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(send_to_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    Komorebic(Format("send-to-monitor-workspace {} {}", main_monitor, num))
}

focus_monitor(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_prefix) + 1)
    value := monitor_key_value[key]
    Komorebic(Format("focus-monitor {}", value))
}

focus_monitor_workspace(ThisHotkey) {
    key := SubStr(ThisHotkey, StrLen(focus_monitor_workspace_prefix) + 1)
    num := workspace_key_value[key]
    Komorebic(Format("focus-monitor-workspace {} {}", main_monitor, num))
}

; +-------+-----+
; |       |     |
; |       +--+--+
; |       |  |--|
; +-------+--+--+
!b:: {
    Komorebic("change-layout bsp")
}

; +--+--+--+--+
; |  |  |  |  |
; |  |  |  |  |
; |  |  |  |  |
; +--+--+--+--+
!c:: {
    Komorebic("change-layout columns")
}

; +-----------+
; |-----------|
; |-----------|
; |-----------|
; +-----------+
!r:: {
    Komorebic("change-layout rows")
}

; +-------+-----+
; |       |     |
; |       +-----+
; |       |     |
; +-------+-----+
!+c:: {
    Komorebic("change-layout vertical-stack")
}

; +------+------+
; |             |
; |------+------+
; |      |      |
; +------+------+
!+r:: {
    Komorebic("change-layout horizontal-stack")
}

; +-----+-----------+-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; |     |           +-----+
; |     |           |     |
; +-----+-----------+-----+
!+m:: {
    Komorebic("change-layout ultrawide-vertical-stack")
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
    Komorebic("change-layout grid")
}

!+g:: {
    Komorebic("change-layout scrolling")
}

!x:: {
    Komorebic("flip-layout horizontal")
}

!y:: {
    Komorebic("flip-layout vertical")
}

!+e:: {
    Komorebic("promote")
}

!e:: {
    Komorebic("promote-focus")
}

!n:: {
    Komorebic("retile")
}

!+w:: {
    Komorebic("toggle-workspace-layer")
}

!+Capslock::
!+Esc:: {
    Komorebic("toggle-pause")
}

!Capslock::
!Esc:: {
    Komorebic("toggle-tiling")
}

!w:: {
    Komorebic("toggle-float")
}

!m:: {
    Komorebic("toggle-monocle")
}

!f:: {
    Komorebic("toggle-maximize")
}

!z:: {
    Komorebic("toggle-lock")
}

!t:: {
    Komorebic("manage")
}

!+t:: {
    Komorebic("unmanage")
}

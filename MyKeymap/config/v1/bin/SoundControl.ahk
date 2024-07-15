#NoEnv
#SingleInstance, force
#NoTrayIcon
ListLines Off
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, logo.ico
SendMode Input

#include %A_ScriptDir%/../data/monitor_center.ahk

layout := new CLayout()

OnMessage(0x100, "WM_KEYDOWN")
layout.show()
SetTimer, IfLoseFocusThenExit, 700
Return

IfLoseFocusThenExit()
{
    global GuiHwnd
    if not WinActive("ahk_id " GuiHwnd)
        ExitApp
}

class CLayout
{
    __New()
    {
        this.X := 180
        this.Y := 10
        this.W := 180
        this.H := 180
        this.margin := 30
        SysGet, c, MonitorCount
        this.count := c
        this.Sound := []
        this.curr := 1
        Gui MyGui:New,  +HwndGuiHwnd
        Gui MyGui:+LabelMyGui_On
        ; Gui, Font,, Consolas
        Gui, Font, s12, 等线
        ; modified
        ; Gui Add, Text, x6 y296 w590 h20 +0x200, EDSF调节音量、AG上一首下一首、空格切换静音、C暂停/播放、V设置、X退出
        Gui Add, Text, x6 y296 w590 h20 +0x200, WSAD调节音量、QE上一首下一首、M切换静音、空格暂停/播放、V设置、X退出

        this.initSound()
    }
    initSound()
    {
        ind := 1
        this.addItem(ind)
        SoundGet, master_volume
        this.setVolumeText(1, Format("{:.0f}", master_volume))
        ind += 1
    }
    show()
    {
        global GuiHwnd
        w :=  this.X + 175
        h :=  320
        GetCurrentMonitorCenter(cx, cy)
        x := cx - w / 2
        y := cy - h / 2
        Gui Show, w%w% h%h% x%x% y%y%, 声音控制
        disableIME(GuiHwnd)
    }

    addItem(i)
    {
        m := new Sound(i, this.X, this.Y, this.W, this.H)
        this.Sound.push(m)
        this.X += this.W + this.margin
    }

    mute(val) {
        this.Sound[this.curr].mute(val)
    }
    deactivate(i) {
        this.Sound[i].deactivate()
    }
    next() {
        if (this.curr >= this.count)
            return
        this.Sound[this.curr].deactivate()
        this.curr += 1
        this.Sound[this.curr].activate()
    }
    prev() {
        if (this.curr <= 1)
            return
        this.Sound[this.curr].deactivate()
        this.curr -= 1
        this.Sound[this.curr].activate()
    }
    setVolumeText(i, brightness) {
        this.Sound[i].setVolumeText(brightness)
    }
    incVolume(num) {
        local master_volume
        SoundGet, master_volume
        layout.setVolumeText(this.curr, Format("{:.0f}", master_volume))
        this.Sound[this.curr].incVolume(num)
    }
    decVolume(num) {
        local master_volume
        SoundGet, master_volume
        layout.setVolumeText(this.curr, Format("{:.0f}", master_volume))
        this.Sound[this.curr].decVolume(num)
    }

}

class Sound
{

    __New(i, X, Y, W, H)
    {
        global muteText1
        global soundText1
        global soundText2
        global soundText3
        global soundText4
        global soundIcon1
        global soundIcon2
        global soundIcon3
        global soundIcon4

        Gui, Font, s128 c0
        Gui Add, Text, x%X% y%Y% w%W% h%H% +0x200 vSoundIcon%i%, 🔊
        X += 62
        Y += 190
        W := 120
        H := 40
        this.i := i

        Gui, Font, s32 c0
        Gui Add, Text, x%X% y%Y% w%W% h%H% +0x200 vSoundText%i%, 100
        GuiControl +BackgroundTrans, soundText%i%
    }

    mute(mute)
    {
        i := this.i
        if (mute == "On") {
            GuiControl, Text, soundIcon%i%, 🔇
        } else if (mute == "Off") {
            GuiControl, Text, soundIcon%i%, 🔊
        }
    }

    activate()
    {
        i := this.i
        Gui, Font, s128 cFF6688
        GuiControl, Font, soundIcon%i%
        Gui, Font, s32 c0
        GuiControl, Font, soundText%i%
    }

    deactivate()
    {
        i := this.i
        Gui, Font, s128 c0
        GuiControl, Font, soundIcon%i%
        Gui, Font, s32 c0
        GuiControl, Font, soundText%i%
    }
    setVolumeText(brightness, mute := "") {
        i := this.i
        this.brightness := brightness
        t := brightness . mute
        GuiControl, Text, soundText%i%, %t%
    }
    incVolume(num) {
        this.brightness := this.limitBrightness(this.brightness + num)
        SoundSet, this.brightness
        this.setVolumeText(this.brightness)
    }
    decVolume(num) {
        this.brightness := this.limitBrightness(this.brightness - num)
        SoundSet, this.brightness
        this.setVolumeText(this.brightness)
    }
    limitBrightness(b) {
        if (b <= 0) {
            return 0
        }
        if (b >= 100) {
            return 100
        }
        return b
    }
}

WM_KEYDOWN(wParam, lParam)
{
    global layout

    ; tooltip, % GetKeyName(Format("vk{:x}", wParam))
    switch (GetKeyName(Format("vk{:x}", wParam)))
    {
        ; modified
        ; case "a": send {Media_Prev}
        ; case "g": send {Media_Next}
        case "q": send {Media_Prev}
        case "e": send {Media_Next}
        case "v":
            run, ms-settings:apps-volume
            ExitApp
        case "Space": send {Media_Play_Pause}
        ; case "s": layout.decVolume(1)
        ; case "f": layout.incVolume(1)
        ; case "d": layout.decVolume(5)
        ; case "e": layout.incVolume(5)
        case "a": layout.decVolume(1)
        case "d": layout.incVolume(1)
        case "s": layout.decVolume(5)
        case "w": layout.incVolume(5)
        ; case "w": layout.prev()
        ; case "r": layout.next()
        case "m":
            SoundSet, +1,, Mute
            SoundGet, val, MASTER, MUTE
            layout.mute(val)
        case "x": ExitApp
        case "Escape": ExitApp
        default:
            ; sleep 500
        return 0
    }
    return 0
}

disableIME(hwnd)
{
    ControlGetFocus, controlName, ahk_id %hwnd%
    ControlGet, controlHwnd, Hwnd,, %controlName%, A
    DllCall("Imm32\ImmAssociateContext", "ptr", controlHwnd, "ptr", 0, "ptr")
}


MyGui_OnClose:
ExitApp
return

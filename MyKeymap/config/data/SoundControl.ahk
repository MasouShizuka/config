#SingleInstance Force
#NoTrayIcon
SetWorkingDir(A_ScriptDir)
TraySetIcon("../bin/icons/logo.ico")

#Include ../bin/lib/Utils.ahk
#Include ./monitor_center.ahk

class CLayout extends Gui {
    __New() {
        super.__New()
        super.Opt("+AlwaysOnTop +Owner +LastFound +Resize -MinimizeBox -MaximizeBox")
        super.Title := "音量调节"

        this.X := 180
        this.Y := 10
        this.W := 180
        this.H := 180
        this.margin := 30
        this.count := SysGet(80)
        this.sound := []
        this.curr := 1

        super.SetFont("s12")
        super.AddText("x6 y296 w590 h20", "WSAD调节音量、QE上一首下一首、M切换静音、空格暂停/播放、V设置、X退出")

        this.initSound()
    }

    initSound() {
        this.addItem()
        master_volume := SoundGetVolume()
        this.setVolumeText(1, Format("{:.0f}", master_volume))
    }

    show() {
        w := this.X + 175
        h := 320
        GetCurrentMonitorCenter(&cx, &cy)
        x := cx - w / 2
        y := cy - h / 2
        super.Show(Format("w{} h{} x{} y{}", w, h, x, y))
        DisableIME(super.Hwnd)
    }

    addItem() {
        m := Sound(this, this.X, this.Y, this.W, this.H)
        this.sound.push(m)
        this.X += this.W + this.margin
    }

    mute(val) {
        this.sound[this.curr].mute(val)
    }

    deactivate(i) {
        this.sound[i].deactivate()
    }

    next() {
        if (this.curr >= this.count)
            return
        this.sound[this.curr].deactivate()
        this.curr += 1
        this.sound[this.curr].activate()
    }

    prev() {
        if (this.curr <= 1)
            return
        this.sound[this.curr].deactivate()
        this.curr -= 1
        this.sound[this.curr].activate()
    }

    setVolumeText(i, brightness) {
        this.sound[i].setVolumeText(brightness)
    }

    incVolume(num) {
        master_volume := SoundGetVolume()
        layout.setVolumeText(this.curr, Format("{:.0f}", master_volume))
        this.sound[this.curr].incVolume(num)
    }

    decVolume(num) {
        master_volume := SoundGetVolume()
        layout.setVolumeText(this.curr, Format("{:.0f}", master_volume))
        this.sound[this.curr].decVolume(num)
    }
}

class Sound {
    __New(gui, X, Y, W, H) {
        this.gui := gui

        this.volume_icon := this.gui.AddText(Format("x{} y{} w{} h{}", X, Y, W, H), "🔊")
        this.volume_icon.SetFont("s128 c0")

        val := SoundGetMute()
        this.mute(val)

        X += 62
        Y += 190
        W := 120
        H := 40

        this.volume_text := this.gui.AddText(Format("x{} y{} w{} h{}", X, Y, W, H), 100)
        this.volume_text.SetFont("s32 c0")
        this.volume_text.Opt("+Background")
    }

    mute(mute) {
        if (mute) {
            this.volume_icon.Text := "🔇"
        } else {
            this.volume_icon.Text := "🔊"
        }
    }

    activate() {
        this.volume_icon.SetFont("s128 cFF6688")
        this.volume_text.SetFont("s32 c0")
    }

    deactivate() {
        this.volume_icon.SetFont("s128 c0")
        this.volume_text.SetFont("s32 c0")
    }

    setVolumeText(brightness, mute := "") {
        this.brightness := brightness
        this.volume_text.Text := brightness . mute
    }

    incVolume(num) {
        this.brightness := this.limitVolume(this.brightness + num)
        SoundSetVolume(this.brightness)
        this.setVolumeText(this.brightness)
    }

    decVolume(num) {
        this.brightness := this.limitVolume(this.brightness - num)
        SoundSetVolume(this.brightness)
        this.setVolumeText(this.brightness)
    }

    limitVolume(v) {
        if (v <= 0) {
            return 0
        }
        if (v >= 100) {
            return 100
        }
        return v
    }
}

layout := CLayout()
layout.show()

SetTimer(IfLoseFocusThenExit, 100)
IfLoseFocusThenExit() {
    if (!WinActive("ahk_id" layout.Hwnd)) {
        ExitApp
    }
}

OnMessage(0x100, WM_KEYDOWN)
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    switch (GetKeyName(Format("vk{:x}", wparam))) {
        case "q": send("{Media_Prev}")
        case "e": send("{Media_Next}")
        case "v":
            Run("ms-settings:apps-volume")
            ExitApp
        case "Space": send("{Media_Play_Pause}")
        case "a": layout.decVolume(1)
        case "d": layout.incVolume(1)
        case "s": layout.decVolume(5)
        case "w": layout.incVolume(5)
        case "m":
            SoundSetMute(-1)
            val := SoundGetMute()
            layout.mute(val)
        case "x": ExitApp
        case "Escape": ExitApp
    }

    return 0
}

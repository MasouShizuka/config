using System;
using System.Globalization;
using System.Runtime.InteropServices;
using workspacer;
using workspacer.Bar;

public class Input_Method_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public int Interval { get; set; } = 1000;

    private System.Timers.Timer _timer;

    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    static extern uint GetWindowThreadProcessId(IntPtr hwnd, IntPtr proccess);
    [DllImport("user32.dll")]
    static extern IntPtr GetKeyboardLayout(uint thread);
    public override IBarWidgetPart[] GetParts() {
        string input_method = "";
        try {
            uint foregroundProcess = GetWindowThreadProcessId(GetForegroundWindow(), IntPtr.Zero);
            int keyboardLayout = GetKeyboardLayout(foregroundProcess).ToInt32() & 0xFFFF;
            input_method = new CultureInfo(keyboardLayout).TwoLetterISOLanguageName;
            if (input_method == "en") {
                input_method = "EN";
            } else if (input_method == "zh") {
                input_method = "中";
            }
        } catch (Exception _) {
        }

        return Parts(Part(LeftPadding + input_method + RightPadding, fore: ForeColor, back: BackColor, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

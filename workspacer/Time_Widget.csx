using System;
using workspacer;
using workspacer.Bar;

public class Time_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;

    private System.Timers.Timer _timer;
    private int _interval;
    private string _format;

    public Time_Widget(int interval, string format) {
        _interval = interval;
        _format = format;
    }

    public Time_Widget() : this(200, "hh:mm:ss tt") {}

    public override IBarWidgetPart[] GetParts() {
        string time_text = DateTime.Now.ToString(_format);

        int hour = DateTime.Now.Hour % 12;
        string time_icon = "";
        if (hour == 0) {
            time_icon = "";
        } else if (hour == 1) {
            time_icon = "";
        } else if (hour == 2) {
            time_icon = "";
        } else if (hour == 3) {
            time_icon = "";
        } else if (hour == 4) {
            time_icon = "";
        } else if (hour == 5) {
            time_icon = "";
        } else if (hour == 6) {
            time_icon = "";
        } else if (hour == 7) {
            time_icon = "";
        } else if (hour == 8) {
            time_icon = "";
        } else if (hour == 9) {
            time_icon = "";
        } else if (hour == 10) {
            time_icon = "";
        } else if (hour == 11) {
            time_icon = "";
        }

        IBarWidgetPart part_icon = Part(time_icon, fore:ForeColor, back: BackColor, fontname: FontName);
        IBarWidgetPart part_time = Part(time_text, fore: BackColor, fontname: FontName);

        IBarWidgetPart[] parts = {
            part_icon,
            part_time,
        };

        return Parts(parts);
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(_interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

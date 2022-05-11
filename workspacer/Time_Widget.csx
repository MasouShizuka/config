using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
        return Parts(Part(LeftPadding + DateTime.Now.ToString(_format) + RightPadding, fore: ForeColor, back: BackColor, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(_interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

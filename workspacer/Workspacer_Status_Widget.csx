using workspacer;
using workspacer.Bar;

public class Workspacer_Status_Widget : BarWidgetBase {
    public Color status_on { get; set; } = Color.Green;
    public Color status_off { get; set; } = Color.Red;
    public int Interval { get; set; } = 1000;

    private IConfigContext config_context;
    private System.Timers.Timer _timer;

    public Workspacer_Status_Widget(IConfigContext context) {
        config_context = context;
    }

    public override IBarWidgetPart[] GetParts() {
        var status = "";
        var color = status_on;
        if (config_context.Enabled) {
            status = "on";
        } else {
            status = "off";
            color = status_off;
        }

        return Parts(Part(LeftPadding + status + RightPadding, fore: color, partClicked: () => {
            config_context.Enabled = !config_context.Enabled;
        }, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

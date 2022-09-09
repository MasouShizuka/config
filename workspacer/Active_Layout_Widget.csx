using workspacer;
using workspacer.Bar;

public class Active_Layout_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public Color DisableColor { get; set; } = null;
    public int Interval { get; set; } = 1000;

    private IConfigContext config_context;
    private System.Timers.Timer _timer;

    public Active_Layout_Widget(IConfigContext context) {
        config_context = context;
    }

    public override IBarWidgetPart[] GetParts() {
        var layout_name = "";
        var fore_color = ForeColor;
        if (!config_context.Enabled) {
            layout_name = "pause";
            fore_color = DisableColor;
        } else {
            var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);
            layout_name = currentWorkspace.LayoutName;
        }

        return Parts(Part(LeftPadding + layout_name + RightPadding, fore: fore_color, back: BackColor, partClicked: () => {
            Context.Workspaces.FocusedWorkspace.NextLayoutEngine();
        }, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

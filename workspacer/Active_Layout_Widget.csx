using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using workspacer;
using workspacer.Bar;

public class Active_Layout_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public int Interval { get; set; } = 1000;

    private System.Timers.Timer _timer;

    public override IBarWidgetPart[] GetParts() {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);

        return Parts(Part(LeftPadding + currentWorkspace.LayoutName + RightPadding, fore: ForeColor, back: BackColor, partClicked: () => {
            Context.Workspaces.FocusedWorkspace.NextLayoutEngine();
        }, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

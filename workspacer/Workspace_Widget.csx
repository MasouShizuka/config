using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using workspacer;
using workspacer.Bar;

public class Workspace_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public Color WorkspaceHasFocusForeColor { get; set; } = Color.Red;
    public Color WorkspaceHasFocusBackColor { get; set; } = null;
    public Color WorkspaceEmptyColor { get; set; } = Color.Gray;

    public override void Initialize() {
        Context.Workspaces.WorkspaceUpdated += () => UpdateWorkspaces();
        Context.Workspaces.WindowMoved += (w, o, n) => UpdateWorkspaces();
    }

    public override IBarWidgetPart[] GetParts() {
        var parts = new List<IBarWidgetPart>();
        var workspaces = Context.WorkspaceContainer.GetWorkspaces(Context.Monitor);
        int index = 0;
        foreach (var workspace in workspaces) {
            parts.Add(CreatePart(workspace, index));
            index++;
        }

        return parts.ToArray();
    }

    private IBarWidgetPart CreatePart(IWorkspace workspace, int index) {
        return Part(GetDisplayName(workspace, index), fore: GetDisplayForeColor(workspace, index), back: GetDisplayBackColor(workspace, index), partClicked: () => {
            Context.Workspaces.SwitchMonitorToWorkspace(Context.Monitor.Index, index);
        }, FontName);
    }

    private void UpdateWorkspaces() {
        MarkDirty();
    }

    protected virtual string GetDisplayName(IWorkspace workspace, int index) {
        var monitor = Context.WorkspaceContainer.GetCurrentMonitorForWorkspace(workspace);
        var visible = Context.Monitor == monitor;

        return visible ? LeftPadding + workspace.Name + RightPadding : workspace.Name;
    }

    protected virtual Color GetDisplayForeColor(IWorkspace workspace, int index) {
        var monitor = Context.WorkspaceContainer.GetCurrentMonitorForWorkspace(workspace);
        if (Context.Monitor == monitor) {
            return WorkspaceHasFocusForeColor;
        }

        var hasWindows = workspace.ManagedWindows.Count != 0;
        return hasWindows ? ForeColor : WorkspaceEmptyColor;
    }

    protected virtual Color GetDisplayBackColor(IWorkspace workspace, int index) {
        var monitor = Context.WorkspaceContainer.GetCurrentMonitorForWorkspace(workspace);
        if (Context.Monitor == monitor) {
            return WorkspaceHasFocusBackColor;
        } else {
            return BackColor;
        }
    }
}

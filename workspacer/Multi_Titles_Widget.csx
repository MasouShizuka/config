using System;
using System.Collections.Generic;
using System.Linq;
using workspacer;
using workspacer.Bar;

public class Multi_Titles_Widget : BarWidgetBase {
    #region Properties
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public Color WindowHasFocusForeColor { get; set; } = Color.Yellow;
    public Color WindowHasFocusBackColor { get; set; } = null;
    public bool IsShortTitle { get; set; } = false;
    public int? MaxTitleLength { get; set; } = null;
    public bool ShowAllWindowTitles { get; set; } = false;
    public string TitlePreamble { get; set; } = null;
    public string TitlePostamble { get; set; } = null;
    public string NoWindowMessage { get; set; } = "No Windows";
    public Func<IWindow, Action> TitlePartClicked = ClickAction;
    public Func<IWindow, object> OrderWindowsBy = (window) => 0;

    private System.Timers.Timer _timer;
    public int Interval { get; set; } = 1000;
    #endregion

    public override void Initialize() {
        Context.Workspaces.WindowAdded += RefreshAdd;
        Context.Workspaces.WindowRemoved += RefreshRemove;
        Context.Workspaces.WindowUpdated += RefreshUpdated;
        Context.Workspaces.FocusedMonitorUpdated += RefreshFocusedMonitor;

        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }

    #region Get Windows
    private IEnumerable<IWindow> GetWindows(bool filterOnTitleFilled = true) {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);

        return currentWorkspace.Windows.Where(w => w.CanLayout).Where(window => !filterOnTitleFilled || !string.IsNullOrEmpty(window.Title));
    }

    private IWindow GetWindow() {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);

        return currentWorkspace.FocusedWindow ?? currentWorkspace.LastFocusedWindow ?? currentWorkspace.ManagedWindows.FirstOrDefault();
    }

    #endregion

    #region Events
    private void RefreshRemove(IWindow window, IWorkspace workspace) {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);
        if (workspace == currentWorkspace && !string.IsNullOrEmpty(window.Title) && !GetWindows().Contains(window)) {
            MarkDirty();
        }
    }

    private void RefreshAdd(IWindow window, IWorkspace workspace) {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);
        if (workspace == currentWorkspace && !string.IsNullOrEmpty(window.Title) && GetWindows().Contains(window)) {
            MarkDirty();
        }
    }

    private void RefreshUpdated(IWindow window, IWorkspace workspace) {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);
        if (workspace == currentWorkspace && !string.IsNullOrEmpty(window.Title) && GetWindows().Contains(window)) {
            MarkDirty();
        }
    }

    private void RefreshFocusedMonitor() {
        MarkDirty();
    }

    private static Action ClickAction(IWindow window) {
        return new Action(() => {
            if (window == null) {
                return;
            }

            window.ShowInCurrentState();
            window.BringToTop();
            window.Focus();
        });
    }
    #endregion

    #region Title Generation
    public override IBarWidgetPart[] GetParts() {
        var windows = ShowAllWindowTitles ? GetWindows() : new[] { GetWindow() };
        if (windows == null || !windows.Any()) {
            return Parts(Part(NoWindowMessage, null, fontname: FontName));
        }

        return windows.OrderByDescending(OrderWindowsBy).SelectMany(w => CreateTitlePart(w, WindowHasFocusForeColor, FontName, IsShortTitle, MaxTitleLength, TitlePartClicked)).ToArray();
    }

    private IBarWidgetPart[] CreateTitlePart(IWindow window, Color WindowHasFocusForeColor, string fontName, bool isShortTitle = false, int? maxTitleLength = null, Func<IWindow, Action> clickAction = null) {
        var windowTitle = window.Title;
        if (isShortTitle) {
            windowTitle = GetShortTitle(windowTitle);
        }

        if (maxTitleLength.HasValue) {
            windowTitle = GetTrimmedTitle(windowTitle, maxTitleLength);
        }

        IBarWidgetPart title_preamble = Part(TitlePreamble, fore: ForeColor, fontname: fontName, partClicked: clickAction != null ? clickAction(window) : null);
        IBarWidgetPart window_title = Part(windowTitle, fore: window.IsFocused ? WindowHasFocusForeColor : ForeColor, back: window.IsFocused ? WindowHasFocusBackColor : BackColor, fontname: fontName, partClicked: clickAction != null ? clickAction(window) : null);
        IBarWidgetPart title_postamble = Part(TitlePostamble, fore: ForeColor, fontname: fontName, partClicked: clickAction != null ? clickAction(window) : null);

        IBarWidgetPart[] parts = {
            title_preamble,
            window_title,
            title_postamble,
        };

        return parts;
    }
    #endregion

    #region Title Formating
    public static string GetShortTitle(string title) {
        var parts = title.Split(new char[] { '-', '—', '|' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) {
            return title.Trim();
        }

        return parts.Last().Trim();
    }

    public static int get_non_ascii_length(string s) {
        int count = 0;
        for (int i = 0; i < s.Length; i++) {
            if (s[i] > 127) {
                count++;
            }
        }

        return count;
    }

    public static string GetTrimmedTitle(string title, int? maxTitleLength = null) {
        if (!maxTitleLength.HasValue || title.Length <= maxTitleLength.Value) {
            return title;
        }

        int title1_length = maxTitleLength.Value / 2;
        int title2_length = maxTitleLength.Value - title1_length;
        string title1 = title.Substring(0, title1_length);
        string title2 = title.Remove(0, title.Length - title2_length);

        int title1_non_ascii_length = get_non_ascii_length(title1);
        int title2_non_ascii_length = get_non_ascii_length(title2);
        title1 = title1.Substring(0, title1_length - title1_non_ascii_length / 2);
        title2 = title2.Remove(0, title2_non_ascii_length / 2);

        return title1 + "..." + title2;
    }
    #endregion
}

#r "D:\Tools\Workspacer\workspacer.Shared.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Timers;
using System.Runtime.InteropServices;
using System.Globalization;
using workspacer;
using workspacer.Bar;
using workspacer.Bar.Widgets;
using workspacer.Gap;
using workspacer.ActionMenu;
using workspacer.FocusIndicator;

[DllImport("user32.dll", EntryPoint = "keybd_event")]
public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

static void refresh_workspace() {
    // 发送 Alt+Enter+Enter
    Thread.Sleep(200);
    keybd_event(18, 0, 0, 0);
    keybd_event(13, 0, 0, 0);
    keybd_event(13, 0, 2, 0);
    keybd_event(13, 0, 0, 0);
    keybd_event(13, 0, 2, 0);
    keybd_event(18, 0, 2, 0);
}

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
        return Parts(Part(LeftPadding + status + RightPadding, fore: color, fontname: FontName, partClicked: () => {
            config_context.Enabled = !config_context.Enabled;
        }));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

public class Input_Method_Widget : BarWidgetBase {
    public int Interval { get; set; } = 1000;

    private System.Timers.Timer _timer;

    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hwnd, IntPtr proccess);
    [DllImport("user32.dll")] static extern IntPtr GetKeyboardLayout(uint thread);
    public override IBarWidgetPart[] GetParts() {
        string input_method = "";
        try {
            IntPtr foregroundWindow = GetForegroundWindow();
            uint foregroundProcess = GetWindowThreadProcessId(foregroundWindow, IntPtr.Zero);
            int keyboardLayout = GetKeyboardLayout(foregroundProcess).ToInt32() & 0xFFFF;
            input_method = new CultureInfo(keyboardLayout).TwoLetterISOLanguageName;
            if (input_method == "en") {
                input_method = "ENG";
            } else if (input_method == "zh") {
                input_method = "拼";
            }
        } catch (Exception _) {
        }
        return Parts(Part(LeftPadding + input_method + RightPadding, fontname: FontName));
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}

public class Workspace_Widget_With_Refresh : BarWidgetBase {
    public Color WorkspaceHasFocusColor { get; set; } = Color.Red;
    public Color WorkspaceEmptyColor { get; set; } = Color.Gray;
    public Color WorkspaceIndicatingBackColor { get; set; } = Color.Teal;
    public int BlinkPeriod { get; set; } = 1000;

    private System.Timers.Timer _blinkTimer;
    private ConcurrentDictionary<IWorkspace, bool> _blinkingWorkspaces;

    public override void Initialize() {
        Context.Workspaces.WorkspaceUpdated += () => UpdateWorkspaces();
        Context.Workspaces.WindowMoved += (w, o, n) => UpdateWorkspaces();

        _blinkingWorkspaces = new ConcurrentDictionary<IWorkspace, bool>();

        _blinkTimer = new System.Timers.Timer(BlinkPeriod);
        _blinkTimer.Elapsed += (s, e) => BlinkIndicatingWorkspaces();
        _blinkTimer.Enabled = true;
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

    private bool WorkspaceIsIndicating(IWorkspace workspace) {
        if (workspace.IsIndicating) {
            if (_blinkingWorkspaces.ContainsKey(workspace)) {
                _blinkingWorkspaces.TryGetValue(workspace, out bool value);
                return value;
            } else {
                _blinkingWorkspaces.TryAdd(workspace, true);
                return true;
            }
        } else if (_blinkingWorkspaces.ContainsKey(workspace)) {
            _blinkingWorkspaces.TryRemove(workspace, out bool _);
        }
        return false;
    }

    private IBarWidgetPart CreatePart(IWorkspace workspace, int index) {
        var backColor = WorkspaceIsIndicating(workspace) ? WorkspaceIndicatingBackColor : null;

        return Part(GetDisplayName(workspace, index), GetDisplayColor(workspace, index), backColor, () => {
            Context.Workspaces.SwitchMonitorToWorkspace(Context.Monitor.Index, index);
            refresh_workspace();
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

    protected virtual Color GetDisplayColor(IWorkspace workspace, int index) {
        var monitor = Context.WorkspaceContainer.GetCurrentMonitorForWorkspace(workspace);
        if (Context.Monitor == monitor) {
            return WorkspaceHasFocusColor;
        }

        var hasWindows = workspace.ManagedWindows.Count != 0;
        return hasWindows ? null : WorkspaceEmptyColor;
    }

    private void BlinkIndicatingWorkspaces() {
        var workspaces = _blinkingWorkspaces.Keys;

        var didFlip = false;
        foreach (var workspace in workspaces) {
            if (_blinkingWorkspaces.TryGetValue(workspace, out bool value)) {
                _blinkingWorkspaces.TryUpdate(workspace, !value, value);
                didFlip = true;
            }
        }

        if (didFlip) {
            MarkDirty();
        }
    }
}

public class Multi_Titles_Widget : BarWidgetBase {
    #region Properties
    public Color WindowHasFocusColor { get; set; } = Color.Yellow;
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
        // return currentWorkspace.Where(window => !filterOnTitleFilled || !string.IsNullOrEmpty(window.Title));
        return currentWorkspace.Windows.Where(w => w.CanLayout).Where(window => !filterOnTitleFilled || !string.IsNullOrEmpty(window.Title));
    }

    private IWindow GetWindow() {
        var currentWorkspace = Context.WorkspaceContainer.GetWorkspaceForMonitor(Context.Monitor);
        return currentWorkspace.FocusedWindow ??
               currentWorkspace.LastFocusedWindow ??
               currentWorkspace.ManagedWindows.FirstOrDefault();
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

        return windows.OrderByDescending(OrderWindowsBy).Select(w => CreateTitlePart(w, WindowHasFocusColor, FontName, IsShortTitle, MaxTitleLength, TitlePartClicked)).ToArray();
    }

    private IBarWidgetPart CreateTitlePart(IWindow window, Color windowHasFocusColor, string fontName, bool isShortTitle = false, int? maxTitleLength = null, Func<IWindow, Action> clickAction = null) {
        var windowTitle = window.Title;
        if (isShortTitle) {
            windowTitle = GetShortTitle(windowTitle);
        }

        if (maxTitleLength.HasValue) {
            windowTitle = GetTrimmedTitle(windowTitle, maxTitleLength);
        }

        windowTitle = string.Format("{0}{1}{2}", string.IsNullOrEmpty(TitlePreamble) ? '[' : TitlePreamble, windowTitle, string.IsNullOrEmpty(TitlePostamble) ? ']' : TitlePostamble);

        return Part(windowTitle, window.IsFocused ? windowHasFocusColor : null, fontname: fontName, partClicked: clickAction != null ? clickAction(window) : null);
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

    public static string GetTrimmedTitle(string title, int? maxTitleLength = null) {
        if (!maxTitleLength.HasValue || title.Length <= maxTitleLength.Value) {
            return title;
        }

        // return title.Remove(maxTitleLength.Value, title.Length - maxTitleLength.Value) + "...";
        int halfMaxTitleLength = maxTitleLength.Value / 2;
        int cutLength = title.Length - halfMaxTitleLength;
        string title1 = title.Remove(halfMaxTitleLength, cutLength);
        string title2 = title.Remove(0, title.Length - (maxTitleLength.Value - halfMaxTitleLength));
        return title1 + "..." + title2;
    }
    #endregion
}

Action<IConfigContext> doConfig = (context) => {
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None;

    var background = new Color(0x0, 0x0, 0x0);
    var bar_height = 24;
    var font_size = 10;
    var font_name = "Iosevka NF";
    var gap = 8;

    context.AddBar(new BarPluginConfig() {
        BarHeight = bar_height,
        DefaultWidgetBackground = background,
        FontName = font_name,
        FontSize = font_size,

        LeftWidgets = () => new IBarWidget[] {
            new Workspace_Widget_With_Refresh() {
                WorkspaceIndicatingBackColor = background,
            },
            new ActiveLayoutWidget() {
                LeftPadding = "[",
                RightPadding = "]",
            },
            new Multi_Titles_Widget() {
                MaxTitleLength = 38,
                ShowAllWindowTitles = true,
                TitlePreamble = " ",
                TitlePostamble = " ",
            }
        },

        RightWidgets = () => new IBarWidget[] {
            new Workspacer_Status_Widget(context) {
                LeftPadding = "[",
                RightPadding = "]",
            },
            new TextWidget("⌨"),
            new Input_Method_Widget(),
            new TextWidget(""),
            new BatteryWidget(),
            new TextWidget(""),
            new TimeWidget(1000, "yyyy-MM-dd HH:mm:ss ddd"),
        },
    });

    context.AddFocusIndicator();

    context.AddGap(new GapPluginConfig() {
        InnerGap = gap,
        OuterGap = gap / 2,
        Delta = gap / 2,
    });

    context.CanMinimizeWindows = true;

    Func<ILayoutEngine[]> defaultLayouts = () => new ILayoutEngine[] {
        new TallLayoutEngine(),
        new VertLayoutEngine(),
        new HorzLayoutEngine(),
        new GridLayoutEngine(),
        new FocusLayoutEngine(),
        new FullLayoutEngine(),
    };
    context.DefaultLayouts = defaultLayouts;

    string[] icons = {
        "  ",
        "  ",
        "  ",
        "  ",
        "  ",
        "  ",
        "  ",
    };
    (string, ILayoutEngine[])[] workspaces = {
        (icons[0], defaultLayouts()),
        (icons[1], defaultLayouts()),
        (icons[2], defaultLayouts()),
        (icons[3], defaultLayouts()),
        (icons[4], defaultLayouts()),
        (icons[5], defaultLayouts()),
        (icons[6], defaultLayouts()),
    };
    foreach ((string name, ILayoutEngine[] layouts) in workspaces) {
        context.WorkspaceContainer.CreateWorkspace(name, layouts);
    }

    context.WindowRouter.IgnoreProcessName("copyq");
    context.WindowRouter.IgnoreProcessName("Snipaste");

    context.WindowRouter.RouteProcessName("msedge", icons[1]);
    context.WindowRouter.RouteProcessName("QQ", icons[2]);
    context.WindowRouter.RouteProcessName("WeChat", icons[2]);
    context.WindowRouter.RouteProcessName("mpv", icons[3]);
    context.WindowRouter.RouteProcessName("cloudmusic", icons[4]);
    context.WindowRouter.RouteProcessName("foobar2000", icons[4]);
    context.WindowRouter.RouteProcessName("Thunder", icons[5]);

    var actionMenu = context.AddActionMenu(new ActionMenuPluginConfig() {
        Background = background,
        MenuHeight = bar_height,
        FontName = font_name,
        FontSize = font_size,
        RegisterKeybind = false,
    });
    Func<ActionMenuItemBuilder> createActionMenuBuilder = () => {
        var menuBuilder = actionMenu.Create();

        menuBuilder.AddMenu("switch to workspace", () => {
            var workspaceMenu = actionMenu.Create();
            var monitor = context.MonitorContainer.FocusedMonitor;
            var workspaces = context.WorkspaceContainer.GetWorkspaces(monitor).ToArray();

            Func<int, Action> createChildMenu = (workspaceIndex) => () => {
                context.Workspaces.SwitchMonitorToWorkspace(monitor.Index, workspaceIndex);
            };

            for (int i = 0; i < workspaces.Length; i++) {
                workspaceMenu.Add(workspaces[i].Name, createChildMenu(i));
            }

            return workspaceMenu;
        });

        menuBuilder.AddMenu("move focused window to workspace", () => {
            var workspaceMenu = actionMenu.Create();
            var focusedWorkspace = context.Workspaces.FocusedWorkspace;
            var workspaces = context.WorkspaceContainer.GetWorkspaces(focusedWorkspace).ToArray();

            Func<int, Action> createChildMenu = (workspaceIndex) => () => {
                context.Workspaces.MoveFocusedWindowToWorkspace(workspaceIndex);
            };

            for (int i = 0; i < workspaces.Length; i++) {
                workspaceMenu.Add(workspaces[i].Name, createChildMenu(i));
            }

            return workspaceMenu;
        });

        menuBuilder.AddFreeForm("create new workspace", (name) => {
            context.WorkspaceContainer.CreateWorkspace(name);
        });
        menuBuilder.AddFreeForm("rename focused workspace", (name) => {
            context.Workspaces.FocusedWorkspace.Name = name; });
        menuBuilder.Add("delete focused workspace", () => {
            context.WorkspaceContainer.RemoveWorkspace(context.Workspaces.FocusedWorkspace);
        });

        menuBuilder.Add("show keybind helper", () => context.Keybinds.ShowKeybindDialog());
        menuBuilder.Add("toggle enabled", () => context.Enabled = !context.Enabled);
        menuBuilder.Add("restart", () => context.Restart());
        menuBuilder.Add("quit", () => context.Quit());

        return menuBuilder;
    };
    var actionMenuBuilder = createActionMenuBuilder();

    Action setKeybindings = () => {
        KeyModifiers mod = KeyModifiers.Alt;
        KeyModifiers mod_shift = mod | KeyModifiers.Shift;
        KeyModifiers mod_ctrl = mod | KeyModifiers.Control;
        Action<int> switch_to_workspace_with_refresh = (index) => {
            context.Workspaces.SwitchToWorkspace(index);
            refresh_workspace();
        };

        context.Keybinds.UnsubscribeAll();

        context.Keybinds.Subscribe(MouseEvent.LButtonDown, () => context.Workspaces.SwitchFocusedMonitorToMouseLocation());

        context.Keybinds.Subscribe(mod, Keys.Escape, () => context.Enabled = !context.Enabled, "toggle enable/disable");

        context.Keybinds.Subscribe(mod, Keys.Q, () => context.Workspaces.FocusedWorkspace.CloseFocusedWindow(), "close focused window");

        context.Keybinds.Subscribe(mod, Keys.W, () => context.Workspaces.FocusedWorkspace.NextLayoutEngine(), "next layout");
        context.Keybinds.Subscribe(mod_shift, Keys.W, () => context.Workspaces.FocusedWorkspace.PreviousLayoutEngine(), "previous layout");
        context.Keybinds.Subscribe(mod, Keys.N, () => context.Workspaces.FocusedWorkspace.ResetLayout(), "reset layout");

        context.Keybinds.Subscribe(mod, Keys.J, () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            var _lastFocused = context.Workspaces.FocusedWorkspace.LastFocusedWindow;
            var didFocus = false;
            for (var i = 0; i < windows.Count; i++) {
                var window = windows[i];
                var index = 0;
                if (window.IsFocused) {
                    if (i + 1 != windows.Count) {
                        index = i + 1;
                    }
                    windows[index].Focus();
                    didFocus = true;
                    if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                        windows[index].ShowNormal();
                        refresh_workspace();
                    }
                    break;
                }
            }
            if (!didFocus && windows.Count > 0) {
                if (_lastFocused != null) {
                    _lastFocused.Focus();
                } else {
                    windows[0].Focus();
                }
            }
        }, "focus next window");
        context.Keybinds.Subscribe(mod, Keys.K, () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            var _lastFocused = context.Workspaces.FocusedWorkspace.LastFocusedWindow;
            var didFocus = false;
            for (var i = 0; i < windows.Count; i++) {
                var window = windows[i];
                var index = windows.Count - 1;
                if (window.IsFocused) {
                    if (i != 0) {
                        index = i - 1;
                    }
                    windows[index].Focus();
                    didFocus = true;
                    if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                        windows[index].ShowNormal();
                        refresh_workspace();
                    }
                    break;
                }
            }
            if (!didFocus && windows.Count > 0) {
                if (_lastFocused != null) {
                    _lastFocused.Focus();
                } else {
                    windows[0].Focus();
                }
            }
        }, "focus previous window");

        context.Keybinds.Subscribe(mod, Keys.E, () => context.Workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow(), "swap focus and primary window");

        context.Keybinds.Subscribe(mod_shift, Keys.J, () => context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow(), "swap focus and next window");
        context.Keybinds.Subscribe(mod_shift, Keys.K, () => context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow(), "swap focus and previous window");

        context.Keybinds.Subscribe(mod, Keys.H, () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea(), "shrink primary area");
        context.Keybinds.Subscribe(mod, Keys.L, () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea(), "expand primary area");

        context.Keybinds.Subscribe(mod, Keys.A, () => context.Workspaces.FocusedWorkspace.IncrementNumberOfPrimaryWindows(), "increment # primary windows");
        context.Keybinds.Subscribe(mod, Keys.X, () => context.Workspaces.FocusedWorkspace.DecrementNumberOfPrimaryWindows(), "decrement # primary windows");

        context.Keybinds.Subscribe(mod, Keys.T, () => context.Windows.ToggleFocusedWindowTiling(), "toggle tiling for focused window");

        context.Keybinds.Subscribe(mod_shift, Keys.Q, context.Quit, "quit workspacer");
        context.Keybinds.Subscribe(mod, Keys.R, context.Restart, "restart workspacer");

        context.Keybinds.Subscribe(mod, Keys.D1, () => switch_to_workspace_with_refresh(0), "switch to workspace 1");
        context.Keybinds.Subscribe(mod, Keys.D2, () => switch_to_workspace_with_refresh(1), "switch to workspace 2");
        context.Keybinds.Subscribe(mod, Keys.D3, () => switch_to_workspace_with_refresh(2), "switch to workspace 3");
        context.Keybinds.Subscribe(mod, Keys.D4, () => switch_to_workspace_with_refresh(3), "switch to workspace 4");
        context.Keybinds.Subscribe(mod, Keys.D5, () => switch_to_workspace_with_refresh(4), "switch to workspace 5");
        context.Keybinds.Subscribe(mod, Keys.D6, () => switch_to_workspace_with_refresh(5), "switch to workspace 6");
        context.Keybinds.Subscribe(mod, Keys.D7, () => switch_to_workspace_with_refresh(6), "switch to workspace 7");
        context.Keybinds.Subscribe(mod, Keys.D8, () => switch_to_workspace_with_refresh(7), "switch to workspace 8");
        context.Keybinds.Subscribe(mod, Keys.D9, () => switch_to_workspace_with_refresh(8), "switch to workspace 9");
        context.Keybinds.Subscribe(mod, Keys.S, () => switch_to_workspace_with_refresh(workspaces.Length - 1), "switch to workspace Others");

        // Subscribe(mod, Keys.Left, () => _context.Workspaces.SwitchToPreviousWorkspace(), "switch to previous workspace");
        // Subscribe(mod, Keys.Right, () => _context.Workspaces.SwitchToNextWorkspace(), "switch to next workspace");
        // Subscribe(mod | KeyModifiers.Control, Keys.Left, () => _context.Workspaces.MoveFocusedWindowAndSwitchToPreviousWorkspace(), "move window to previous workspace and switch to it");
        // Subscribe(mod | KeyModifiers.Control, Keys.Right, () => _context.Workspaces.MoveFocusedWindowAndSwitchToNextWorkspace(), "move window to next workspace and switch to it");
        context.Keybinds.Subscribe(mod, Keys.Oemtilde, () => context.Workspaces.SwitchToLastFocusedWorkspace(), "switch to last focused workspace");

        context.Keybinds.Subscribe(mod, Keys.U, () => context.Workspaces.SwitchFocusedMonitor(0), "focus monitor 1");
        context.Keybinds.Subscribe(mod, Keys.I, () => context.Workspaces.SwitchFocusedMonitor(1), "focus monitor 2");
        context.Keybinds.Subscribe(mod, Keys.O, () => context.Workspaces.SwitchFocusedMonitor(2), "focus monitor 3");
        context.Keybinds.Subscribe(mod_shift, Keys.U, () => context.Workspaces.MoveFocusedWindowToMonitor(0), "move focused window to monitor 1");
        context.Keybinds.Subscribe(mod_shift, Keys.I, () => context.Workspaces.MoveFocusedWindowToMonitor(1), "move focused window to monitor 2");
        context.Keybinds.Subscribe(mod_shift, Keys.O, () => context.Workspaces.MoveFocusedWindowToMonitor(2), "move focused window to monitor 3");

        context.Keybinds.Subscribe(mod_shift, Keys.D1, () => context.Workspaces.MoveFocusedWindowToWorkspace(0), "switch focused window to workspace 1");
        context.Keybinds.Subscribe(mod_shift, Keys.D2, () => context.Workspaces.MoveFocusedWindowToWorkspace(1), "switch focused window to workspace 2");
        context.Keybinds.Subscribe(mod_shift, Keys.D3, () => context.Workspaces.MoveFocusedWindowToWorkspace(2), "switch focused window to workspace 3");
        context.Keybinds.Subscribe(mod_shift, Keys.D4, () => context.Workspaces.MoveFocusedWindowToWorkspace(3), "switch focused window to workspace 4");
        context.Keybinds.Subscribe(mod_shift, Keys.D5, () => context.Workspaces.MoveFocusedWindowToWorkspace(4), "switch focused window to workspace 5");
        context.Keybinds.Subscribe(mod_shift, Keys.D6, () => context.Workspaces.MoveFocusedWindowToWorkspace(5), "switch focused window to workspace 6");
        context.Keybinds.Subscribe(mod_shift, Keys.D7, () => context.Workspaces.MoveFocusedWindowToWorkspace(6), "switch focused window to workspace 7");
        context.Keybinds.Subscribe(mod_shift, Keys.D8, () => context.Workspaces.MoveFocusedWindowToWorkspace(7), "switch focused window to workspace 8");
        context.Keybinds.Subscribe(mod_shift, Keys.D9, () => context.Workspaces.MoveFocusedWindowToWorkspace(8), "switch focused window to workspace 9");
        context.Keybinds.Subscribe(mod_shift, Keys.S, () => context.Workspaces.MoveFocusedWindowToWorkspace(workspaces.Length - 1), "switch focused window to workspace Others");

        // Subscribe(mod, Keys.O, () => _context.Windows.DumpWindowDebugOutput(), "dump debug info to console for all windows");
        // Subscribe(mod | KeyModifiers.LShift, Keys.O, () => _context.Windows.DumpWindowUnderCursorDebugOutput(), "dump debug info to console for window under cursor");
        // Subscribe(mod | KeyModifiers.LShift, Keys.I, () => _context.ToggleConsoleWindow(), "toggle debug console");
        // Subscribe(mod | KeyModifiers.LShift, Keys.Oem2, () => ShowKeybindDialog(), "toggle keybind window");

        context.Keybinds.Subscribe(mod, Keys.F, () => {
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                if (window.IsMaximized) {
                    context.Enabled = true;
                    window.ShowNormal();
                } else {
                    context.Enabled = false;
                    window.ShowMaximized();
                }
            }
        }, "maximize focused window");
        context.Keybinds.Subscribe(mod, Keys.D, () => {
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                if (window.IsMinimized) {
                    refresh_workspace();
                    window.ShowNormal();
                } else {
                    window.ShowMinimized();
                }
            }
        }, "minimize focused window");

        context.Keybinds.Subscribe(mod, Keys.P, () => actionMenu.ShowMenu(actionMenuBuilder), "open action menu");
    };
    setKeybindings();
};

return doConfig;

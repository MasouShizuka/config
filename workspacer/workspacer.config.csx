#r "D:\Tools\Workspacer\workspacer.Shared.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Timers;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using workspacer;
using workspacer.Bar;
using workspacer.Bar.Widgets;
using workspacer.Gap;
using workspacer.ActionMenu;
using workspacer.FocusIndicator;

// 某些程序（例如 Vscode）会在调用某些 api 后卡住，例如切换 workspace 时
// 需要进行一定的操作才能恢复
// 程序的进程名称列表
static string[] process_name_list = {
    "Code",
    "TE64",
    "vivaldi",
    "WindowsTerminal",
};
// 初始化一个看不见的 Form，并将其置顶
static Form form = new Form();
form.Width = 0;
form.Height = 0;
form.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
form.TopLevel = true;
form.TopMost = true;
static async void refresh() {
    await Task.Delay(300);
    // 激活 Form 并隐藏，以恢复程序的状态
    form.Show();
    form.Activate();
    form.Hide();
}
static void refresh_window(IWindow focused_window) {
    if (focused_window != null) {
        string focused_window_process_name = focused_window.ProcessName;
        foreach (string process_name in process_name_list) {
            if (focused_window_process_name == process_name) {
                refresh();
                break;
            }
        }
    }
}

// 移动鼠标到当前窗口的中心
[StructLayout(LayoutKind.Sequential)]
struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
[DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
[DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
[DllImport("User32.dll")] static extern bool SetCursorPos(int X, int Y);
static async void move_cursor_to_current_window_center() {
    try {
        await Task.Delay(100);
        RECT r = new RECT();
        IntPtr foregroundWindow = GetForegroundWindow();
        GetWindowRect(foregroundWindow, out r);
        int width = r.Right - r.Left;
        int height = r.Bottom - r.Top;
        int x = r.Left + width / 2;
        int y = r.Top + height / 2;
        SetCursorPos(x, y);
    } catch (Exception _) {
    }
}

// workspacer 启用状态的 widget
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

// 输入法状态的 widget
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

// 多标题的 widget
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

        windowTitle = string.Format("{0}{1}{2}", TitlePreamble, windowTitle, TitlePostamble);

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
        int title1_length = maxTitleLength.Value / 2;
        int title2_length = maxTitleLength.Value - title1_length;
        string title1 = title.Substring(0, title1_length);
        string title2 = title.Remove(0, title.Length - title2_length);
        return title1 + "..." + title2;
    }
    #endregion
}

Action<IConfigContext> doConfig = (context) => {
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None;

    var background = new Color(0x0, 0x0, 0x0);
    var bar_height = 26;
    var font_size = 13;
    var font_name = "Sarasa Mono SC Nerd Font";
    var gap = 8;

    // 顶栏
    context.AddBar(new BarPluginConfig() {
        BarHeight = bar_height,
        DefaultWidgetBackground = background,
        FontName = font_name,
        FontSize = font_size,

        LeftWidgets = () => new IBarWidget[] {
            new WorkspaceWidget() {
                WorkspaceIndicatingBackColor = background,
            },
            new ActiveLayoutWidget() {
                LeftPadding = "[",
                RightPadding = "]",
            },
            new TextWidget("┃"),
            new Multi_Titles_Widget() {
                MaxTitleLength = 38,
                ShowAllWindowTitles = true,
                TitlePreamble = "",
                TitlePostamble = " ┃",
            }
        },

        RightWidgets = () => new IBarWidget[] {
            new Workspacer_Status_Widget(context) {
                LeftPadding = "[",
                RightPadding = "]",
            },
            new TextWidget(" "),
            new Input_Method_Widget() {
                Interval = 500,
            },
            new TextWidget(""),
            new BatteryWidget(),
            new TextWidget(" "),
            new TimeWidget(1000, "yyyy-MM-dd HH:mm:ss ddd"),
        },
    });

    // 聚焦窗口时的外框
    context.AddFocusIndicator();

    // 窗口间的间距
    context.AddGap(new GapPluginConfig() {
        InnerGap = gap,
        OuterGap = gap / 2,
        Delta = gap / 2,
    });

    // 能最小化窗口
    context.CanMinimizeWindows = true;

    // 布局类型
    Func<ILayoutEngine[]> defaultLayouts = () => new ILayoutEngine[] {
        new TallLayoutEngine(),
        new VertLayoutEngine(),
        new HorzLayoutEngine(),
        new GridLayoutEngine(),
        new DwindleLayoutEngine(),
        new FocusLayoutEngine(),
        new FullLayoutEngine(),
    };
    context.DefaultLayouts = defaultLayouts;

    // workspace
    string[] icons = {
        "  ",
        "  ",
        "  ",
        "  ",
        "  ",
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

    // 忽略的程序
    context.WindowRouter.IgnoreProcessName("ApplicationFrameHost");
    context.WindowRouter.IgnoreProcessName("copyq");
    context.WindowRouter.IgnoreProcessName("Flow.Launcher");
    context.WindowRouter.IgnoreProcessName("Snipaste");

    // 导航至指定 workspace 的程序
    context.WindowRouter.RouteProcessName("vivaldi", icons[1]);
    context.WindowRouter.RouteProcessName("QQ", icons[2]);
    context.WindowRouter.RouteProcessName("WeChat", icons[2]);
    context.WindowRouter.RouteProcessName("cloudmusic", icons[3]);
    context.WindowRouter.RouteProcessName("foobar2000", icons[3]);
    context.WindowRouter.RouteProcessName("mpv", icons[4]);
    context.WindowRouter.RouteProcessName("Thunder", icons[5]);

    // 菜单
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

    // 快捷键
    Action setKeybindings = () => {
        KeyModifiers mod = KeyModifiers.Alt;
        KeyModifiers mod_shift = mod | KeyModifiers.Shift;
        KeyModifiers mod_ctrl = mod | KeyModifiers.Control;
        Action<int> switch_to_workspace_with_refresh = (index) => {
            context.Workspaces.SwitchToWorkspace(index);
            refresh_window(context.Workspaces.FocusedWorkspace.FocusedWindow);
        };

        // 解除所有的原生快捷键
        context.Keybinds.UnsubscribeAll();

        context.Keybinds.Subscribe(MouseEvent.LButtonDown, () => context.Workspaces.SwitchFocusedMonitorToMouseLocation());

        context.Keybinds.Subscribe(mod, workspacer.Keys.Escape, () => context.Enabled = !context.Enabled, "toggle enable/disable");

        context.Keybinds.Subscribe(mod, workspacer.Keys.Q, () => context.Workspaces.FocusedWorkspace.CloseFocusedWindow(), "close focused window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.W, () => context.Workspaces.FocusedWorkspace.NextLayoutEngine(), "next layout");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.W, () => context.Workspaces.FocusedWorkspace.PreviousLayoutEngine(), "previous layout");
        context.Keybinds.Subscribe(mod, workspacer.Keys.N, () => context.Workspaces.FocusedWorkspace.ResetLayout(), "reset layout");

        context.Keybinds.Subscribe(mod, workspacer.Keys.J, () => {
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
                        refresh_window(windows[index]);
                    }
                    if (!windows[index].IsMinimized) {
                        move_cursor_to_current_window_center();
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
        context.Keybinds.Subscribe(mod, workspacer.Keys.K, () => {
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
                        refresh_window(windows[index]);
                    }
                    if (!windows[index].IsMinimized) {
                        move_cursor_to_current_window_center();
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

        context.Keybinds.Subscribe(mod, workspacer.Keys.E, () => context.Workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow(), "swap focus and primary window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.J, () => context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow(), "swap focus and next window");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.K, () => context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow(), "swap focus and previous window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.H, () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea(), "shrink primary area");
        context.Keybinds.Subscribe(mod, workspacer.Keys.L, () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea(), "expand primary area");

        context.Keybinds.Subscribe(mod, workspacer.Keys.A, () => context.Workspaces.FocusedWorkspace.IncrementNumberOfPrimaryWindows(), "increment # primary windows");
        context.Keybinds.Subscribe(mod, workspacer.Keys.X, () => context.Workspaces.FocusedWorkspace.DecrementNumberOfPrimaryWindows(), "decrement # primary windows");

        context.Keybinds.Subscribe(mod, workspacer.Keys.T, () => context.Windows.ToggleFocusedWindowTiling(), "toggle tiling for focused window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.Q, context.Quit, "quit workspacer");
        context.Keybinds.Subscribe(mod, workspacer.Keys.R, context.Restart, "restart workspacer");

        context.Keybinds.Subscribe(mod, workspacer.Keys.D1, () => switch_to_workspace_with_refresh(0), "switch to workspace 1");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D2, () => switch_to_workspace_with_refresh(1), "switch to workspace 2");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D3, () => switch_to_workspace_with_refresh(2), "switch to workspace 3");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D4, () => switch_to_workspace_with_refresh(3), "switch to workspace 4");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D5, () => switch_to_workspace_with_refresh(4), "switch to workspace 5");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D6, () => switch_to_workspace_with_refresh(5), "switch to workspace 6");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D7, () => switch_to_workspace_with_refresh(6), "switch to workspace 7");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D8, () => switch_to_workspace_with_refresh(7), "switch to workspace 8");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D9, () => switch_to_workspace_with_refresh(8), "switch to workspace 9");
        context.Keybinds.Subscribe(mod, workspacer.Keys.S, () => switch_to_workspace_with_refresh(workspaces.Length - 1), "switch to workspace Others");

        // Subscribe(mod, workspacer.Keys.Left, () => _context.Workspaces.SwitchToPreviousWorkspace(), "switch to previous workspace");
        // Subscribe(mod, workspacer.Keys.Right, () => _context.Workspaces.SwitchToNextWorkspace(), "switch to next workspace");
        // Subscribe(mod | KeyModifiers.Control, workspacer.Keys.Left, () => _context.Workspaces.MoveFocusedWindowAndSwitchToPreviousWorkspace(), "move window to previous workspace and switch to it");
        // Subscribe(mod | KeyModifiers.Control, workspacer.Keys.Right, () => _context.Workspaces.MoveFocusedWindowAndSwitchToNextWorkspace(), "move window to next workspace and switch to it");
        context.Keybinds.Subscribe(mod, workspacer.Keys.Oemtilde, () => context.Workspaces.SwitchToLastFocusedWorkspace(), "switch to last focused workspace");

        context.Keybinds.Subscribe(mod, workspacer.Keys.U, () => context.Workspaces.SwitchFocusedMonitor(0), "focus monitor 1");
        context.Keybinds.Subscribe(mod, workspacer.Keys.I, () => context.Workspaces.SwitchFocusedMonitor(1), "focus monitor 2");
        context.Keybinds.Subscribe(mod, workspacer.Keys.O, () => context.Workspaces.SwitchFocusedMonitor(2), "focus monitor 3");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.U, () => context.Workspaces.MoveFocusedWindowToMonitor(0), "move focused window to monitor 1");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.I, () => context.Workspaces.MoveFocusedWindowToMonitor(1), "move focused window to monitor 2");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.O, () => context.Workspaces.MoveFocusedWindowToMonitor(2), "move focused window to monitor 3");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D1, () => context.Workspaces.MoveFocusedWindowToWorkspace(0), "switch focused window to workspace 1");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D2, () => context.Workspaces.MoveFocusedWindowToWorkspace(1), "switch focused window to workspace 2");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D3, () => context.Workspaces.MoveFocusedWindowToWorkspace(2), "switch focused window to workspace 3");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D4, () => context.Workspaces.MoveFocusedWindowToWorkspace(3), "switch focused window to workspace 4");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D5, () => context.Workspaces.MoveFocusedWindowToWorkspace(4), "switch focused window to workspace 5");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D6, () => context.Workspaces.MoveFocusedWindowToWorkspace(5), "switch focused window to workspace 6");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D7, () => context.Workspaces.MoveFocusedWindowToWorkspace(6), "switch focused window to workspace 7");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D8, () => context.Workspaces.MoveFocusedWindowToWorkspace(7), "switch focused window to workspace 8");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D9, () => context.Workspaces.MoveFocusedWindowToWorkspace(8), "switch focused window to workspace 9");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.S, () => context.Workspaces.MoveFocusedWindowToWorkspace(workspaces.Length - 1), "switch focused window to workspace Others");

        // Subscribe(mod, workspacer.Keys.O, () => _context.Windows.DumpWindowDebugOutput(), "dump debug info to console for all windows");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.O, () => _context.Windows.DumpWindowUnderCursorDebugOutput(), "dump debug info to console for window under cursor");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.I, () => _context.ToggleConsoleWindow(), "toggle debug console");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.Oem2, () => ShowKeybindDialog(), "toggle keybind window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.A, () => {
            var windows = context.Workspaces.FocusedWorkspace.ManagedWindows.Where(w => w.CanLayout).ToList();
            if (windows.Count > 1) {
                for (var i = 0; i < windows.Count - 1; i++) {
                    context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow();
                }
            }
        }, "rotate stack clockwise");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.X, () => {
            var windows = context.Workspaces.FocusedWorkspace.ManagedWindows.Where(w => w.CanLayout).ToList();
            if (windows.Count > 1) {
                for (var i = 0; i < windows.Count - 1; i++) {
                    context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow();
                }
            }
        }, "rotate stack counterclockwise");

        context.Keybinds.Subscribe(mod, workspacer.Keys.F, () => {
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
        context.Keybinds.Subscribe(mod, workspacer.Keys.D, () => {
            var focused_window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (focused_window != null) {
                if (focused_window.IsMinimized) {
                    focused_window.ShowNormal();
                    move_cursor_to_current_window_center();
                    refresh_window(focused_window);
                } else {
                    focused_window.ShowMinimized();
                }
            }
        }, "minimize focused window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.M, () => actionMenu.ShowMenu(actionMenuBuilder), "open action menu");
    };
    setKeybindings();
};

return doConfig;

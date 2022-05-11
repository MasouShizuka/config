#r "D:\Tools\Workspacer\workspacer.Shared.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

#load "C:\Users\MasouShizuka\.workspacer\Active_Layout_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Battery_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Input_Method_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Multi_Titles_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Text_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Time_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Workspace_Widget.csx"
#load "C:\Users\MasouShizuka\.workspacer\Workspacer_Status_Widget.csx"

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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
form.FormBorderStyle = FormBorderStyle.None;
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
[DllImport("user32.dll")]
static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
[DllImport("User32.dll")]
static extern bool SetCursorPos(int X, int Y);
[StructLayout(LayoutKind.Sequential)]
struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
static async void move_cursor_to_current_window_center() {
    try {
        await Task.Delay(100);
        RECT r = new RECT();
        GetWindowRect(GetForegroundWindow(), out r);
        int width = r.Right - r.Left;
        int height = r.Bottom - r.Top;
        int x = r.Left + width / 2;
        int y = r.Top + height / 2;
        SetCursorPos(x, y);
    } catch (Exception _) {
    }
}

Action<IConfigContext> doConfig = (context) => {
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None;

    var color_black = new Color(0x21, 0x22, 0x2C);
    var color_green = new Color(0x7E, 0xCA, 0x9C);
    var color_grey = new Color(0x28, 0x2A, 0x36);
    var color_orange = new Color(0xFF, 0xB8, 0x6C);
    var color_purple = new Color(0xD6, 0xAC, 0xFF);
    var color_red = new Color(0xFF, 0x55, 0x55);
    var color_white = new Color(0xAB, 0xB2, 0xBF);
    var color_yellow = new Color(0xF1, 0xFA, 0x8C);

    var background_color = color_black;
    var background_focus_color = color_grey;
    var bar_height = 25;
    var font_name = "Sarasa Mono SC Nerd Font";
    var font_size = 15;
    var gap = 8;

    // 顶栏
    context.AddBar(new BarPluginConfig() {
        BarHeight = bar_height,
        DefaultWidgetBackground = background_color,
        FontName = font_name,
        FontSize = font_size,

        LeftWidgets = () => new IBarWidget[] {
            new Workspace_Widget() {
                WorkspaceHasFocusForeColor = color_red,
                WorkspaceHasFocusBackColor = background_focus_color,
            },
            new Active_Layout_Widget() {
                LeftPadding = "[",
                RightPadding = "]",
                ForeColor = color_green,
            },
            new Text_Widget("┃") {
                ForeColor = color_white,
            },
            new Multi_Titles_Widget() {
                ForeColor = color_white,
                WindowHasFocusForeColor = color_yellow,
                WindowHasFocusBackColor = background_focus_color,
                MaxTitleLength = 38,
                ShowAllWindowTitles = true,
                TitlePreamble = "",
                TitlePostamble = "┃",
            }
        },

        RightWidgets = () => new IBarWidget[] {
            new Workspacer_Status_Widget(context) {
                LeftPadding = "[",
                RightPadding = "] ",
                status_on = color_green,
                status_off = color_red,
            },
            new Text_Widget(" ") {
                ForeColor = color_black,
                BackColor = color_orange,
            },
            new Input_Method_Widget() {
                ForeColor = color_orange,
                Interval = 500,
            },
            new Battery_Widget() {
                IconColor = color_black,
                HighChargeColor = color_green,
                MedChargeColor = color_yellow,
                LowChargeColor = color_red,
            },
            new Text_Widget(" ") {
                ForeColor = color_black,
                BackColor = color_purple,
            },
            new Time_Widget(1000, "yyyy-MM-dd HH:mm:ss ddd") {
                ForeColor = color_purple,
            },
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
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
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
        Background = background_color,
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
            context.Workspaces.FocusedWorkspace.Name = name;
        });
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

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.A, async () => {
            var windows = context.Workspaces.FocusedWorkspace.ManagedWindows.Where(w => w.CanLayout).ToList();
            if (windows.Count > 1) {
                for (var i = 0; i < windows.Count - 1; i++) {
                    context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow();
                }
            }
        }, "rotate stack clockwise");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.X, async () => {
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

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.F, async () => {
            var focused_window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                if (focused_window != null) {
                    if (focused_window.IsMinimized) {
                        focused_window.ShowNormal();
                    }
                }
            } else {
                var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
                for (var i = 0; i < windows.Count; i++) {
                    var window = windows[i];
                    if (window.IsMinimized) {
                        window.ShowNormal();
                    }
                }
            }
            refresh_window(focused_window);
            context.Workspaces.FocusedWorkspace.DoLayout();
        }, "unhide all windows");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.D, async () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            for (var i = 0; i < windows.Count; i++) {
                var window = windows[i];
                if (!window.IsMinimized) {
                    await Task.Delay(10);
                    window.ShowMinimized();
                }
            }
        }, "hide all windows");

        context.Keybinds.Subscribe(mod, workspacer.Keys.M, () => actionMenu.ShowMenu(actionMenuBuilder), "open action menu");
    };
    setKeybindings();
};

return doConfig;

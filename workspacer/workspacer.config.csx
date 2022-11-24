#r "D:\Tools\Workspacer\workspacer.Shared.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "D:\Tools\workspacer\plugins\workspacer.FocusBorder\workspacer.FocusBorder.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"
#r "D:\Tools\Workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"

#load "C:\Users\MasouShizuka\.config\workspacer\Active_Layout_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Battery_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Input_Method_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Multi_Titles_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Network_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Performance_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Text_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Time_Widget.csx"
#load "C:\Users\MasouShizuka\.config\workspacer\Workspace_Widget.csx"

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using workspacer;
using workspacer.ActionMenu;
using workspacer.Bar;
using workspacer.Bar.Widgets;
using workspacer.FocusBorder;
using workspacer.FocusIndicator;
using workspacer.Gap;

// 某些程序（例如 vscode）会在调用某些 api 后卡住，例如切换 workspace 时
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
form.TopMost = true;
// 通过激活 Form 后再将其隐藏的方式刷新 workspacer
static async void refresh() {
    await Task.Delay(500);
    form.Show();
    form.Activate();
    form.Hide();
}
// 对指定的程序进行刷新
static void refresh_window(IWindow window) {
    if (window != null) {
        string window_process_name = window.ProcessName;
        foreach (string process_name in process_name_list) {
            if (window_process_name == process_name) {
                refresh();
                break;
            }
        }
    }
}

[DllImport("User32.dll")]
static extern bool SetCursorPos(int X, int Y);
// 移动鼠标到窗口中心
static void move_cursor_to_window_center(IWindow window) {
    IWindowLocation l = window.Location;
    int width = l.Width;
    int height = l.Height;
    int x = l.X + width / 2;
    int y = l.Y + height / 2;
    SetCursorPos(x, y);
}

[DllImport("user32.dll")]
static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
[StructLayout(LayoutKind.Sequential)]
struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
[DllImport("user32.dll")]
static extern IntPtr SetWindowPos(IntPtr hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, int wFlags);
// 移动窗口
static void move_window(int x, int y) {
    IntPtr hWnd = GetForegroundWindow();
    RECT r = new RECT();
    GetWindowRect(GetForegroundWindow(), out r);
    int X = r.Left + x;
    int Y = r.Top + y;
    SetWindowPos(hWnd, 0, X, Y, 0, 0, 0x0001 | 0x0004);
}
// 改变窗口大小
static void change_window_size(int x, int y) {
    IntPtr hWnd = GetForegroundWindow();
    RECT r = new RECT();
    GetWindowRect(GetForegroundWindow(), out r);
    int cx = r.Right - r.Left + x;
    int cy = r.Bottom - r.Top + y;
    SetWindowPos(hWnd, 0, 0, 0, cx, cy, 0x0002 | 0x0004);
}

// 切换当前 layout 和 full layout
static bool is_full = false;
static int switch_steps = 0;

Action<IConfigContext> doConfig = (context) => {
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None;

    var color_black = new Color(0x21, 0x22, 0x2C);
    var color_blue = new Color(0x42, 0xA5, 0xF5);
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
    var window_step = 40;

    // 能最小化窗口
    context.CanMinimizeWindows = true;

    // 窗口间的间距
    context.AddGap(new GapPluginConfig() {
        InnerGap = gap,
        OuterGap = gap / 2,
        Delta = gap / 2,
    });

    // 顶栏
    context.AddBar(new BarPluginConfig() {
        Background = background_color,
        BarHeight = bar_height,
        DefaultWidgetBackground = background_color,
        FontName = font_name,
        FontSize = font_size,

        LeftWidgets = () => new IBarWidget[] {
            new Workspace_Widget() {
                WorkspaceHasFocusForeColor = color_red,
                WorkspaceHasFocusBackColor = background_focus_color,
            },
            new Active_Layout_Widget(context) {
                LeftPadding = "[",
                RightPadding = "]",
                ForeColor = color_green,
                DisableColor = color_red,
                Interval = 500,
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
            new Network_Widget() {
                ForeColor = color_black,
                BackColor = color_purple,
            },
            new Text_Widget(" ") {
                ForeColor = color_black,
                BackColor = color_orange,
            },
            new Input_Method_Widget() {
                ForeColor = color_orange,
                Interval = 500,
            },
            new Text_Widget("⚙") {
                ForeColor = color_black,
                BackColor = color_red,
            },
            new Cpu_Performance_Widget() {
                ForeColor = color_red,
                RightPadding = "%",
            },
            new Text_Widget("🗏") {
                ForeColor = color_black,
                BackColor = color_green,
            },
            new Memory_Performance_Widget() {
                ForeColor = color_green,
                RightPadding = "%",
            },
            new Battery_Widget() {
                IconColor = color_black,
                HighChargeColor = color_green,
                MedChargeColor = color_yellow,
                LowChargeColor = color_red,
            },
            new Time_Widget(1000, "yyyy-MM-dd HH:mm:ss ddd") {
                ForeColor = color_black,
                BackColor = color_purple,
            },
        },
    });

    // 当前窗口的外框
    var focusBorderPluginConfig = new FocusBorderPluginConfig();
    focusBorderPluginConfig.BorderColor = color_blue;
    focusBorderPluginConfig.BorderSize = 10;
    focusBorderPluginConfig.Opacity = 1.0;
    context.AddFocusBorder(focusBorderPluginConfig);

    // 切换窗口时的外框
    var focusIndicatorPluginConfig = new FocusIndicatorPluginConfig();
    focusIndicatorPluginConfig.BorderColor = Color.Red;
    focusIndicatorPluginConfig.BorderSize = 10;
    focusIndicatorPluginConfig.TimeToShow = 200;
    context.AddFocusIndicator(focusIndicatorPluginConfig);

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
    context.WindowRouter.IgnoreProcessName("Bandizip64");
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
        KeyModifiers mod_ctrl = mod | KeyModifiers.Control;
        KeyModifiers mod_shift = mod | KeyModifiers.Shift;
        KeyModifiers mod_ctrl_shift = mod | KeyModifiers.Control | KeyModifiers.Shift;

        // 解除所有的原生快捷键
        context.Keybinds.UnsubscribeAll();

        context.Keybinds.Subscribe(MouseEvent.LButtonDown, () => context.Workspaces.SwitchFocusedMonitorToMouseLocation());

        context.Keybinds.Subscribe(mod, workspacer.Keys.Escape, () => context.Enabled = !context.Enabled, "toggle enable/disable");

        context.Keybinds.Subscribe(mod, workspacer.Keys.Q, () => context.Workspaces.FocusedWorkspace.CloseFocusedWindow(), "close focused window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.W, () => {
            var layout_name = context.Workspaces.FocusedWorkspace.LayoutName;
            context.Workspaces.FocusedWorkspace.NextLayoutEngine();
            if (layout_name == "full") {
                var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
                for (var i = 0; i < windows.Count; i++) {
                    var window = windows[i];
                    if (window.IsMinimized) {
                        window.ShowNormal();
                    }
                }
                context.Workspaces.FocusedWorkspace.DoLayout();
            }
            }, "next layout");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.W, () => {
            var layout_name = context.Workspaces.FocusedWorkspace.LayoutName;
            context.Workspaces.FocusedWorkspace.PreviousLayoutEngine();
            if (layout_name == "full") {
                var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
                for (var i = 0; i < windows.Count; i++) {
                    var window = windows[i];
                    if (window.IsMinimized) {
                        window.ShowNormal();
                    }
                }
                context.Workspaces.FocusedWorkspace.DoLayout();
            }
            }, "previous layout");
        context.Keybinds.Subscribe(mod, workspacer.Keys.N, () => context.Workspaces.FocusedWorkspace.ResetLayout(), "reset layout");

        context.Keybinds.Subscribe(mod, workspacer.Keys.J, () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            var didFocus = false;
            for (var i = 0; i < windows.Count; i++) {
                var window = windows[i];
                var index = 0;
                if (window.IsFocused) {
                    if (i + 1 != windows.Count) {
                        index = i + 1;
                    }
                    window = windows[index];
                    window.Focus();
                    didFocus = true;

                    if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                        window.ShowNormal();
                        refresh_window(window);
                    }

                    if (!window.IsMinimized) {
                        move_cursor_to_window_center(window);
                    }

                    break;
                }
            }
            if (!didFocus && windows.Count > 0) {
                windows[0].Focus();
            }
        }, "focus next window");
        context.Keybinds.Subscribe(mod, workspacer.Keys.K, () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            var didFocus = false;
            for (var i = 0; i < windows.Count; i++) {
                var window = windows[i];
                var index = windows.Count - 1;
                if (window.IsFocused) {
                    if (i != 0) {
                        index = i - 1;
                    }
                    window = windows[index];
                    window.Focus();
                    didFocus = true;

                    if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                        window.ShowNormal();
                        refresh_window(window);
                    }

                    if (!window.IsMinimized) {
                        move_cursor_to_window_center(window);
                    }

                    break;
                }
            }
            if (!didFocus && windows.Count > 0) {
                windows[0].Focus();
            }
        }, "focus previous window");
        context.Keybinds.Subscribe(mod, workspacer.Keys.E, () => {
            var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
            var window = windows.FirstOrDefault();
            window.Focus();

            if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                window.ShowNormal();
                refresh_window(window);
            }

            if (!window.IsMinimized) {
                move_cursor_to_window_center(window);
            }
        }, "focus primary window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.E, () => {
            var windows = context.Workspaces.FocusedWorkspace.ManagedWindows.Where(w => w.CanLayout).ToList();
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            var focused_window_index = windows.FindIndex(w => w == window);
            if (windows.Count > 1) {
                for (var i = 0; i < focused_window_index; i++) {
                    context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow();
                }
            }
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "swap focus and primary window");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.J, () => {
            context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow();
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "swap focus and next window");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.K, () => {
            context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow();
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "swap focus and previous window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.H, () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea(), "shrink primary area");
        context.Keybinds.Subscribe(mod, workspacer.Keys.L, () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea(), "expand primary area");

        // context.Keybinds.Subscribe(mod, workspacer.Keys.Oemcomma, () => context.Workspaces.FocusedWorkspace.IncrementNumberOfPrimaryWindows(), "increment # primary windows");
        // context.Keybinds.Subscribe(mod, workspacer.Keys.OemPeriod () => context.Workspaces.FocusedWorkspace.DecrementNumberOfPrimaryWindows(), "decrement # primary windows");

        context.Keybinds.Subscribe(mod, workspacer.Keys.T, () => context.Windows.ToggleFocusedWindowTiling(), "toggle tiling for focused window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.Q, context.Quit, "quit workspacer");
        context.Keybinds.Subscribe(mod, workspacer.Keys.R, context.Restart, "restart workspacer");

        context.Keybinds.Subscribe(mod, workspacer.Keys.D1, () => {
            context.Workspaces.SwitchToWorkspace(0);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 1");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D2, () => {
            context.Workspaces.SwitchToWorkspace(1);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 2");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D3, () => {
            context.Workspaces.SwitchToWorkspace(2);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 3");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D4, () => {
            context.Workspaces.SwitchToWorkspace(3);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 4");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D5, () => {
            context.Workspaces.SwitchToWorkspace(4);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 5");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D6, () => {
            context.Workspaces.SwitchToWorkspace(5);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 6");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D7, () => {
            context.Workspaces.SwitchToWorkspace(6);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 7");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D8, () => {
            context.Workspaces.SwitchToWorkspace(7);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 8");
        context.Keybinds.Subscribe(mod, workspacer.Keys.D9, () => {
            context.Workspaces.SwitchToWorkspace(8);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "switch to workspace 9");

        // Subscribe(mod, workspacer.Keys.Left, () => _context.Workspaces.SwitchToPreviousWorkspace(), "switch to previous workspace");
        // Subscribe(mod, workspacer.Keys.Right, () => _context.Workspaces.SwitchToNextWorkspace(), "switch to next workspace");
        // Subscribe(mod | KeyModifiers.Control, workspacer.Keys.Left, () => _context.Workspaces.MoveFocusedWindowAndSwitchToPreviousWorkspace(), "move window to previous workspace and switch to it");
        // Subscribe(mod | KeyModifiers.Control, workspacer.Keys.Right, () => _context.Workspaces.MoveFocusedWindowAndSwitchToNextWorkspace(), "move window to next workspace and switch to it");
        context.Keybinds.Subscribe(mod, workspacer.Keys.Oemtilde, () => context.Workspaces.SwitchToLastFocusedWorkspace(), "switch to last focused workspace");

        context.Keybinds.Subscribe(mod, workspacer.Keys.U, () => {
            context.Workspaces.SwitchFocusedMonitor(0);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "focus monitor 1");
        context.Keybinds.Subscribe(mod, workspacer.Keys.I, () => {
            context.Workspaces.SwitchFocusedMonitor(1);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "focus monitor 2");
        context.Keybinds.Subscribe(mod, workspacer.Keys.O, () => {
            context.Workspaces.SwitchFocusedMonitor(2);
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                move_cursor_to_window_center(window);
            }
        }, "focus monitor 3");
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

        // Subscribe(mod, workspacer.Keys.O, () => _context.Windows.DumpWindowDebugOutput(), "dump debug info to console for all windows");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.O, () => _context.Windows.DumpWindowUnderCursorDebugOutput(), "dump debug info to console for window under cursor");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.I, () => _context.ToggleConsoleWindow(), "toggle debug console");
        // Subscribe(mod | KeyModifiers.LShift, workspacer.Keys.Oem2, () => ShowKeybindDialog(), "toggle keybind window");

        context.Keybinds.Subscribe(mod, workspacer.Keys.C, () => {
            var windows = context.Workspaces.FocusedWorkspace.ManagedWindows.Where(w => w.CanLayout).ToList();
            if (windows.Count > 1) {
                for (var i = 0; i < windows.Count - 1; i++) {
                    context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow();
                }
            }
        }, "rotate stack clockwise");
        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.C, () => {
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
            var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
            if (window != null) {
                if (window.IsMinimized) {
                    window.ShowNormal();
                    move_cursor_to_window_center(window);
                    refresh_window(window);
                } else {
                    window.ShowMinimized();
                }
            }
        }, "minimize focused window");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.F, () => {
            if (context.Workspaces.FocusedWorkspace.LayoutName == "full") {
                var window = context.Workspaces.FocusedWorkspace.FocusedWindow;
                if (window != null) {
                    if (window.IsMinimized) {
                        window.ShowNormal();
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
            refresh_window(context.Workspaces.FocusedWorkspace.FocusedWindow);
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

        context.Keybinds.Subscribe(mod, workspacer.Keys.M, () => {
            if (!is_full) {
                var layout_name = context.Workspaces.FocusedWorkspace.LayoutName;
                if (layout_name != "full") {
                    while (layout_name != "full") {
                        context.Workspaces.FocusedWorkspace.PreviousLayoutEngine();
                        layout_name = context.Workspaces.FocusedWorkspace.LayoutName;
                        switch_steps++;
                    }
                    is_full = true;
                }
            } else {
                while (switch_steps != 0) {
                    context.Workspaces.FocusedWorkspace.NextLayoutEngine();
                    switch_steps--;
                }
                is_full = false;

                var windows = context.Workspaces.FocusedWorkspace.Windows.Where(w => w.CanLayout).ToList();
                for (var i = 0; i < windows.Count; i++) {
                    var window = windows[i];
                    if (window.IsMinimized) {
                        window.ShowNormal();
                    }
                }
                context.Workspaces.FocusedWorkspace.DoLayout();
            }
        }, "switch between current and full layout");

        context.Keybinds.Subscribe(mod_shift, workspacer.Keys.M, () => actionMenu.ShowMenu(actionMenuBuilder), "open action menu");

        context.Keybinds.Subscribe(mod_ctrl, workspacer.Keys.Up, () => move_window(0, -window_step), "move window up");
        context.Keybinds.Subscribe(mod_ctrl, workspacer.Keys.Down, () => move_window(0, window_step), "move window down");
        context.Keybinds.Subscribe(mod_ctrl, workspacer.Keys.Left, () => move_window(-window_step, 0), "move window left");
        context.Keybinds.Subscribe(mod_ctrl, workspacer.Keys.Right, () => move_window(window_step, 0), "move window right");

        context.Keybinds.Subscribe(mod_ctrl_shift, workspacer.Keys.Up, () => change_window_size(0, -window_step), "decrease window height");
        context.Keybinds.Subscribe(mod_ctrl_shift, workspacer.Keys.Down, () => change_window_size(0, window_step), "increase window height");
        context.Keybinds.Subscribe(mod_ctrl_shift, workspacer.Keys.Left, () => change_window_size(-window_step, 0), "decrease window width");
        context.Keybinds.Subscribe(mod_ctrl_shift, workspacer.Keys.Right, () => change_window_size(window_step, 0), "increase window width");
    };
    setKeybindings();
};

return doConfig;

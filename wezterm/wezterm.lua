local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

local zsh = {
    label = "Zsh",
    args = {
        "C:/msys64/msys2_shell.cmd",
        "-ucrt64",
        "-defterm",
        "-here",
        "-use-full-path",
        "-no-start",
        "-shell",
        "zsh",
    },
}

local powershell = {
    label = "Powershell",
    args = {
        "pwsh",
        "-NoLogo",
    },
}

local arch = {
    label = "Arch",
    args = {
        "wsl",
        "-d",
        "Arch",
        "--cd",
        "~",
    },
}

config.adjust_window_size_when_changing_font_size = false

config.animation_fps = 60

config.color_scheme = "Windows 10 (base16)"

config.command_palette_font_size = 20.0

config.default_prog = zsh.args

config.disable_default_key_bindings = true

config.font = wezterm.font("Sarasa Mono SC Nerd Font")

config.font_size = 16.0

config.front_end = "WebGpu"

config.hide_tab_bar_if_only_one_tab = true

config.initial_cols = 120

config.initial_rows = 30

config.keys = {
    -- 间接映射，以便 neovim 能够接收原本不接收的 keymap
    { key = "1",          mods = "CTRL",           action = act.SendKey({ key = "F1", mods = "CTRL" }) },
    { key = "2",          mods = "CTRL",           action = act.SendKey({ key = "F2", mods = "CTRL" }) },
    { key = "3",          mods = "CTRL",           action = act.SendKey({ key = "F3", mods = "CTRL" }) },
    { key = "4",          mods = "CTRL",           action = act.SendKey({ key = "F4", mods = "CTRL" }) },
    { key = "Space",      mods = "CTRL",           action = act.SendKey({ key = "F5", mods = "CTRL" }) },
    { key = "Comma",      mods = "CTRL",           action = act.SendKey({ key = "F6", mods = "CTRL" }) },
    { key = "Period",     mods = "CTRL",           action = act.SendKey({ key = "F7", mods = "CTRL" }) },
    { key = "Semicolon",  mods = "CTRL",           action = act.SendKey({ key = "F8", mods = "CTRL" }) },
    { key = "n",          mods = "CTRL|SHIFT",     action = act.SendKey({ key = "F9", mods = "CTRL" }) },
    { key = "t",          mods = "CTRL|SHIFT",     action = act.SendKey({ key = "F10", mods = "CTRL" }) },

    { key = "Grave",      mods = "CTRL|SHIFT",     action = act.ShowLauncher },
    { key = "phys:1",     mods = "CTRL|SHIFT",     action = act.SpawnCommandInNewTab(zsh) },
    { key = "phys:2",     mods = "CTRL|SHIFT",     action = act.SpawnCommandInNewTab(powershell) },
    { key = "phys:3",     mods = "CTRL|SHIFT",     action = act.SpawnCommandInNewTab(arch) },

    -- { key = "Tab",        mods = "CTRL",           action = act.ActivateTabRelative(1) },
    -- { key = "Tab",        mods = "SHIFT|CTRL",     action = act.ActivateTabRelative(-1) },
    { key = "l",          mods = "CTRL|SHIFT",     action = act.ActivateTabRelative(1) },
    { key = "h",          mods = "CTRL|SHIFT",     action = act.ActivateTabRelative(-1) },
    { key = "Enter",      mods = "ALT",            action = act.ToggleFullScreen },
    -- { key = "!",          mods = "CTRL",           action = act.ActivateTab(0) },
    -- { key = "!",          mods = "SHIFT|CTRL",     action = act.ActivateTab(0) },
    -- { key = "\"",         mods = "ALT|CTRL",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- { key = "\"",         mods = "SHIFT|ALT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "h",          mods = "LEADER",         action = act.SplitPane({ direction = "Left" }) },
    { key = "l",          mods = "LEADER",         action = act.SplitPane({ direction = "Right" }) },
    { key = "j",          mods = "LEADER",         action = act.SplitPane({ direction = "Down" }) },
    { key = "k",          mods = "LEADER",         action = act.SplitPane({ direction = "Up" }) },
    -- { key = "#",          mods = "CTRL",           action = act.ActivateTab(2) },
    -- { key = "#",          mods = "SHIFT|CTRL",     action = act.ActivateTab(2) },
    -- { key = "$",          mods = "CTRL",           action = act.ActivateTab(3) },
    -- { key = "$",          mods = "SHIFT|CTRL",     action = act.ActivateTab(3) },
    -- { key = "%",          mods = "CTRL",           action = act.ActivateTab(4) },
    -- { key = "%",          mods = "SHIFT|CTRL",     action = act.ActivateTab(4) },
    -- { key = "%",          mods = "ALT|CTRL",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- { key = "%",          mods = "SHIFT|ALT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- { key = "&",          mods = "CTRL",           action = act.ActivateTab(6) },
    -- { key = "&",          mods = "SHIFT|CTRL",     action = act.ActivateTab(6) },
    -- { key = "'",          mods = "SHIFT|ALT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- { key = "(",          mods = "CTRL",           action = act.ActivateTab(-1) },
    -- { key = "(",          mods = "SHIFT|CTRL",     action = act.ActivateTab(-1) },
    -- { key = ")",          mods = "CTRL",           action = act.ResetFontSize },
    -- { key = ")",          mods = "SHIFT|CTRL",     action = act.ResetFontSize },
    -- { key = "*",          mods = "CTRL",           action = act.ActivateTab(7) },
    -- { key = "*",          mods = "SHIFT|CTRL",     action = act.ActivateTab(7) },
    { key = "+",          mods = "CTRL",           action = act.IncreaseFontSize },
    { key = "+",          mods = "SHIFT|CTRL",     action = act.IncreaseFontSize },
    { key = "-",          mods = "CTRL",           action = act.DecreaseFontSize },
    { key = "-",          mods = "SHIFT|CTRL",     action = act.DecreaseFontSize },
    { key = "-",          mods = "SUPER",          action = act.DecreaseFontSize },
    { key = "0",          mods = "CTRL",           action = act.ResetFontSize },
    { key = "0",          mods = "SHIFT|CTRL",     action = act.ResetFontSize },
    { key = "0",          mods = "SUPER",          action = act.ResetFontSize },
    -- { key = "1",          mods = "SHIFT|CTRL",     action = act.ActivateTab(0) },
    -- { key = "1",          mods = "SUPER",          action = act.ActivateTab(0) },
    -- { key = "2",          mods = "SHIFT|CTRL",     action = act.ActivateTab(1) },
    -- { key = "2",          mods = "SUPER",          action = act.ActivateTab(1) },
    -- { key = "3",          mods = "SHIFT|CTRL",     action = act.ActivateTab(2) },
    -- { key = "3",          mods = "SUPER",          action = act.ActivateTab(2) },
    -- { key = "4",          mods = "SHIFT|CTRL",     action = act.ActivateTab(3) },
    -- { key = "4",          mods = "SUPER",          action = act.ActivateTab(3) },
    -- { key = "5",          mods = "SHIFT|CTRL",     action = act.ActivateTab(4) },
    -- { key = "5",          mods = "SHIFT|ALT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- { key = "5",          mods = "SUPER",          action = act.ActivateTab(4) },
    -- { key = "6",          mods = "SHIFT|CTRL",     action = act.ActivateTab(5) },
    -- { key = "6",          mods = "SUPER",          action = act.ActivateTab(5) },
    -- { key = "7",          mods = "SHIFT|CTRL",     action = act.ActivateTab(6) },
    -- { key = "7",          mods = "SUPER",          action = act.ActivateTab(6) },
    -- { key = "8",          mods = "SHIFT|CTRL",     action = act.ActivateTab(7) },
    -- { key = "8",          mods = "SUPER",          action = act.ActivateTab(7) },
    -- { key = "9",          mods = "SHIFT|CTRL",     action = act.ActivateTab(-1) },
    -- { key = "9",          mods = "SUPER",          action = act.ActivateTab(-1) },
    { key = "=",          mods = "CTRL",           action = act.IncreaseFontSize },
    { key = "=",          mods = "SHIFT|CTRL",     action = act.IncreaseFontSize },
    { key = "=",          mods = "SUPER",          action = act.IncreaseFontSize },
    -- { key = "@",          mods = "CTRL",           action = act.ActivateTab(1) },
    -- { key = "@",          mods = "SHIFT|CTRL",     action = act.ActivateTab(1) },
    { key = "C",          mods = "CTRL",           action = act.CopyTo("Clipboard") },
    { key = "C",          mods = "SHIFT|CTRL",     action = act.CopyTo("Clipboard") },
    { key = "F",          mods = "CTRL",           action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "F",          mods = "SHIFT|CTRL",     action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "K",          mods = "CTRL",           action = act.ClearScrollback("ScrollbackOnly") },
    { key = "K",          mods = "SHIFT|CTRL",     action = act.ClearScrollback("ScrollbackOnly") },
    -- { key = "L",          mods = "CTRL",           action = act.ShowDebugOverlay },
    -- { key = "L",          mods = "SHIFT|CTRL",     action = act.ShowDebugOverlay },
    -- { key = "M",          mods = "CTRL",           action = act.Hide },
    -- { key = "M",          mods = "SHIFT|CTRL",     action = act.Hide },
    -- { key = "N",          mods = "CTRL",           action = act.SpawnWindow },
    -- { key = "N",          mods = "SHIFT|CTRL",     action = act.SpawnWindow },
    { key = "P",          mods = "CTRL",           action = act.ActivateCommandPalette },
    { key = "P",          mods = "SHIFT|CTRL",     action = act.ActivateCommandPalette },
    { key = "R",          mods = "CTRL",           action = act.ReloadConfiguration },
    { key = "R",          mods = "SHIFT|CTRL",     action = act.ReloadConfiguration },
    -- { key = "T",          mods = "CTRL",           action = act.SpawnTab("CurrentPaneDomain") },
    -- { key = "T",          mods = "SHIFT|CTRL",     action = act.SpawnTab("CurrentPaneDomain") },
    -- { key = "U",          mods = "CTRL",           action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
    -- { key = "U",          mods = "SHIFT|CTRL",     action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
    { key = "v",          mods = "CTRL",           action = act.PasteFrom("Clipboard") },
    { key = "V",          mods = "CTRL",           action = act.PasteFrom("Clipboard") },
    { key = "V",          mods = "SHIFT|CTRL",     action = act.PasteFrom("Clipboard") },
    -- { key = "W",          mods = "CTRL",           action = act.CloseCurrentTab({ confirm = true }) },
    -- { key = "W",          mods = "SHIFT|CTRL",     action = act.CloseCurrentTab({ confirm = true }) },
    { key = "w",          mods = "CTRL|SHIFT",     action = act.CloseCurrentPane({ confirm = false }) },
    { key = "X",          mods = "CTRL",           action = act.ActivateCopyMode },
    { key = "X",          mods = "SHIFT|CTRL",     action = act.ActivateCopyMode },
    { key = "Z",          mods = "CTRL",           action = act.TogglePaneZoomState },
    { key = "Z",          mods = "SHIFT|CTRL",     action = act.TogglePaneZoomState },
    -- { key = "[",          mods = "SHIFT|SUPER",    action = act.ActivateTabRelative(-1) },
    -- { key = "]",          mods = "SHIFT|SUPER",    action = act.ActivateTabRelative(1) },
    -- { key = "^",          mods = "CTRL",           action = act.ActivateTab(5) },
    -- { key = "^",          mods = "SHIFT|CTRL",     action = act.ActivateTab(5) },
    { key = "_",          mods = "CTRL",           action = act.DecreaseFontSize },
    { key = "_",          mods = "SHIFT|CTRL",     action = act.DecreaseFontSize },
    { key = "c",          mods = "SHIFT|CTRL",     action = act.CopyTo("Clipboard") },
    { key = "c",          mods = "SUPER",          action = act.CopyTo("Clipboard") },
    { key = "f",          mods = "SHIFT|CTRL",     action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "f",          mods = "SUPER",          action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "k",          mods = "SHIFT|CTRL",     action = act.ClearScrollback("ScrollbackOnly") },
    { key = "k",          mods = "SUPER",          action = act.ClearScrollback("ScrollbackOnly") },
    -- { key = "l",          mods = "SHIFT|CTRL",     action = act.ShowDebugOverlay },
    -- { key = "m",          mods = "SHIFT|CTRL",     action = act.Hide },
    -- { key = "m",          mods = "SUPER",          action = act.Hide },
    -- { key = "n",          mods = "SHIFT|CTRL",     action = act.SpawnWindow },
    -- { key = "n",          mods = "SUPER",          action = act.SpawnWindow },
    { key = "p",          mods = "SHIFT|CTRL",     action = act.ActivateCommandPalette },
    { key = "r",          mods = "SHIFT|CTRL",     action = act.ReloadConfiguration },
    { key = "r",          mods = "SUPER",          action = act.ReloadConfiguration },
    -- { key = "t",          mods = "SHIFT|CTRL",     action = act.SpawnTab("CurrentPaneDomain") },
    -- { key = "t",          mods = "SUPER",          action = act.SpawnTab("CurrentPaneDomain") },
    -- { key = "u",          mods = "SHIFT|CTRL",     action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
    { key = "v",          mods = "SHIFT|CTRL",     action = act.PasteFrom("Clipboard") },
    { key = "v",          mods = "SUPER",          action = act.PasteFrom("Clipboard") },
    -- { key = "w",          mods = "SHIFT|CTRL",     action = act.CloseCurrentTab({ confirm = true }) },
    -- { key = "w",          mods = "SUPER",          action = act.CloseCurrentTab({ confirm = true }) },
    { key = "x",          mods = "SHIFT|CTRL",     action = act.ActivateCopyMode },
    { key = "z",          mods = "SHIFT|CTRL",     action = act.TogglePaneZoomState },
    -- { key = "{",          mods = "SUPER",          action = act.ActivateTabRelative(-1) },
    -- { key = "{",          mods = "SHIFT|SUPER",    action = act.ActivateTabRelative(-1) },
    -- { key = "}",          mods = "SUPER",          action = act.ActivateTabRelative(1) },
    -- { key = "}",          mods = "SHIFT|SUPER",    action = act.ActivateTabRelative(1) },
    { key = "phys:Space", mods = "SHIFT|CTRL",     action = act.QuickSelect },
    -- { key = "PageUp",     mods = "SHIFT",          action = act.ScrollByPage(-1) },
    -- { key = "PageUp",     mods = "CTRL",           action = act.ActivateTabRelative(-1) },
    -- { key = "PageUp",     mods = "SHIFT|CTRL",     action = act.MoveTabRelative(-1) },
    -- { key = "PageDown",   mods = "SHIFT",          action = act.ScrollByPage(1) },
    -- { key = "PageDown",   mods = "CTRL",           action = act.ActivateTabRelative(1) },
    -- { key = "PageDown",   mods = "SHIFT|CTRL",     action = act.MoveTabRelative(1) },
    { key = "u",          mods = "CTRL|SHIFT",     action = act.ScrollByPage(-1) },
    { key = "d",          mods = "CTRL|SHIFT",     action = act.ScrollByPage(1) },
    { key = "Comma",      mods = "CTRL|SHIFT",     action = act.MoveTabRelative(-1) },
    { key = "Period",     mods = "CTRL|SHIFT",     action = act.MoveTabRelative(1) },
    -- { key = "LeftArrow",  mods = "SHIFT|CTRL",     action = act.ActivatePaneDirection("Left") },
    -- { key = "LeftArrow",  mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
    -- { key = "RightArrow", mods = "SHIFT|CTRL",     action = act.ActivatePaneDirection("Right") },
    -- { key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
    -- { key = "UpArrow",    mods = "SHIFT|CTRL",     action = act.ActivatePaneDirection("Up") },
    -- { key = "UpArrow",    mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
    -- { key = "DownArrow",  mods = "SHIFT|CTRL",     action = act.ActivatePaneDirection("Down") },
    -- { key = "DownArrow",  mods = "CTRL|SHIFT",     action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "LeftArrow",  mods = "CTRL|SHIFT",     action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "RightArrow", mods = "CTRL|SHIFT",     action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "UpArrow",    mods = "CTRL|SHIFT",     action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "DownArrow",  mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "j",          mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Next") },
    { key = "k",          mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Prev") },
    { key = "Insert",     mods = "SHIFT",          action = act.PasteFrom("PrimarySelection") },
    { key = "Insert",     mods = "CTRL",           action = act.CopyTo("PrimarySelection") },
    { key = "Copy",       mods = "NONE",           action = act.CopyTo("Clipboard") },
    { key = "Paste",      mods = "NONE",           action = act.PasteFrom("Clipboard") },
}

config.key_tables = {
    copy_mode = {
        { key = "Tab",        mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
        { key = "Tab",        mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
        { key = "Enter",      mods = "NONE",  action = act.CopyMode("MoveToStartOfNextLine") },
        { key = "Escape",     mods = "NONE",  action = act.CopyMode("Close") },
        { key = "Space",      mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
        { key = "$",          mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "$",          mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "l",          mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
        { key = ",",          mods = "NONE",  action = act.CopyMode("JumpReverse") },
        { key = "0",          mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
        { key = ";",          mods = "NONE",  action = act.CopyMode("JumpAgain") },
        { key = "F",          mods = "NONE",  action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
        { key = "F",          mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
        { key = "G",          mods = "NONE",  action = act.CopyMode("MoveToScrollbackBottom") },
        { key = "G",          mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
        -- { key = "H",          mods = "NONE",  action = act.CopyMode("MoveToViewportTop") },
        -- { key = "H",          mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
        -- { key = "L",          mods = "NONE",  action = act.CopyMode("MoveToViewportBottom") },
        -- { key = "L",          mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
        -- { key = "M",          mods = "NONE",  action = act.CopyMode("MoveToViewportMiddle") },
        -- { key = "M",          mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
        { key = "O",          mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
        { key = "O",          mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
        { key = "T",          mods = "NONE",  action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
        { key = "T",          mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
        { key = "V",          mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Line" }) },
        { key = "V",          mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
        { key = "^",          mods = "NONE",  action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "^",          mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "h",          mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "b",          mods = "NONE",  action = act.CopyMode("MoveBackwardWord") },
        -- { key = "b",          mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
        { key = "b",          mods = "CTRL",  action = act.CopyMode("PageUp") },
        { key = "c",          mods = "CTRL",  action = act.CopyMode("Close") },
        { key = "d",          mods = "CTRL",  action = act.CopyMode({ MoveByPage = 0.5 }) },
        { key = "e",          mods = "NONE",  action = act.CopyMode("MoveForwardWordEnd") },
        { key = "f",          mods = "NONE",  action = act.CopyMode({ JumpForward = { prev_char = false } }) },
        -- { key = "f",          mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
        { key = "f",          mods = "CTRL",  action = act.CopyMode("PageDown") },
        { key = "g",          mods = "NONE",  action = act.CopyMode("MoveToScrollbackTop") },
        { key = "g",          mods = "CTRL",  action = act.CopyMode("Close") },
        { key = "h",          mods = "NONE",  action = act.CopyMode("MoveLeft") },
        { key = "j",          mods = "NONE",  action = act.CopyMode("MoveDown") },
        { key = "k",          mods = "NONE",  action = act.CopyMode("MoveUp") },
        { key = "l",          mods = "NONE",  action = act.CopyMode("MoveRight") },
        -- { key = "m",          mods = "ALT",   action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "o",          mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEnd") },
        { key = "q",          mods = "NONE",  action = act.CopyMode("Close") },
        { key = "t",          mods = "NONE",  action = act.CopyMode({ JumpForward = { prev_char = true } }) },
        { key = "u",          mods = "CTRL",  action = act.CopyMode({ MoveByPage = -0.5 }) },
        { key = "v",          mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
        { key = "v",          mods = "CTRL",  action = act.CopyMode({ SetSelectionMode = "Block" }) },
        { key = "w",          mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
        { key = "y",          mods = "NONE",  action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },
        { key = "PageUp",     mods = "NONE",  action = act.CopyMode("PageUp") },
        { key = "PageDown",   mods = "NONE",  action = act.CopyMode("PageDown") },
        { key = "End",        mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "Home",       mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
        { key = "LeftArrow",  mods = "NONE",  action = act.CopyMode("MoveLeft") },
        -- { key = "LeftArrow",  mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
        { key = "RightArrow", mods = "NONE",  action = act.CopyMode("MoveRight") },
        -- { key = "RightArrow", mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
        { key = "UpArrow",    mods = "NONE",  action = act.CopyMode("MoveUp") },
        { key = "DownArrow",  mods = "NONE",  action = act.CopyMode("MoveDown") },
    },

    search_mode = {
        { key = "Enter",     mods = "NONE", action = act.CopyMode("PriorMatch") },
        { key = "Escape",    mods = "NONE", action = act.CopyMode("Close") },
        { key = "n",         mods = "CTRL", action = act.CopyMode("NextMatch") },
        { key = "p",         mods = "CTRL", action = act.CopyMode("PriorMatch") },
        { key = "r",         mods = "CTRL", action = act.CopyMode("CycleMatchType") },
        { key = "u",         mods = "CTRL", action = act.CopyMode("ClearPattern") },
        { key = "PageUp",    mods = "NONE", action = act.CopyMode("PriorMatchPage") },
        { key = "PageDown",  mods = "NONE", action = act.CopyMode("NextMatchPage") },
        { key = "UpArrow",   mods = "NONE", action = act.CopyMode("PriorMatch") },
        { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
    },
}

config.launch_menu = { zsh, powershell, arch }

config.leader = { key = "phys:s", mods = "CTRL|SHIFT", timeout_milliseconds = 1000 }

config.max_fps = 60

config.tab_max_width = 100

config.use_fancy_tab_bar = false

config.warn_about_missing_glyphs = false

config.webgpu_power_preference = "HighPerformance"

config.win32_system_backdrop = "Acrylic"

config.window_background_opacity = 0.6

config.window_close_confirmation = "NeverPrompt"

config.window_decorations = "RESIZE"

config.window_frame = {
    font = wezterm.font("Sarasa Mono SC Nerd Font", { weight = "Bold" }),
    font_size = 14.0,
}

config.window_padding = {
    left = 2,
    right = 2,
    top = 6,
    bottom = 0,
}

local function tab_title(tab_info, options)
    -- if the tab title is explicitly set, take that
    -- Otherwise, use the title from the active pane
    -- in that tab
    local title = tab_info.tab_title
    if not (title and #title > 0) then
        title = tab_info.active_pane.title
    end

    title = string.gsub(title, "\\", "/")

    if options["only_exe"] then
        local index = string.match(title, ".*()/")
        if index then
            title = string.sub(title, index + 1, #title)
        end
    end

    if options["remove_ext"] then
        local index = string.match(title, ".*()%.")
        if index then
            title = string.sub(title, 1, index - 1)
        end
    end

    if options["add_index"] then
        title = tostring(tab_info.tab_index + 1) .. "." .. title
    end

    return title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = true,
    })

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    local left = "  "
    local right = "  "
    title = wezterm.truncate_right(title, max_width - (#left + #right))

    return {
        { Text = left },
        { Text = title },
        { Text = right },
    }
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local zoomed = ""
    if tab.active_pane.is_zoomed then
        zoomed = "[Z] "
    end

    local index = ""
    if #tabs > 1 then
        index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end

    local title = tab_title(tab, {
        only_exe = true,
        remove_ext = true,
        add_index = false,
    })

    return zoomed .. index .. title
end)

return config

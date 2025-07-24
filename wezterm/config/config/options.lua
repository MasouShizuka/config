local wezterm = require("wezterm")

local custom = wezterm.color.get_builtin_schemes()["Tokyo Night Moon"]
custom.background = wezterm.color.get_builtin_schemes()["Windows 10 (base16)"].background

return {
    adjust_window_size_when_changing_font_size = false,
    animation_fps = 60,
    color_scheme = "custom",
    color_schemes = {
        ["custom"] = custom,
    },
    command_palette_font_size = 20.0,
    font = wezterm.font_with_fallback({
        {
            family = "Maple Mono NF CN",
            harfbuzz_features = { "+cv01", "+cv03", "+ss03" },
        },
        "Sarasa Mono SC",
    }),
    font_size = 17.0,
    hide_tab_bar_if_only_one_tab = true,
    initial_cols = 120,
    initial_rows = 30,
    tab_max_width = 100,
    use_fancy_tab_bar = false,
    warn_about_missing_glyphs = false,
    webgpu_power_preference = "HighPerformance",
    win32_system_backdrop = "Acrylic",
    window_background_opacity = 0.6,
    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",
    window_padding = {
        left = 2,
        right = 2,
        top = 0,
        bottom = 0,
    },
}

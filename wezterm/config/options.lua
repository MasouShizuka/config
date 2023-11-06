local wezterm = require("wezterm")

return {
    adjust_window_size_when_changing_font_size = false,
    initial_cols = 120,
    initial_rows = 30,

    animation_fps = 60,
    max_fps = 60,

    color_scheme = "Windows 10 (base16)",

    command_palette_font_size = 20.0,
    font = wezterm.font("Sarasa Mono SC Nerd Font"),
    font_size = 16.0,

    front_end = "WebGpu",
    webgpu_power_preference = "HighPerformance",

    hide_tab_bar_if_only_one_tab = true,
    tab_max_width = 100,
    use_fancy_tab_bar = false,

    warn_about_missing_glyphs = false,

    win32_system_backdrop = "Acrylic",
    window_background_opacity = 0.6,
    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",
    window_frame = {
        font = wezterm.font("Sarasa Mono SC Nerd Font", { weight = "Bold" }),
        font_size = 14.0,
    },
    window_padding = {
        left = 2,
        right = 2,
        top = 0,
        bottom = 0,
    },
}

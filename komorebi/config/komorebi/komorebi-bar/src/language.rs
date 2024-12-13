use crate::config::LabelPrefix;
use crate::render::RenderConfig;
use crate::widget::BarWidget;
use eframe::egui::text::LayoutJob;
use eframe::egui::Context;
use eframe::egui::FontId;
use eframe::egui::Label;
use eframe::egui::Sense;
use eframe::egui::TextFormat;
use eframe::egui::TextStyle;
use eframe::egui::Ui;
use schemars::JsonSchema;
use serde::Deserialize;
use serde::Serialize;
use windows::Win32::Globalization::GetLocaleInfoW;
use windows::Win32::Globalization::LOCALE_SISO3166CTRYNAME;
use windows::Win32::Globalization::LOCALE_SISO639LANGNAME;
use windows::Win32::UI::Input::KeyboardAndMouse::GetKeyboardLayout;
use windows::Win32::UI::WindowsAndMessaging::GetForegroundWindow;
use windows::Win32::UI::WindowsAndMessaging::GetWindowThreadProcessId;

#[derive(Copy, Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct LanguageConfig {
    /// Enable the Language widget
    pub enable: bool,
    /// Display label prefix
    pub label_prefix: Option<LabelPrefix>,
}

impl From<LanguageConfig> for Language {
    fn from(value: LanguageConfig) -> Self {
        Self {
            enable: value.enable,
            label_prefix: value.label_prefix.unwrap_or(LabelPrefix::Icon),
        }
    }
}

#[derive(Clone, Debug)]
pub struct Language {
    pub enable: bool,
    label_prefix: LabelPrefix,
}

impl Language {
    fn output(&mut self) -> String {
        let language_code;
        let country_code;

        unsafe {
            let hwnd = GetForegroundWindow();
            let thread_id = GetWindowThreadProcessId(hwnd, None);
            let hkl = GetKeyboardLayout(thread_id);
            let lang_id = hkl.0 as u32 & 0xFFFF;

            let mut lang_name = [0u16; 9];
            GetLocaleInfoW(lang_id, LOCALE_SISO639LANGNAME, Some(&mut lang_name));
            language_code =
                String::from_utf16(lang_name.split(|&x| x == 0u16).next().unwrap_or_default())
                    .unwrap_or_default();

            let mut country_name = [0u16; 9];
            GetLocaleInfoW(lang_id, LOCALE_SISO3166CTRYNAME, Some(&mut country_name));
            country_code = String::from_utf16(
                country_name
                    .split(|&x| x == 0u16)
                    .next()
                    .unwrap_or_default(),
            )
            .unwrap_or_default();

        };

        format!("{}-{}", language_code, country_code)
    }
}

impl BarWidget for Language {
    fn render(&mut self, ctx: &Context, ui: &mut Ui, config: &mut RenderConfig) {
        if self.enable {
            let mut output = self.output();
            if !output.is_empty() {
                let font_id = ctx
                    .style()
                    .text_styles
                    .get(&TextStyle::Body)
                    .cloned()
                    .unwrap_or_else(FontId::default);

                let mut layout_job = LayoutJob::simple(
                    match self.label_prefix {
                        LabelPrefix::Icon | LabelPrefix::IconAndText => egui_phosphor::regular::KEYBOARD.to_string(),
                        LabelPrefix::None | LabelPrefix::Text => String::new(),
                    },
                    font_id.clone(),
                    ctx.style().visuals.selection.stroke.color,
                    100.0,
                );

                if let LabelPrefix::Text | LabelPrefix::IconAndText = self.label_prefix {
                    output.insert_str(0, "IME: ");
                }

                layout_job.append(
                    &output,
                    10.0,
                    TextFormat::simple(font_id, ctx.style().visuals.text_color()),
                );

                config.apply_on_widget(true, ui, |ui| {
                    ui.add(
                        Label::new(layout_job)
                            .selectable(false)
                            .sense(Sense::click()),
                    );
                });
            }
        }
    }
}

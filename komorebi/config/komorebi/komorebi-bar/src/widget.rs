use crate::battery::Battery;
use crate::battery::BatteryConfig;
use crate::cpu::Cpu;
use crate::cpu::CpuConfig;
use crate::date::Date;
use crate::date::DateConfig;
use crate::komorebi::Komorebi;
use crate::komorebi::KomorebiConfig;
use crate::language::Language;
use crate::language::LanguageConfig;
use crate::media::Media;
use crate::media::MediaConfig;
use crate::memory::Memory;
use crate::memory::MemoryConfig;
use crate::network::Network;
use crate::network::NetworkConfig;
use crate::render::RenderConfig;
use crate::storage::Storage;
use crate::storage::StorageConfig;
use crate::time::Time;
use crate::time::TimeConfig;
use eframe::egui::Context;
use eframe::egui::Ui;
use schemars::JsonSchema;
use serde::Deserialize;
use serde::Serialize;

pub trait BarWidget {
    fn render(&mut self, ctx: &Context, ui: &mut Ui, config: &mut RenderConfig);
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum WidgetConfig {
    Battery(BatteryConfig),
    Cpu(CpuConfig),
    Date(DateConfig),
    Komorebi(KomorebiConfig),
    Language(LanguageConfig),
    Media(MediaConfig),
    Memory(MemoryConfig),
    Network(NetworkConfig),
    Storage(StorageConfig),
    Time(TimeConfig),
}

impl WidgetConfig {
    pub fn as_boxed_bar_widget(&self) -> Box<dyn BarWidget> {
        match self {
            WidgetConfig::Battery(config) => Box::new(Battery::from(*config)),
            WidgetConfig::Cpu(config) => Box::new(Cpu::from(*config)),
            WidgetConfig::Date(config) => Box::new(Date::from(config.clone())),
            WidgetConfig::Komorebi(config) => Box::new(Komorebi::from(config)),
            WidgetConfig::Language(config) => Box::new(Language::from(*config)),
            WidgetConfig::Media(config) => Box::new(Media::from(*config)),
            WidgetConfig::Memory(config) => Box::new(Memory::from(*config)),
            WidgetConfig::Network(config) => Box::new(Network::from(*config)),
            WidgetConfig::Storage(config) => Box::new(Storage::from(*config)),
            WidgetConfig::Time(config) => Box::new(Time::from(config.clone())),
        }
    }

    pub fn enabled(&self) -> bool {
        match self {
            WidgetConfig::Battery(config) => config.enable,
            WidgetConfig::Cpu(config) => config.enable,
            WidgetConfig::Date(config) => config.enable,
            WidgetConfig::Komorebi(config) => {
                config.workspaces.enable
                    || (if let Some(layout) = &config.layout {
                        layout.enable
                    } else {
                        false
                    })
                    || (if let Some(focused_window) = &config.focused_window {
                        focused_window.enable
                    } else {
                        false
                    })
                    || (if let Some(configuration_switcher) = &config.configuration_switcher {
                        configuration_switcher.enable
                    } else {
                        false
                    })
            }
            WidgetConfig::Language(config) => config.enable,
            WidgetConfig::Media(config) => config.enable,
            WidgetConfig::Memory(config) => config.enable,
            WidgetConfig::Network(config) => config.enable,
            WidgetConfig::Storage(config) => config.enable,
            WidgetConfig::Time(config) => config.enable,
        }
    }
}

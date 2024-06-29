# KeyMouse

**KeyMouse** is a program which works like the chrome plugin **vimium**, but is designed for other programs(like windows file browser).

![demo](https://i.imgur.com/HxaxNYu.gif)

## Installation

Download the zip file in release page and unzip it.

## Usage

- Select Mode: Show tags for ui items.
- Hint Mode: Show tags equidistantly on screen with `hintDistance`.
- Fast Select/Hint Mode: Repeat to hit tag until esc. This mode may fail in some situations.
- Right Click Prefix: If you hit `rightClickPrefix` before hitting tag, KeyMouse will simulate right click instead.
- Single Click Prefix: If you hit `singleClickPrefix` before hitting tag, KeyMouse will simulate single click instead.
- Double Click Prefix: If you hit `doubleClickPrefix` before hitting tag, KeyMouse will simulate double click instead.
- Escape: Exit select/hint mode.
- Toggle Enable: Enable/Disable the program.
- Force Not Use Cache: When `enableCache` is `true` and you're in `select mode`, force not use cache.

> if KeyMouse doesn't work, try to run as Administrator.

## Configuration

**KeyMouse** supports configuration for hot keys and profile.you can put your configuration in `config.json`(put in the path the same as `KeyMouse.exe`). there is a typical configuration:

```json
{
    "profile":
    {
        "runOnStartUp": true,
        "backgroundColor": "#CCFFCC",
        "fontColor": "#000000",
        "fontSize": 9,
        "font": "Arial Rounded MT Bold",
        "windowBkgdColor": "#CCBBAA",
        "windowFontColor": "#000000",
        "windowFontSize": 11,
        "windowFont": "Arial Rounded MT Bold",
        "opacity": 70,
        "invertClickType": false,
        "onlyForeWindow": true,
        "enableWindowSwitching": true,
        "enableCache": true,
        "showHintOnlyCurrentMonitor": true,
        "hintDistance": 60
    },
    "keybindings":
    {
        "toggleEnable": "alt+[",
        "forceNotUseCache": "space",
        "escape": "esc",
        "rightClickPrefix": "shift+a",
        "singleClickPrefix": "shift+s",
        "doubleClickPrefix": "shift+d",
        "selectModeSingle": "alt+;",
        "selectModeDouble": "alt+shift+;",
        "fastSelectMode": "alt+ctrl+;",
        "hintModeSingle": "alt+.",
        "hintModeDouble": "alt+shift+.",
        "fastHintMode": "alt+ctrl+."
    }
}
```

### options

The options of profile is listed below:

| Options                    | Type   | Default                 | Description                                                                                                                                                      |
| -------------------------- | ------ | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| runOnStartUp               | bool   | `false`                 | When this option is `true`, the app will be launched when windows starts up.                                                                                     |
| backgroundColor            | string | `#CCFFCC`               | The background color of hints. Use RGB format                                                                                                                    |
| fontColor                  | string | `#000000`               | The font color of hint. Use RGB format                                                                                                                           |
| fontSize                   | int    | `9`                     | The font size of hint.                                                                                                                                           |
| font                       | string | `Arial Rounded MT Bold` | The font type of hint. You can find the font name supported by your system through **Settings->Personalization->fonts**. Make sure to use the full name of font. |
| windowBkgdColor            | string | `#CCBBAA`               | This option is for switch window tag. Indicate the background color of switch window tag.                                                                        |
| windowFontColor            | string | `#000000`               | This option is for switch window tag. Indecate tor font color of switch window tag.                                                                              |
| windowFontSize             | int    | `11`                    | This option is for switch window tag.                                                                                                                            |
| windowFont                 | string | `Arial Rounded MT Bold` | this option is for switch window tag. Indecate the font type of switch window tag.                                                                               |
| opacity                    | int    | `70`                    | The opacity of tags. value is from 0-100.                                                                                                                        |
| invertClickType            | bool   | `false`                 | When it's true, KeyMouse will use right click as main click.                                                                                                     |
| onlyForeWindow             | bool   | `true`                  | When using multiple monitors, only enumerate hints on foreground window. If setting to false, It will try to enumerate windows on other monitors(might be slow.) |
| enableWindowSwitching      | bool   | `true`                  | Window switching feature may cause a high delay on some Windows versions.                                                                                        |
| enableCache                | bool   | `false`                 | (experimental) Try to cache the target window's hints when it's possible. (target window may be frozen if it's hint-intensive.)                                  |
| showHintOnlyCurrentMonitor | bool   | `true`                  | When using multiple monitors, only show tags on current monitor in hint mode.                                                                                    |
| hintDistance               | int    | `60`                    | The distance between tags in hint mode.                                                                                                                          |

The hot keys support `alt`, `shift`, `ctrl`, `win` and most keys on the keyboard. Please use lowercase and use `+` to connect different keys. some typical keybings: `alt+j`, `shift+alt+j`, `f11`. You can also use `disabled` to disable hot key.

The option of hot keys is listed below:

| Options           | Type   | Default       | Description                                                                                                                                                                           |
| ----------------- | ------ | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| toggleEnable      | string | `alt+[`       | Enable/Disable this app.                                                                                                                                                              |
| forceNotUseCache  | string | `space`       | When `enableCache` is `true` and you're in select mode. Hitting `forceNotUseCache` will retrieve hints directly instead of using cache.                                               |
| escape            | string | `esc`         | Leave select/hint mode.                                                                                                                                                               |
| rightClickPrefix  | string | `shift+a`     | When you're in select/hint mode. Hitting `rightClickPrefix` before hitting tag will simulate right click instead.                                                                     |
| singleClickPrefix | string | `shift+s`     | When you're in select/hint mode. Hitting `singleClickPrefix` before hitting tag will simulate single click instead.                                                                   |
| doubleClickPrefix | string | `shift+d`     | When you're in select/hint mode. Hitting `doubleClickPrefix` before hitting tag will simulate double click instead.                                                                   |
| selectModeSingle  | string | `alt+;`       | Enter select mode with default single click.                                                                                                                                          |
| selectModeDouble  | string | `alt+shift+;` | Enter select mode with default double click.                                                                                                                                          |
| fastSelectMode    | string | `alt+ctrl+;`  | Enter fast select mode. the difference between select mode and fast select mode is that FSM will continually enter select mode. may fail in some situations. Default is single click. |
| hintModeSingle    | string | `alt+.`       | Enter hint mode with default single click.                                                                                                                                            |
| hintModeDouble    | string | `alt+shift+.` | Enter hint mode with default double click.                                                                                                                                            |
| fastHintMode      | string | `alt+ctrl+.`  | Enter fast hint mode. the difference between hint mode and fast hint mode is that it will continually enter hint mode. Default is single click.                                       |

## Build

### Prerequisities

- require json lib from [nlohmann/json](https://github.com/nlohmann/json).
    - you can either add `--recurse-submodules` option when cloning this repo or get a copy from `nlohmann/json/single_include/nlohmann/json.hpp` to `/KeyMouse/KeyMouse/json/single_include/nlohmann/json.hpp`.

### Step

1. run `git clone --recurse-submodules https://github.com/iscooool/KeyMouse.git`.
2. Install Visual Studio and Import this project.
3. Ensure to build this project in x64.

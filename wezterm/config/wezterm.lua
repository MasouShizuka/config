local wezterm = require("wezterm")

local config
if wezterm.config_builder then
    config = wezterm.config_builder()
else
    config = {}
end

local function apply_to_config(options)
    for k, v in pairs(options) do
        if config[k] ~= nil then
            wezterm.log_warn(
                "Duplicate config option detected: ",
                { old = config[k], new = options[k] }
            )
        end

        config[k] = v
    end
end

apply_to_config(require("config.options"))
apply_to_config(require("config.keybindings"))
apply_to_config(require("config.launching_programs").options)

require("config.events")

return config

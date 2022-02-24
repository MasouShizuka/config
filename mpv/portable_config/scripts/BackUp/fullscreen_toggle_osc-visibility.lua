mp.observe_property("fullscreen", "bool", function (_, val)
    mp.commandv("script-message", "osc-visibility", val and "auto" or "always")
end)

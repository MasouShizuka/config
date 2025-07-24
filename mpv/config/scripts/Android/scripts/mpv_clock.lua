-- Shows the current OS time in the OSD
-- Pressing 'c' shows it for 5 seconds, and pressing 'C' (Shift+C) toggles it on indefinitely until you toggle it off again.
-- Created by Yuto Takano, inspired by blue-sky-r/mpv.git
-- Edit the cfg below to change the key-bindings, date format, and duration.

local cfg = {
    format    = "%H:%M",
    duration  = 5,
    key       = "c",
    togglekey = "C",
}

-- global clock show state variable
local is_shown = false
-- global osd timer variable
local osd_timer = nil

-- Simply show clock for the desired duration
local function osd_clock()
    local s = os.date(cfg.format)
    mp.osd_message(s, cfg.duration)
    collectgarbage()
    collectgarbage()
end

-- Similar to the above, but is called by the periodic_timer
local function osd_clock_timer()
    -- do not run if toggled off. Shouldn't be called since periodic_timer is stop()-ed but just in case.
    if is_shown then
        local s = os.date(cfg.format)
        -- show time for 1 second
        mp.osd_message(s, 1)
    end
    collectgarbage()
    collectgarbage()
end

local function osd_clock_toggle()
    is_shown = not is_shown

    -- make sure timer is defined (n>1 th toggle)
    if osd_timer ~= nil then
        if is_shown then
            osd_timer:resume()
        else
            osd_timer:stop()
        end
    else
        -- otherwise create a timer to call the clock on every second
        osd_clock_timer()
        osd_timer = mp.add_periodic_timer(1, osd_clock_timer)
    end
end

-- mp.add_key_binding(cfg.key, 'show-clock', osd_clock)
-- mp.msg.verbose("key:'"..cfg.key.."' bound to 'show-clock'")
-- mp.add_key_binding(cfg.togglekey, 'toggle-clock', osd_clock_toggle)
-- mp.msg.verbose("key:'"..cfg.togglekey.."' bound to 'toggle-clock'")

mp.register_script_message("show-clock", osd_clock)
mp.register_script_message("toggle-clock", osd_clock_toggle)

osd_clock_toggle()

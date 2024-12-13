local multi_subtitles_info = {}

function multi_subtitles_clear()
    for _, value in ipairs(multi_subtitles_info) do
        mp.command(value.remove_command)
    end

    multi_subtitles_info = {}
end

function multi_subtitles_exist(id)
    for index, value in ipairs(multi_subtitles_info) do
        if value.id == id then
            return true, index
        end
    end

    return false, -1
end

function multi_subtitles_update(id, vf)
    local is_exist, index = multi_subtitles_exist(id)
    if is_exist then
        table.remove(multi_subtitles_info, index)
    else
        multi_subtitles_info[#multi_subtitles_info + 1] = {
            id = id,
            remove_command = "vf remove" .. vf,
        }
    end
end

function multi_subtitles_toggle(id)
    if type(id) == "string" then
        id = tonumber(id)
    end

    if id == 0 then
        multi_subtitles_clear()
    else
        for _, track in ipairs(mp.get_property_native("track-list")) do
            local is_exist, _ = multi_subtitles_exist(id)
            local vf1 = ""
            if is_exist then
                vf1 = "remove"
            else
                vf1 = "append"
            end

            if track.type == "sub" and track.id == id then
                if not track.external then
                    local path = mp.get_property_native("path")
                    local vf2 = " ``subtitles=filename=\"" .. path .. "\":stream_index=" .. id - 1 .. "``"
                    local vf = "vf " .. vf1 .. vf2
                    mp.command(vf)

                    multi_subtitles_update(id, vf2)
                else
                    local path = track["external-filename"]
                    local vf2 = " ``subtitles=filename=\"" .. path .. "\"``"
                    local vf = "vf " .. vf1 .. vf2
                    mp.command(vf)

                    multi_subtitles_update(id, vf2)
                end
            end
        end
    end
end

mp.register_script_message("multi_subtitles_toggle", multi_subtitles_toggle)

function multi_subtitles_menu()
    local utils = require("mp.utils")

    local items = {}
    items[#items + 1] = {
        title = "Clear",
        italic = true,
        muted = true,
        value = { "script-message-to", "multi_subtitles", "multi_subtitles_toggle", 0 },
    }
    for _, track in ipairs(mp.get_property_native("track-list")) do
        if track.type == "sub" then
            items[#items + 1] = {
                title = (track.title and track.title or "Track " .. track.id),
                hint = track.lang and track.lang:upper() or nil,
                value = { "script-message-to", "multi_subtitles", "multi_subtitles_toggle", track.id },
                external = track.external,
                external_path = track["external-filename"],
            }
        end
    end
    local menu = {
        type = "sub",
        title = "Multi-Subtitles",
        items = items,
    }

    local json = utils.format_json(menu)
    mp.commandv("script-message-to", "uosc", "open-menu", json)
end

mp.add_key_binding(nil, "multi-subtitles-menu", multi_subtitles_menu)

function multi_subtitles_recovery()
    local info = multi_subtitles_info
    multi_subtitles_clear()

    for _, value in ipairs(info) do
        multi_subtitles_toggle(value.id)
    end
end

mp.register_event("file-loaded", function()
    multi_subtitles_recovery()
end)

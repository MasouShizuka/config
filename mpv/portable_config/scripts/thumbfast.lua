--[[
SOURCE_ https://github.com/po5/thumbfast/commit/0017ff006951d910dd572d02804b0d6dc20cd200

适配多个OSC类脚本的新缩略图引擎
]]--

local options = {

    socket = "",           -- Socket path (leave empty for auto)
    tnpath = "",           -- 缩略图缓存路径（确保目录真实存在），留空即自动

    max_height = 300,      -- Maximum thumbnail size in pixels (scaled down to fit) Values are scaled when hidpi is enabled
    max_width = 300,
    max_thumbs = 1440,     -- 最大缩略图数量

    overlay_id = 42,       -- Overlay id

    spawn_first = false,   -- Spawn thumbnailer on file load for faster initial thumbnails
    network = false,       -- Enable on network playback
    audio = false,         -- Enable on audio playback

    precise = true,        -- 启用高精度的预览
    hwdec = true,          -- 启用硬解加速

}

mp.utils = require "mp.utils"
mp.options = require "mp.options"
mp.options.read_options(options)

local os_name = ""

math.randomseed(os.time())
local unique = math.random(10000000)
local init = false

local spawned = false
local can_generate = true
local network = false
local disabled = false
local interval = 0

local x = nil
local y = nil
local last_x = x
local last_y = y

local last_index = nil
local last_request = nil
local last_request_time = nil
local last_display_time = 0

local effective_w = options.max_width
local effective_h = options.max_height
local thumb_size = effective_w * effective_h * 4

local function get_os()
    local raw_os_name = ""

    if jit and jit.os and jit.arch then
        raw_os_name = jit.os
    else
        if package.config:sub(1,1) == "\\" then
            -- Windows
            local env_OS = os.getenv("OS")
            if env_OS then
                raw_os_name = env_OS
            end
        else
            raw_os_name = mp.command_native({name = "subprocess", playback_only = false, capture_stdout = true, args = {"uname", "-s"}}).stdout
        end
    end

    raw_os_name = (raw_os_name):lower()

    local os_patterns = {
        ["windows"] = "Windows",

        -- Uses socat
        ["linux"]   = "Linux",

        ["osx"]     = "Mac",
        ["mac"]     = "Mac",
        ["darwin"]  = "Mac",

        ["^mingw"]  = "Windows",
        ["^cygwin"] = "Windows",

        -- Because they have the good netcat (with -U)
        ["bsd$"]    = "Mac",
        ["sunos"]   = "Mac"
    }

    -- Default to linux
    local str_os_name = "Linux"

    for pattern, name in pairs(os_patterns) do
        if raw_os_name:match(pattern) then
            str_os_name = name
            break
        end
    end

    return str_os_name
end

local function calc_dimensions()
    local width = mp.get_property_number("video-out-params/dw")
    local height = mp.get_property_number("video-out-params/dh")
    if not width or not height then return end

    local scale = mp.get_property_number("display-hidpi-scale", 1)

    if width / height > options.max_width / options.max_height then
        effective_w = math.floor(options.max_width * scale + 0.5)
        effective_h = math.floor(height / width * effective_w + 0.5)
    else
        effective_h = math.floor(options.max_height * scale + 0.5)
        effective_w = math.floor(width / height * effective_h + 0.5)
    end

    thumb_size = effective_w * effective_h * 4
end

local function info()
    local display_w, display_h = effective_w, effective_h

    local json, err = mp.utils.format_json({width=display_w, height=display_h, disabled=disabled, socket=options.socket, tnpath=options.tnpath, overlay_id=options.overlay_id})
    mp.commandv("script-message", "thumbfast-info", json)
end

local function remove_thumbnail_files()
    os.remove(options.tnpath)
    os.remove(options.tnpath..".bgra")
end

local function spawn(time)
    if disabled then return end

    local path = mp.get_property("path")
    if path == nil then return end

    spawned = true

    local open_filename = mp.get_property("stream-open-filename")
    local ytdl = open_filename and network and path ~= open_filename
    if ytdl then
        path = open_filename
    end

    if os_name == "" then
        os_name = get_os()
    end

    if options.socket == "" then
        if os_name == "Windows" then
            options.socket = "thumbfast"
        elseif os_name == "Mac" then
            options.socket = "/tmp/thumbfast"
        else
            options.socket = "/tmp/thumbfast"
        end
    end

    if options.tnpath == "" then
        if os_name == "Windows" then
            options.tnpath = os.getenv("TEMP").."\\thumbfast.out"
        elseif os_name == "Mac" then
            options.tnpath = "/tmp/thumbfast.out"
        else
            options.tnpath = "/tmp/thumbfast.out"
        end
    end

    if not init then
        -- ensure uniqueness
        options.socket = options.socket .. unique
        options.tnpath = options.tnpath .. unique
        init = true
    end

    remove_thumbnail_files()

    calc_dimensions()

    info()

    local mpv_hwdec = "no"
    if options.hwdec then mpv_hwdec = "auto" end
    mp.command_native_async(
        {name = "subprocess", playback_only = true, args = {
            "mpv", path, "--config=no", "--terminal=no", "--msg-level=all=no", "--idle=yes", "--keep-open=always","--pause=yes", "--ao=null", "--vo=null",
            "--load-auto-profiles=no", "--load-osd-console=no", "--load-stats-overlay=no", "--osc=no",
            "--vd-lavc-skiploopfilter=all", "--vd-lavc-software-fallback=1", "--vd-lavc-fast","--hwdec="..mpv_hwdec, 
            "--edition="..(mp.get_property_number("edition") or "auto"), "--vid="..(mp.get_property_number("vid") or "auto"), "--sub=no", "--audio=no", "--sub-auto=no", "--audio-file-auto=no",
            "--input-ipc-server="..options.socket,
            "--start="..time,
            "--ytdl-format=worst", "--demuxer-readahead-secs=0", "--demuxer-max-bytes=128KiB",
            "--gpu-dumb-mode=yes", "--tone-mapping=clip", "--hdr-compute-peak=no",
            "--sws-scaler=point", "--sws-fast=yes", "--sws-allow-zimg=no",
            "--audio-pitch-correction=no",
            "--vf=".."scale=w="..effective_w..":h="..effective_h..":flags=neighbor,format=bgra",
            "--ovc=rawvideo", "--of=image2", "--ofopts=update=1", "--o="..options.tnpath
        }},
        function() end
    )
end

local function run(command, callback)
    if not spawned then return end

    callback = callback or function() end

    local seek_command
    if os_name == "Windows" then
        seek_command = {"cmd", "/c", "echo "..command.." > \\\\.\\pipe\\" .. options.socket}
    elseif os_name == "Mac" then
        -- this doesn't work, on my system. not sure why.
        seek_command = {"/usr/bin/env", "sh", "-c", "echo '"..command.."' | nc -w0 -U " .. options.socket}
    else
        seek_command = {"/usr/bin/env", "sh", "-c", "echo '" .. command .. "' | socat - " .. options.socket}
    end

    mp.command_native_async(
        {name = "subprocess", playback_only = true, capture_stdout = true, args = seek_command},
        callback
    )
end

local function thumb_index(thumbtime)
    return math.floor(thumbtime / interval)
end

local function index_time(index, thumbtime)
    if interval > 0 then
        local time = index * interval
        return time + interval / 3
    else
        return thumbtime
    end
end

local function draw(w, h, thumbtime, display_time, script)
    local display_w, display_h = w, h

    if x ~= nil then
        mp.command_native(
            {name = "overlay-add", id=options.overlay_id, x=x, y=y, file=options.tnpath..".bgra", offset=0, fmt="bgra", w=display_w, h=display_h, stride=(4*display_w)}
        )
    elseif script then
        local json, err = mp.utils.format_json({width=display_w, height=display_h, x=x, y=y, socket=options.socket, tnpath=options.tnpath, overlay_id=options.overlay_id})
        mp.commandv("script-message-to", script, "thumbfast-render", json)
    end
end

local function display_img(w, h, thumbtime, display_time, script, redraw)
    if last_display_time > display_time or disabled then return end

    if not redraw then
        can_generate = false

        local info = mp.utils.file_info(options.tnpath)
        if not info or info.size ~= thumb_size then
            if thumbtime == -1 then
                can_generate = true
                return
            end

            if thumbtime < 0 then
                thumbtime = thumbtime + 1
            end

            -- display last successful thumbnail if one exists
            local info2 = mp.utils.file_info(options.tnpath..".bgra")
            if info2 and info2.size == thumb_size then
                draw(w, h, thumbtime, display_time, script)
            end

            -- retry up to 5 times
            return mp.add_timeout(0.05, function() display_img(w, h, thumbtime < 0 and thumbtime or -5, display_time, script) end)
        end

        if last_display_time > display_time then return end

        -- os.rename can't replace files on windows
        if os_name == "Windows" then
            os.remove(options.tnpath..".bgra")
        end
        -- move the file because it can get overwritten while overlay-add is reading it, and crash the player
        os.rename(options.tnpath, options.tnpath..".bgra")

        last_display_time = display_time
    else
        local info = mp.utils.file_info(options.tnpath..".bgra")
        if not info or info.size ~= thumb_size then
            -- still waiting on intial thumbnail
            return mp.add_timeout(0.05, function() display_img(w, h, thumbtime, display_time, script) end)
        end
        if not can_generate then
            return draw(w, h, thumbtime, display_time, script)
        end
    end

    draw(w, h, thumbtime, display_time, script)

    can_generate = true

    if not redraw then
        -- often, the file we read will be the last requested thumbnail
        -- retry after a small delay to ensure we got the latest image
        if thumbtime ~= -1 then
            mp.add_timeout(0.05, function() display_img(w, h, -1, display_time, script) end)
            mp.add_timeout(0.1, function() display_img(w, h, -1, display_time, script) end)
        end
    end
end

local function thumb(time, r_x, r_y, script)
    if disabled then return end

    time = tonumber(time)
    if time == nil then return end

    if r_x == nil or r_y == nil then
        x, y = nil, nil
    else
        x, y = math.floor(r_x + 0.5), math.floor(r_y + 0.5)
    end

    local index = thumb_index(time)
    local seek_time = index_time(index, time)

    if last_request == seek_time or (interval > 0 and index == last_index) then
        last_index = index
        if x ~= last_x or y ~= last_y then
            last_x, last_y = x, y
            display_img(effective_w, effective_h, time, mp.get_time(), script, true)
        end
        return
    end

    local cur_request_time = mp.get_time()

    last_index = index
    last_request_time = cur_request_time
    last_request = seek_time

    if not spawned then
        spawn(seek_time)
        if can_generate then
            display_img(effective_w, effective_h, time, cur_request_time, script)
            mp.add_timeout(0.15, function() display_img(effective_w, effective_h, time, cur_request_time, script) end)
            end
        return
    end

    local seek_flag = "absolute"
    if not options.precise then seek_flag = seek_flag.."-percent" end
    run("async seek "..seek_time.." "..seek_flag, function() if can_generate then display_img(effective_w, effective_h, time, cur_request_time, script) end end)
end

local function clear()
    last_display_time = mp.get_time()
    can_generate = true
    last_x = nil
    last_y = nil
    mp.command_native(
        {name = "overlay-remove", id=options.overlay_id}
    )
end

local function watch_changes()
    local old_w = effective_w
    local old_h = effective_h

    calc_dimensions()

    if spawned then
        if old_w ~= effective_w or old_h ~= effective_h then
            -- mpv doesn't allow us to change output size
            run("quit")
            clear()
            info()
            spawned = false
            spawn(last_request or mp.get_property_number("time-pos", 0))
        end
    else
        if old_w ~= effective_w or old_h ~= effective_h then
            info()
        end
    end
end

local function sync_changes(prop, val)
    if spawned and val then
        run("set "..prop.." "..val)
    end
end

local function file_load()
    clear()

    network = mp.get_property_bool("demuxer-via-network", false)
    local image = mp.get_property_native('current-tracks/video/image', true)
    local albumart = image and mp.get_property_native("current-tracks/video/albumart", false)

    disabled = (network and not options.network) or (albumart and not options.audio) or (image and not albumart)
    info()
    if disabled then return end

    interval = math.min(math.max(mp.get_property_number("duration", 1) / options.max_thumbs, 0), mp.get_property_number("duration", 0) / 2)

    spawned = false
    if options.spawn_first then spawn(mp.get_property_number("time-pos", 0)) end
end

local function shutdown()
    run("quit")
    remove_thumbnail_files()
    os.remove(options.socket)
end

mp.observe_property("display-hidpi-scale", "native", watch_changes)
mp.observe_property("video-out-params", "native", watch_changes)
mp.observe_property("vid", "native", sync_changes)
mp.observe_property("edition", "native", sync_changes)

mp.register_script_message("thumb", thumb)
mp.register_script_message("clear", clear)

mp.register_event("file-loaded", file_load)
mp.register_event("shutdown", shutdown)

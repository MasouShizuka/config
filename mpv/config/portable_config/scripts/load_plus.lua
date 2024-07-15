--[[
SOURCE_ https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua
COMMIT_ a1caa001870985f36ae3c0082181e4e708ebdd73
SOURCE_ https://github.com/rossy/mpv-open-file-dialog/blob/master/open-file-dialog.lua
COMMIT_ 04fe818fc703d8c5dcc3a6aabe1caeed8286bdbb
文档_ https://github.com/hooke007/MPV_lazy/discussions/106

功能集一：
  列表文件数量为1时自动填充同目录下的其它文件。

功能集二：
  自定义快捷键 在mpv中唤起一个打开文件的窗口用于快速加载文件/网址。

可用的快捷键示例（在 input.conf 中写入）：
 <KEY>   script-binding load_plus/import_files   # 打开文件
 <KEY>   script-binding load_plus/import_url     # 打开地址
 <KEY>   script-binding load_plus/append_aid     # 追加其它音轨（不切换）
 <KEY>   script-binding load_plus/append_sid     # 追加其它字幕（切换）

]]

local msg = require "mp.msg"
local options = require "mp.options"
local utils = require "mp.utils"

opt = {
	level = 1,                  -- <0|1|2|3>
	video = true,
	video_ext = "default",
	audio = false,
	audio_ext = "default",
	image = false,
	image_ext = "default",
	skip_hidden = true,
	max_entries = 150,
	directory_mode = "ignore",
	ignore_pattern = "$^",
}
options.read_options(opt)

MAXDIRSTACK = 20

--
-- 单文件时自动补充队列
--

function Set (t)
	local set = {}
	for _, v in pairs(t) do set[v] = true end
	return set
end

function SetUnion (a,b)
	for k in pairs(b) do a[k] = true end
	return a
end

if opt.video_ext ~= "default" then
	local video_ext_tab = {}
	for x in opt.video_ext:gmatch("[^,]+") do
		table.insert(video_ext_tab, x)
	end
	EXTENSIONS_VIDEO = Set (video_ext_tab)
else
	EXTENSIONS_VIDEO = Set {
		"3g2","3gp",
		"amv","asf","avi",
		"f4v","flv",
		"m2ts","m4v","mkv","mov","mp4","mpeg","mpg",
		"ogv",
		"rm","rmvb",
		"ts",
		"vob",
		"webm","wmv",
		"y4m" }
end

if opt.audio_ext ~= "default" then
	local audio_ext_tab = {}
	for x in opt.audio_ext:gmatch("[^,]+") do
		table.insert(audio_ext_tab, x)
	end
	EXTENSIONS_AUDIO = Set (audio_ext_tab)
else
	EXTENSIONS_AUDIO = Set {
		"aac","aiff","alac","ape","au",
		"dsf",
		"flac",
		"m4a","mp3",
		"oga","ogg","ogm","opus",
		"tak","tta",
		"wav","wma","wv" }
end

if opt.image_ext ~= "default" then
	local image_ext_tab = {}
	for x in opt.image_ext:gmatch("[^,]+") do
		table.insert(image_ext_tab, x)
	end
	EXTENSIONS_IMAGE = Set (image_ext_tab)
else
	EXTENSIONS_IMAGE = Set {
		"apng","avif",
		"bmp",
		"gif",
		"j2k", "jfif","jp2","jpeg","jpg",
		"png",
		"svg",
		"tga","tif","tiff",
		"uci",
		"webp" }
end

EXTENSIONS = Set {}
if opt.video then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_VIDEO) end
if opt.audio then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_AUDIO) end
if opt.image then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_IMAGE) end

function validate_directory_mode()
	if opt.directory_mode ~= "recursive" and opt.directory_mode ~= "lazy" and opt.directory_mode ~= "ignore" then
		opt.directory_mode = nil
	end
end
validate_directory_mode()

function add_files(files)
	local oldcount = mp.get_property_number("playlist-count", 1)
	for i = 1, #files do
		mp.commandv("loadfile", files[i][1], "append")
		mp.commandv("playlist-move", oldcount + i - 1, files[i][2])
	end
end

function get_extension(path)
	match = string.match(path, "%.([^%.]+)$" )
	if match == nil then
		return "nomatch"
	else
		return match
	end
end

table.filter = function(t, iter)
	for i = #t, 1, -1 do
		if not iter(t[i]) then
			table.remove(t, i)
		end
	end
end

table.append = function(t1, t2)
	local t1_size = #t1
	for i = 1, #t2 do
		t1[t1_size + i] = t2[i]
	end
end

-- port https://github.com/mpvnet-player/mpv.net/issues/575#issuecomment-1817413401
-- https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmplogicalw
local winapi = {}
local is_windows = mp.get_property_native("platform") == "windows"

if is_windows then
	-- port https://github.com/po5/thumbfast/blob/8498a34b594578a8b5ddd38c8c2ba20023638fc0/thumbfast.lua#L81
	local is_ffi_loaded, ffi = pcall(require, "ffi")
	if is_ffi_loaded then
		winapi = {
			ffi = ffi,
			C = ffi.C,
			CP_UTF8 = 65001,
			shlwapi = ffi.load("shlwapi"),
		}

		ffi.cdef[[
			int __stdcall MultiByteToWideChar(unsigned int CodePage, unsigned long dwFlags, const char *lpMultiByteStr,
			int cbMultiByte, wchar_t *lpWideCharStr, int cchWideChar);
			int __stdcall StrCmpLogicalW(wchar_t *psz1, wchar_t *psz2);
		]]

		winapi.utf8_to_wide = function(utf8_str)
			if utf8_str then
				local utf16_len = winapi.C.MultiByteToWideChar(winapi.CP_UTF8, 0, utf8_str, -1, nil, 0)
				if utf16_len > 0 then
					local utf16_str = winapi.ffi.new("wchar_t[?]", utf16_len)
					if winapi.C.MultiByteToWideChar(winapi.CP_UTF8, 0, utf8_str, -1, utf16_str, utf16_len) > 0 then
						return utf16_str
					end
				end
			end
			return ""
		end
	end
end

function alphanumsort_windows(filenames)
	table.sort(filenames, function(a, b)
		local a_wide = winapi.utf8_to_wide(a)
		local b_wide = winapi.utf8_to_wide(b)
		return winapi.shlwapi.StrCmpLogicalW(a_wide, b_wide) == -1
	end)
	return filenames
end

-- alphanum sorting for humans in Lua
-- http://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua

function alphanumsort_lua(filenames)
	local function padnum(n, d)
		return #d > 0 and ("%03d%s%.12f"):format(#n, n, tonumber(d) / (10 ^ #d))
			or ("%03d%s"):format(#n, n)
	end

	local tuples = {}
	for i, f in ipairs(filenames) do
		tuples[i] = {f:lower():gsub("0*(%d+)%.?(%d*)", padnum), f}
	end
	table.sort(tuples, function(a, b)
		return a[1] == b[1] and #b[2] < #a[2] or a[1] < b[1]
	end)
	for i, tuple in ipairs(tuples) do filenames[i] = tuple[2] end
	return filenames
end

function alphanumsort(filenames)
	local is_ffi_loaded = pcall(require, "ffi")
	if is_windows and is_ffi_loaded then
		alphanumsort_windows(filenames)
	else
		alphanumsort_lua(filenames)
	end
end

local autoloaded = nil
local added_entries = {}
local autoloaded_dir = nil

function scan_dir(path, current_file, dir_mode, separator, dir_depth, total_files, extensions)
	if dir_depth == MAXDIRSTACK then
		return
	end
	msg.trace("scanning: " .. path)
	local files = utils.readdir(path, "files") or {}
	local dirs = dir_mode ~= "ignore" and utils.readdir(path, "dirs") or {}
	local prefix = path == "." and "" or path
	table.filter(files, function (v)
		-- The current file could be a hidden file, ignoring it doesn't load other
		-- files from the current directory.
		local current = prefix .. v == current_file
		if (opt.skip_hidden and not current and string.match(v, "^%.")) then
			return false
		end
		if (not current and string.match(v, opt.ignore_pattern)) then
			return false
		end

		local ext = get_extension(v)
		if ext == nil then
			return false
		end

	if opt.level == 3 then
		local name = mp.get_property("filename")
		local namepre = string.sub(name, 1, 6)
		local namepre0 = string.gsub(namepre, "%p", "%%%1")
		for ext, _ in pairs(EXTENSIONS) do
			if string.match(name, ext.."$") ~= nil then
				if string.match(v, "^"..namepre0) == nil then
				return false
				end
			end
		end
	end

		return extensions[string.lower(ext)]
	end)

	table.filter(dirs, function(d)
		return not ((opt.skip_hidden and string.match(d, "^%.")))
	end)
	alphanumsort(files)
	alphanumsort(dirs)

	for i, file in ipairs(files) do
		files[i] = prefix .. file
	end

	table.append(total_files, files)
	if dir_mode == "recursive" then
		for _, dir in ipairs(dirs) do
			scan_dir(prefix .. dir .. separator, current_file, dir_mode,
						separator, dir_depth + 1, total_files, extensions)
		end
	else
		for i, dir in ipairs(dirs) do
			dirs[i] = prefix .. dir
		end
		table.append(total_files, dirs)
	end
end

function find_and_add_entries()
	local aborted = mp.get_property_native("playback-abort")
	if aborted then
		msg.verbose("自动队列中止：播放中止")
		return
	end

	local path = mp.get_property("path", "")
	local dir, filename = utils.split_path(path)
	msg.trace(("dir: %s, filename: %s"):format(dir, filename))
	if opt.level == 0 then
		msg.verbose("自动队列中止：功能已禁用")
		return
	elseif #dir == 0 then
		msg.warn("自动队列中止：非本地路径")
		return
	end

	local pl_count = mp.get_property_number("playlist-count", 1)
	this_ext = get_extension(filename)
	-- check if this is a manually made playlist
	if (pl_count > 1 and autoloaded == nil) or
		(pl_count == 1 and EXTENSIONS[string.lower(this_ext)] == nil) then
		msg.warn("自动队列中止：已手动创建/修改播放列表")
		return
	else
		if pl_count == 1 then
			autoloaded = true
			autoloaded_dir = dir
			added_entries = {}
		end
	end

	local extensions = {}
	if opt.level == 2 then
		if EXTENSIONS_VIDEO[string.lower(this_ext)] ~= nil then
			extensions = EXTENSIONS_VIDEO
		elseif EXTENSIONS_AUDIO[string.lower(this_ext)] ~= nil then
			extensions = EXTENSIONS_AUDIO
		else
			extensions = EXTENSIONS_IMAGE
		end
	else
		extensions = EXTENSIONS
	end

	local pl = mp.get_property_native("playlist", {})
	local pl_current = mp.get_property_number("playlist-pos-1", 1)
	msg.trace(("playlist-pos-1: %s, playlist: %s"):format(pl_current,
		utils.to_string(pl)))

	local files = {}
	do
		local dir_mode = opt.directory_mode or mp.get_property("directory-mode", "lazy")
		local separator = mp.get_property_native("platform") == "windows" and "\\" or "/"
		scan_dir(autoloaded_dir, path, dir_mode, separator, 0, files, extensions)
	end

	if next(files) == nil then
		msg.info("当前路径下无其它文件或子文件夹")
		return
	end

	-- Find the current pl entry (dir+"/"+filename) in the sorted dir list
	local current
	for i = 1, #files do
		if files[i] == path then
			current = i
			break
		end
	end
	if current == nil then
		return
	end
	msg.trace("自动队列：当前文件所处序列 "..current)

	-- treat already existing playlist entries, independent of how they got added
	-- as if they got added by autoload
	for _, entry in ipairs(pl) do
		added_entries[entry.filename] = true
	end

	local append = {[-1] = {}, [1] = {}}
	for direction = -1, 1, 2 do -- 2 iterations, with direction = -1 and +1
		for i = 1, opt.max_entries do
			local pos = current + i * direction
			local file = files[pos]
			if file == nil or file[1] == "." then
				break
			end

			-- skip files that are/were already in the playlist
			if not added_entries[file] then
				if direction == -1 then
					msg.info("自动队列 追加（前）" .. file)
					table.insert(append[-1], 1, {file, pl_current + i * direction + 1})
				else
					msg.info("自动队列 追加（后）" .. file)
					if pl_count > 1 then
						table.insert(append[1], {file, pl_current + i * direction - 1})
					else
						mp.commandv("loadfile", file, "append")
					end
				end
			end
			added_entries[file] = true
		end
		if pl_count == 1 and direction == -1 and #append[-1] > 0 then
			for i = 1, #append[-1] do
				mp.commandv("loadfile", append[-1][i][1], "append")
			end
			mp.commandv("playlist-move", 0, current)
		end
	end

	if pl_count > 1 then
		add_files(append[1])
		add_files(append[-1])
	end
end


--
-- 弹出对话框加载文件
--

function import_files()
	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end
	local res = utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', [[& {
			Trap {
				Write-Error -ErrorRecord $_
				Exit 1
			}
			Add-Type -AssemblyName PresentationFramework
			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()
			$ofd = New-Object -TypeName Microsoft.Win32.OpenFileDialog
			$ofd.Multiselect = $true
			If ($ofd.ShowDialog() -eq $true) {
				ForEach ($filename in $ofd.FileNames) {
					$u8filename = $u8.GetBytes("$filename`n")
					$out.Write($u8filename, 0, $u8filename.Length)
				}
			}
		}]]},
		cancellable = false,
	})
	if was_ontop then mp.set_property_native("ontop", true) end
	if (res.status ~= 0) then return end
	local first_file = true
	for filename in string.gmatch(res.stdout, '[^\n]+') do
		mp.commandv("loadfile", filename, first_file and "replace" or "append")
		first_file = false
	end
end

function import_url()
	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end
	local res = utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', [[& {
			Trap {
				Write-Error -ErrorRecord $_
				Exit 1
			}
			Add-Type -AssemblyName Microsoft.VisualBasic
			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()
			$urlname = [Microsoft.VisualBasic.Interaction]::InputBox("输入地址", "打开", "https://")
			$u8urlname = $u8.GetBytes("$urlname")
			$out.Write($u8urlname, 0, $u8urlname.Length)
		}]]},
		cancellable = false,
	})
	if was_ontop then mp.set_property_native("ontop", true) end
	if (res.status ~= 0) then return end
	mp.commandv("loadfile", res.stdout)
end

function append_aid()
	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end
	local res = utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', [[& {
			Trap {
				Write-Error -ErrorRecord $_
				Exit 1
			}
			Add-Type -AssemblyName PresentationFramework
			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()
			$ofd = New-Object -TypeName Microsoft.Win32.OpenFileDialog
			$ofd.Multiselect = $false
			If ($ofd.ShowDialog() -eq $true) {
				ForEach ($filename in $ofd.FileNames) {
					$u8filename = $u8.GetBytes("$filename")
					$out.Write($u8filename, 0, $u8filename.Length)
				}
			}
		}]]},
		cancellable = false,
	})
	if was_ontop then mp.set_property_native("ontop", true) end
	if (res.status ~= 0) then return end
	for filename in string.gmatch(res.stdout, '[^\n]+') do
		mp.commandv("audio-add", filename, "auto")
	end
end

function append_sid()
	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end
	local res = utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', [[& {
			Trap {
				Write-Error -ErrorRecord $_
				Exit 1
			}
			Add-Type -AssemblyName PresentationFramework
			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()
			$ofd = New-Object -TypeName Microsoft.Win32.OpenFileDialog
			$ofd.Multiselect = $false
			If ($ofd.ShowDialog() -eq $true) {
				ForEach ($filename in $ofd.FileNames) {
					$u8filename = $u8.GetBytes("$filename")
					$out.Write($u8filename, 0, $u8filename.Length)
				}
			}
		}]]},
		cancellable = false,
	})
	if was_ontop then mp.set_property_native("ontop", true) end
	if (res.status ~= 0) then return end
	for filename in string.gmatch(res.stdout, '[^\n]+') do
		mp.commandv("sub-add", filename, "cached")
	end
end



mp.register_event("end-file", remove_vfSub)

mp.register_event("start-file", find_and_add_entries)

mp.add_key_binding(nil, "import_files", import_files)
mp.add_key_binding(nil, "import_url", import_url)
mp.add_key_binding(nil, "append_aid", append_aid)
mp.add_key_binding(nil, "append_sid", append_sid)

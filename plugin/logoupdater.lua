
--[[ The Tuxbox Copyright

 Copyright 2019 Markus Volk

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer. Redistributions in binary form must
 reproduce the above copyright notice, this list of conditions and the following
 disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS`` AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 The views and conclusions contained in the software and documentation are those of the
 authors and should not be interpreted as representing official policies, either expressed
 or implied, of the Tuxbox Project.]]

n = neutrino()
fh = filehelpers.new()

tmp = "/tmp/logoupdate"
this_dir = debug.getinfo(1,"S").source:sub(2):match("(.*/)")
bgimage = this_dir .. "logoupdater.png"
logo_source = tmp .. "/logos"
logo_event_source = tmp .. "/logos-events"
logo_popup_source = tmp .. "/logos-popup"
logolinker = tmp .. "/logo-links/logo-linker.sh"
logo_intro = tmp .. "/logo-intro/lua-version"
logodb = tmp .. "/logo-links/logo-links.db"
logoupdater_cfg = "/var/tuxbox/config/logoupdater.cfg"

local has_posix, posix = pcall(require, "posix")

neutrino_conf = configfile.new()
neutrino_conf:loadConfig("/etc/neutrino/config/neutrino.conf")
lang = neutrino_conf:getString("language", "english")
timing_menu = neutrino_conf:getInt32("timing.menu", 240)
osd_resolution = neutrino_conf:getInt32("osd_resolution", 1)

caption = "Logo Updater"

local function shq(s)
	return ("%q"):format(tostring(s or ""))
end

local function normalize_exec(raw)
	if type(raw) == "boolean" then return raw end
	return raw == 0
end

local function execute_command(command)
	io.write(string.format("execute: %s\n", command))
	local out_path = "/tmp/lua_execute_tmp_file"
	local err_path = out_path .. ".err"
	local raw = os.execute(command .. " >" .. out_path .. " 2>" .. err_path)
	local ok = normalize_exec(raw)
	local fo = io.open(out_path, "r")
	local stdout = fo and fo:read("*all") or ""
	if fo then fo:close() end
	local fe = io.open(err_path, "r")
	local stderr = fe and fe:read("*all") or ""
	if fe then fe:close() end
	return ok, stdout, stderr
end

local function sleep(sec)
	if has_posix and posix.sleep then
		posix.sleep(sec)
	else
		os.execute("sleep " .. tonumber(sec))
	end
end

function exists(file)
	if fh:exist(file, "f") == false then
		io.write(string.format("NOTE: file %s does not exist...\n", file))
		return false
	end
	return true
end

function isdir(path)
	if fh:exist(path, "d") == false then
		io.write(string.format("NOTE: path %s does not exist...\n", path))
		return false
	end
	return true
end

local function ensure_dir(path)
	if not path or path == "" then return false end
	if fh:exist(path, "d") then return true end
	local ok = execute_command("mkdir -p " .. shq(path))
	return ok and fh:exist(path, "d") == true
end

-- Mirrors Neutrino's own logo search order:
--   logo_hdd_dir -> LOGODIR_VAR -> LOGODIR
-- (see pictureviewer.cpp). Creates the user-configured dir on demand so
-- a fresh install with a missing logo_hdd_dir still succeeds.
-- Path is taken straight from neutrino.conf; the plugin never persists
-- its own logo path.
local function resolve_logo_dir(conf)
	local neutrino_path = conf:getString("logo_hdd_dir", "")
	local candidates = {
		{ source = "neutrino.conf (logo_hdd_dir)", path = neutrino_path },
		{ source = "LOGODIR_VAR",                  path = LOGODIR_VAR },
		{ source = "LOGODIR",                      path = LOGODIR },
	}
	for _, c in ipairs(candidates) do
		if c.path and c.path ~= "" then
			if ensure_dir(c.path) then
				io.write(string.format(
					"logoupdater: using logo dir %q (source: %s)\n",
					c.path, c.source))
				return c.path
			else
				io.write(string.format(
					"logoupdater: WARNING candidate %q (source: %s) is unusable, trying next\n",
					c.path, c.source))
			end
		end
	end
	io.write(string.format(
		"logoupdater: WARNING falling back to hardcoded %q\n", LOGODIR))
	return LOGODIR
end

logodir = resolve_logo_dir(neutrino_conf)

locale = {}
locale["deutsch"] = {
fetch_source = "Die aktuellen Logos werden geladen",
fetch_failed = "Download fehlgeschlagen",
copy_logos = "Die Logos werden ins Logoverzeichnis kopiert",
copy_failed = "Kopieren fehlgeschlagen",
copy_eventlogos = "Die Event-Logos werden ins Logoverzeichnis kopiert",
copy_popuplogos = "Die Popup-Logos werden ins Logoverzeichnis kopiert",
link_logos = "Es werden benötigte Links erstellt",
link_failed = "Erstellen der Links fehlgeschlagen",
cleanup = "Temporäre Dateien werden gelöscht",
cleanup_failed = "Temporäre Dateien konnten nicht entfernt werden",
menu_options = "Einstellungen",
menu_update = "Update starten",
yes = "ja",
no = "nein",
cfg_popup = "Popup Logos installieren",
cfg_event = "Event Logos installieren",
cfg_git = "Git für den Download verwenden",
cfg_keep = "Bestehende Dateien behalten",
msg_end = "Logos wurden erfolgreich nach " .. logodir .. " installiert",
}
locale["english"] = {
fetch_source = "The latest logos are getting downloaded.",
fetch_failed = "Download failed",
copy_logos = "Copy logos to its destination",
copy_failed = "Copying data failed",
copy_eventlogos = "Copying eventlogos",
copy_popuplogos = "Copying popuplogos",
link_logos = "Creating needed links",
link_failed = "Linking failed",
cleanup = "Cleanup temporary files",
cleanup_failed = "Cleanup data failed",
menu_options = "Options",
menu_update = "Start update",
yes = "yes",
no = "no",
cfg_popup = "Install popup logos",
cfg_event = "Install event logos",
cfg_git = "Use git for downloading",
cfg_keep = "Keep existing files",
msg_end = "Logos were successfully installed into " .. logodir,
}

local function create_logoupdater_cfg()
	local cfg_dir = string.match(logoupdater_cfg, "(.+)/[^/]+$")
	if cfg_dir and not isdir(cfg_dir) then
		fh:mkdir(cfg_dir)
	end

	local f = io.open(logoupdater_cfg, "w")
	if not f then
		io.write(string.format("ERROR: unable to open %s for writing\n", logoupdater_cfg))
		return false
	end
	f:write("eventlogos=1\n")
	f:write("popuplogos=0\n")
	f:write("use_git=0\n")
	f:write("keep_files=0\n")
	f:write("last_logodir=\n")
	f:close()
	return true
end

if not exists(logoupdater_cfg) then
	create_logoupdater_cfg()
end

local function get_cfg_value(str)
	if not exists(logoupdater_cfg) then
		return 0
	end

	local value = 0
	for line in io.lines(logoupdater_cfg) do
		if line:match("^" .. str .. "=") then
			local _, j = string.find(line, str .. "=")
			value = tonumber(string.sub(line, j+1, #line)) or 0
			break
		end
	end
	return value
end

local function get_cfg_string(str, default)
	if not exists(logoupdater_cfg) then
		return default or ""
	end
	for line in io.lines(logoupdater_cfg) do
		if line:match("^" .. str .. "=") then
			local _, j = string.find(line, str .. "=")
			return string.sub(line, j + 1, #line)
		end
	end
	return default or ""
end

local function set_cfg_value(key, value)
	local lines = {}
	local found = false
	if exists(logoupdater_cfg) then
		for line in io.lines(logoupdater_cfg) do
			if line:match("^" .. key .. "=") then
				line = key .. "=" .. tostring(value)
				found = true
			end
			table.insert(lines, line)
		end
	end
	if not found then
		table.insert(lines, key .. "=" .. tostring(value))
	end
	local f = io.open(logoupdater_cfg, "w")
	if not f then
		io.write(string.format("ERROR: unable to open %s for writing\n", logoupdater_cfg))
		return false
	end
	for _, l in ipairs(lines) do f:write(l, "\n") end
	f:close()
	return true
end

if get_cfg_value("use_git") == 1 then
	logo_url = "https://github.com/neutrino-images/ni-logo-stuff"
else
	logo_url = "https://codeload.github.com/neutrino-images/ni-logo-stuff/zip/master"
end

local function show_error(msg)
	local hb = hintbox.new { title = caption, icon = "settings", text = msg }
	hb:paint()
	sleep(3)
	hb:hide()
end

local function step(text, command, err_text)
	local hb = hintbox.new { title = caption, icon = "settings", text = text }
	hb:paint()
	local ok = execute_command(command)
	sleep(1)
	hb:hide()
	if not ok then
		show_error(err_text)
		return false
	end
	return true
end

local function download_logos()
	local hb = hintbox.new { title = caption, icon = "settings", text = locale[lang].fetch_source }
	hb:paint()
	local ok
	if get_cfg_value("use_git") == 1 then
		ok = execute_command("git clone " .. logo_url .. " " .. shq(tmp))
	else
		local zip = tmp .. ".zip"
		ok = execute_command("curl " .. logo_url .. " -o " .. shq(zip))
		if ok then
			if not fh:exist(tmp, "d") then
				execute_command("mkdir -p " .. shq(tmp))
			end
			ok = execute_command("unzip -x " .. shq(zip) .. " -d " .. shq(tmp))
			if ok and has_posix and posix.glob then
				for _, v in ipairs(posix.glob(tmp .. "/*/*") or {}) do
					execute_command("mv -f " .. shq(v) .. " " .. shq(tmp))
				end
			end
			execute_command("rm -rf " .. shq(zip))
		end
	end
	hb:hide()
	if not ok then
		show_error(locale[lang].fetch_failed)
		return false
	end
	return true
end

function start_update()
	chooser:hide()
	if isdir(tmp) then
		execute_command("rm -rf " .. shq(tmp))
	end

	if not download_logos() then return end

	local delete = ""
	if get_cfg_value("keep_files") == 0 then delete = "--delete " end

	if not step(locale[lang].copy_logos,
			"rsync -rlpgoD --size-only " .. delete
				.. shq(logo_source .. "/") .. " " .. shq(logodir),
			locale[lang].copy_failed) then return end

	if get_cfg_value("eventlogos") == 1 then
		if not step(locale[lang].copy_eventlogos,
				"rsync -rlpgoD --size-only " .. delete
					.. shq(logo_event_source) .. "/* " .. shq(logodir),
				locale[lang].copy_failed) then return end
	end

	if get_cfg_value("popuplogos") == 1 then
		if not step(locale[lang].copy_popuplogos,
				"rsync -rlpgoD --size-only " .. delete
					.. shq(logo_popup_source) .. "/* " .. shq(logodir),
				locale[lang].copy_failed) then return end
	end

	-- todo: implement lua-filesystem to improve linking performance
	if not step(locale[lang].link_logos,
			shq(logolinker) .. " " .. shq(logodb) .. " " .. shq(logodir),
			locale[lang].link_failed) then return end

	if not step(locale[lang].cleanup,
			"rm -rf " .. shq(tmp),
			locale[lang].cleanup_failed) then return end

	messagebox.exec{ title = caption, text = locale[lang].msg_end, buttons = {"ok"}, timeout = 6 }
end

local function write_cfg(_, v, key)
	local new = (v == locale[lang].yes) and "1" or "0"
	local lines = {}
	for line in io.lines(logoupdater_cfg) do
		if line:match("^" .. key .. "=") then
			line = key .. "=" .. new
		end
		table.insert(lines, line)
	end
	local f = assert(io.open(logoupdater_cfg, "w"))
	for _, l in ipairs(lines) do f:write(l, "\n") end
	f:close()
end

function eventlogos_cfg(k, v)
	write_cfg(k, v, "eventlogos")
end

function popuplogos_cfg(k, v)
	write_cfg(k, v, "popuplogos")
end

function use_git_cfg(k, v)
	write_cfg(k, v, "use_git")
end

function keep_files_cfg(k, v)
	write_cfg(k, v, "keep_files")
end

local function chooser_pair(current)
	local opt = { locale[lang].yes, locale[lang].no }
	if current == 1 then
		return { opt[1], opt[2] }
	else
		return { opt[2], opt[1] }
	end
end

function options()
	chooser:hide()
	local m = menu.new{ name = locale[lang].menu_options }
	m:addItem{ type = "back" }
	m:addItem{ type = "separatorline" }
	m:addItem{ type = "chooser", action = "eventlogos_cfg",
		options = chooser_pair(get_cfg_value("eventlogos")),
		id = "ID1", icon = 1, directkey = RC["1"], name = locale[lang].cfg_event }
	m:addItem{ type = "chooser", action = "popuplogos_cfg",
		options = chooser_pair(get_cfg_value("popuplogos")),
		id = "ID2", icon = 2, directkey = RC["2"], name = locale[lang].cfg_popup }
	m:addItem{ type = "chooser", action = "use_git_cfg",
		options = chooser_pair(get_cfg_value("use_git")),
		id = "ID3", icon = 3, directkey = RC["3"], name = locale[lang].cfg_git }
	m:addItem{ type = "chooser", action = "keep_files_cfg",
		options = chooser_pair(get_cfg_value("keep_files")),
		id = "ID4", icon = 4, directkey = RC["4"], name = locale[lang].cfg_keep }
	m:exec()
	main()
end

function main()
	local chooser_dx = n:scale2Res(560)
	local chooser_dy = n:scale2Res(350)
	local chooser_x = SCREEN.OFF_X + (((SCREEN.END_X - SCREEN.OFF_X) - chooser_dx) / 2)
	local chooser_y = SCREEN.OFF_Y + (((SCREEN.END_Y - SCREEN.OFF_Y) - chooser_dy) / 2)

	chooser = cwindow.new {
		x = chooser_x,
		y = chooser_y,
		dx = chooser_dx,
		dy = chooser_dy,
		icon = "settings",
		has_shadow = true,
		btnGreen = locale[lang].menu_update,
		btnRed = locale[lang].menu_options
	}

	chooser:setBodyImage{ image_path = bgimage }
	chooser:paint()

	local i = 0
	local d = 500 -- ms
	local t = (timing_menu * 1000) / d
	if t == 0 then
		t = -1 -- no timeout
	end
	local colorkey = nil
	local msg, data
	repeat
		i = i + 1
		msg, data = n:GetInput(d)
		if msg == RC['red'] then
			options()
			colorkey = true
		elseif msg == RC['green'] then
			start_update()
			colorkey = true
		end
	until msg == RC['home'] or colorkey or i == t
	chooser:hide()
end

main()

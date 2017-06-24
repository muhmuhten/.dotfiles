local utils = require 'mp.utils'

local prefix = os.getenv("HOME") .. "/Logs/mpv/"

local function append_log(name, tag, ...)
	local fh = assert(io.open(prefix .. name .. "." .. tag, "a"))
	fh:write(table.concat({...}, "\t") .. "\n")
	fh:close()
end

local last_file
local seen_zero = false

local function on_end_file(e)
	if not last_file then
		return
	end

	local start, name, path, dur = unpack(last_file)
	local time = os.time()

	if time - start <= dur/20 then
		return
	end

	local date = os.date("!%F %T", time)
	append_log(name, "on_end_file", date, e.event, path)
end

local function on_file_loaded(e)
	local path = utils.join_path(utils.getcwd(), mp.get_property "path")
	local name = mp.get_property "filename/no-ext"

	local time = os.time()
	local date = os.date("!%F %T", time)
	append_log(name, "on_file_loaded", date, e.event, path)
	last_file = {time, name, path, tonumber(mp.get_property "duration")}
	seen_zero = false
end

local function on_playback_restart(e)
	pos = mp.get_property "time-pos"
	if pos then
		pos = tonumber(pos)
	else
		return
	end

	-- XXX pos < 0 when looped from end
	if pos == 0 and not seen_zero then
		seen_zero = true
		return
	end

	if pos <= 0 then
		on_end_file(e)
		on_file_loaded(e)
	end
end

mp.register_event("end-file", on_end_file)
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("playback-restart", on_playback_restart)

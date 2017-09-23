local function flop_audio()
	local tracklist = mp.get_property_native "track-list"
	local audiolist = {}
	local sel = 0
	for i, track in ipairs(tracklist) do
		if track.type == "audio" then
			audiolist[#audiolist+1] = track.id
			if track.selected then
				sel = #audiolist
			end
		end
	end
	if #audiolist <= 1 then return end
	mp.set_property_number("aid", audiolist[sel % #audiolist + 1])
end
mp.add_key_binding("a", "flop-audio", flop_audio)

local function show_audio()
	print(mp.get_property "aid")
end
mp.add_key_binding("0x1", "show-audio", show_audio)

local function set_audio(n)
	return function()
		mp.set_property_number("aid", n)
	end
end
for i=1,9 do
	mp.add_key_binding("Alt+"..i, "aid="..i, set_audio(i))
end

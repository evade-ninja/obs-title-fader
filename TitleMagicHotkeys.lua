local obs = obslua
local debug
local hk = {}
local hotkeySwitch1 = 0;

local hotkeys = {
    A_SWITCH_1 = "Show Title"
}

local function onHotKey(action)
    if debug then obs.script_log(obs.LOG_INFO, string.format("Hotkey : %s", action)) end

    if action == "A_SWITCH_1" then
        if hotkeySwitch1 == 0 then
			hotkeySwitch1 = 1
		else
			hotkeySwitch1 = 0
		end
        update_hotkeys_js()
    end
end

function update_hotkeys_js()
    local output = assert(io.open(script_path() .. '/hotkeys.js', "w"))
    output:write('hotkeySwitch1 = '.. hotkeySwitch1 .. ';\n')
    output:close()
end

function script_load(settings)
	function pairsByKeys (t, f)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0
		local iter = function ()
		  i = i + 1
		  if a[i] == nil then return nil
		  else return a[i], t[a[i]]
		  end
		end
		return iter
	end	

	for name, line in pairsByKeys(hotkeys) do
		hk[name] = obs.obs_hotkey_register_frontend(name, line, function(pressed) if pressed then onHotKey(name) end end)
		local hotkeyArray = obs.obs_data_get_array(settings, name)
		obs.obs_hotkey_load(hk[name], hotkeyArray)
		obs.obs_data_array_release(hotkeyArray)
	end	
	update_hotkeys_js()
end

-- called on unload
function script_unload()
end

-- called when settings changed
function script_update(settings)
	debug = obs.obs_data_get_bool(settings, "debug")
end


-- return description shown to user
function script_description()
	return "Control the TitleMagic"
end


-- define properties that user can change
function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_bool(props, "debug", "Debug")
	return props
end


-- set default values
function script_defaults(settings)
	obs.obs_data_set_default_bool(settings, "debug", false)
end


-- save additional data not set by user
function script_save(settings)
	for k, v in pairs(hotkeys) do
		local hotkeyArray = obs.obs_hotkey_save(hk[k])
		obs.obs_data_set_array(settings, k, hotkeyArray)
		obs.obs_data_array_release(hotkeyArray)
	end
end
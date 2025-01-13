-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

if package.config:sub(1, 1) == '\\' then
	-- We are on windows
	config.default_domain = "WSL:Ubuntu-20.04"
end

config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"
config.window_padding = { left = 0, right = 0, top = "0.2cell", bottom = "0.2cell" }
config.font_size = 17.0
config.audible_bell = "Disabled"

config.keys = {
	-- Currently, F20 appears to be bugged, so this config doesn't take affect.
	{
		key = 'F20',
		action = wezterm.action.Nop,
	},
	{
		key = 'F10',
		action = wezterm.action.Nop,
	},
}

-- and finally, return the configuration to wezterm
return config

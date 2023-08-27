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
config.font_size = 15.0

-- and finally, return the configuration to wezterm
return config

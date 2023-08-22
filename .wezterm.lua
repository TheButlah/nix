-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
        config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

config.default_domain = "WSL:Ubuntu-20.04"
config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"
config.window_padding = { left = 0, right = 0, top = "0.2cell", bottom = "0.2cell" }

-- and finally, return the configuration to wezterm
return config

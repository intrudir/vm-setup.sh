-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.default_prog = { "powershell.exe", "-NoLogo" }
config.color_scheme = 'Argonaut'
config.font = wezterm.font 'FiraCode Nerd Font'
-- and finally, return the configuration to wezterm
return config

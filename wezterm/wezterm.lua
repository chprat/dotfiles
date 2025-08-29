local wezterm = require("wezterm")
local config = wezterm.config_builder()
local on_mac = wezterm.target_triple == "aarch64-apple-darwin"

config.font = wezterm.font("JetBrains Mono")
config.font_size = on_mac and 14 or 12

config.color_scheme = "Rosé Pine Moon (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

-- configure word boundaries for mouse selection
config.selection_word_boundary = " \t\n{}[]()\"'`,:;│"

return config

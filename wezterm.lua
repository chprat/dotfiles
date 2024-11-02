local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Solarized (light) (terminal.sexy)"
config.hide_tab_bar_if_only_one_tab = true

-- configure word boundaries for mouse selection
config.selection_word_boundary = " \t\n{}[]()\"'`,:;│"

return config

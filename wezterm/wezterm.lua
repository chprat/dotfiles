local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")

config.color_scheme = "Rosé Pine Moon (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

wezterm.on("gui-startup", function()
    local _, _, window = mux.spawn_window({})
    window:gui_window():maximize()
end)

-- configure word boundaries for mouse selection
config.selection_word_boundary = " \t\n{}[]()\"'`,:;│"

return config

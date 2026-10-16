local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 14
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0
}
config.font = wezterm.font 'MesloLGSNerdFontMono'
config.color_scheme = "Dracula (Official)"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.9
config.window_decorations = "NONE"

-- Workaround for wezterm <= 20240203 dropping fullscreen on alt-tab under
-- Wayland (upstream #6262 / #6383, fixed after that release). Should be
-- unnecessary on nightly -- uncomment if fullscreen still breaks.
-- config.enable_wayland = false

config.keys = {
  {
    key = 'F11',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action{SendString = "\x1b\r"},
  },
}

return config

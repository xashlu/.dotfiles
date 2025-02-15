local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'

local background_image = wezterm.config_dir .. '/0.png'

config.background = {
  {
    source = {
      File = background_image
    },
    hsb = { brightness = 0.02 }
  }
}

config.color_scheme = 'AdventureTime'
return config

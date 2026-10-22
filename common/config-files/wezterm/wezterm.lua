local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'DroidSansM Nerd Font',
  'Noto Sans Symbols2',
  'Noto Color Emoji',
}
config.font_size = 14
config.colors = {
  background = '#1c1c1c', -- Match tmux's colour234 pane background.
}

-- Match Terminator's disabled bold rendering.
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font_with_fallback {
      'DroidSansM Nerd Font',
      'Noto Sans Symbols2',
      'Noto Color Emoji',
    },
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font_with_fallback {
      { family = 'DroidSansM Nerd Font', italic = true },
      'Noto Sans Symbols2',
      'Noto Color Emoji',
    },
  },
}

config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.enable_tab_bar = false
config.enable_scroll_bar = false
-- WezTerm has no unbounded scrollback option; retain one million lines per tab.
config.scrollback_lines = 1000000
-- Concord emits U+10EEEE, a private glyph with no available font on this host.
config.warn_about_missing_glyphs = false
config.keys = {
  {
    key = 'F11',
    action = wezterm.action.ToggleFullScreen,
  },
}

return config

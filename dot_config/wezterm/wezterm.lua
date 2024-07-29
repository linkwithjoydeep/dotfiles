local wezterm = require("wezterm")
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Catppuccin Mocha"

-- no tabs for tmux gang ;)
config.enable_tab_bar = false

-- Font configs
config.font = wezterm.font_with_fallback({
	"Dank Mono",
	"JetBrainsMono Nerd Font",
})
config.font_size = 16.0
config.line_height = 1.5
config.freetype_load_target = "HorizontalLcd"

-- window decoration
config.enable_scroll_bar = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
	top = "1.2cell",
	bottom = 0,
}

config.animation_fps = 60

config.scrollback_lines = 50000

-- utils
config.term = "wezterm"

config.audible_bell = "Disabled"

return config

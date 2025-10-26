local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("DankMono Nerd Font")
config.font_size = 18.0
config.line_height = 1.35 -- 35% increase from default

-- Theme
config.color_scheme = "Tokyo Night"

-- Cursor
config.default_cursor_style = "BlinkingBlock"

-- Mouse behavior
config.hide_mouse_cursor_when_typing = true
-- config.mouse_wheel_scaling = 2.0

-- Window configuration
config.window_padding = {
	left = "0cell",
	right = "0cell",
	top = "40px",
	bottom = "0cell",
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE" -- Transparent titlebar on macOS
config.enable_tab_bar = false

-- macOS specific
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Shell integration features disabled (no-cursor, sudo, no-title)
-- Wezterm's shell integration is controlled differently
config.enable_scroll_bar = false

return config

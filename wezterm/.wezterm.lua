-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
-- local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

-- ---------- Performance / rendering ----------
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 1
config.prefer_egl = true
config.term = "xterm-256color"

-- Make the status line update frequently so short modes (like 1s leader) are visible
config.status_update_interval = 200 -- ms

-- ---------- Cursor ----------
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- ---------- Font ----------
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"FiraCode Nerd Font Mono", -- fallback in case the installer used the Mono family
})
config.font_size = 12.0
config.cell_width = 0.9

-- ---------- Window ----------
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Keep native Windows title bar + buttons
config.window_decorations = "TITLE | RESIZE"

-- This only affects custom-drawn frames; Windows' native TITLE bar may ignore these colors
config.window_frame = {
	font = wezterm.font_with_fallback({
		"FiraCode Nerd Font",
		"FiraCode Nerd Font Mono",
	}),
	active_titlebar_bg = "#0c0b0f",
}

-- ---------- Tabs ----------
-- Important: show the tab bar so left/right status (leader indicator) is visible
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

-- ---------- Shell ----------
-- Start PowerShell 7 by default
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- ---------- Colors / scheme toggling ----------
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {
	background = "#0c0b0f", -- dark purple
	cursor_border = "#bea3c7",
	cursor_bg = "#bea3c7",

	tab_bar = {
		background = "#0c0b0f",
		active_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#bea3c7",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#f8f2f5",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		new_tab = { bg_color = "#0c0b0f", fg_color = "white" },
	},
}

wezterm.on("toggle-colorscheme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Zenburn" then
		overrides.color_scheme = "Cloud (terminal.sexy)"
	else
		overrides.color_scheme = "Zenburn"
	end
	window:set_config_overrides(overrides)
end)

-- ---------- Status indicators (left & right) ----------
wezterm.on("update-right-status", function(window, _pane)
	local k = window:active_key_table()
	local label = ""
	if k == "leader" then
		label = " [LEADER] "
	elseif k == "window" then
		label = " [WIN] "
	elseif k == "resize" then
		label = " [RESIZE] "
	end

	-- Show on the right
	window:set_right_status(wezterm.format({
		{ Attribute = { Italic = true } },
		{ Text = label },
	}))

	-- Mirror on the left as well so it’s obvious
	window:set_left_status(wezterm.format({
		{ Attribute = { Bold = true } },
		{ Text = label },
	}))
end)

-- ---------- Key tables ----------
-- Pseudo-leader so we can detect and display [LEADER]
-- Press SHIFT+Space to enter 'leader' for ~1.2s
config.key_tables = {
	leader = {
		-- leader → w → (b/v/q/p)
		{ key = "w", action = act.ActivateKeyTable({ name = "window", one_shot = true, timeout_milliseconds = 1200 }) },
		-- leader → e => resize mode (h/j/k/l to resize; e or Esc to exit)
		{ key = "e", action = act.ActivateKeyTable({ name = "resize", one_shot = false }) },
		{ key = "Escape", action = "PopKeyTable" },
	},

	-- Window/pane management (triggered by leader → w)
	window = {
		-- Split horizontally (side-by-side)
		{ key = "b", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
		-- Split vertically (top/bottom)
		{ key = "v", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
		-- Close current pane (as requested: q)
		{ key = "q", action = act.CloseCurrentPane({ confirm = true }) },
		-- Pane select overlay
		{ key = "p", action = act.PaneSelect },
		{ key = "Escape", action = "PopKeyTable" },
	},

	-- Resize mode: enter with leader → e; h/j/k/l to resize; e or Esc to exit
	resize = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "e", action = "PopKeyTable" },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

-- ---------- Keys ----------
config.keys = {
	-- SHIFT+Space: enter pseudo-leader (1.2s)
	{
		key = "Space",
		mods = "SHIFT",
		action = act.ActivateKeyTable({ name = "leader", one_shot = false, timeout_milliseconds = 1200 }),
	},

	-- Color scheme toggle
	{ key = "E", mods = "CTRL|SHIFT|ALT", action = act.EmitEvent("toggle-colorscheme") },

	-- Alt+Ctrl+H/V splits
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT|ALT",
		action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }),
	},

	-- Ctrl+L to show debug overlay
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },

	-- Ctrl+Alt+O toggles opacity
	{
		key = "O",
		mods = "CTRL|ALT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.window_background_opacity == 1.0 then
				overrides.window_background_opacity = 0.9
			else
				overrides.window_background_opacity = 1.0
			end
			window:set_config_overrides(overrides)
		end),
	},
}

-- ---------- Size ----------
config.initial_cols = 80

-- Return the configuration to wezterm
return config

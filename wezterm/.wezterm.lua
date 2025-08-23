local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

-- ---------- Render / perf ----------
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 60
config.prefer_egl = true
config.term = "xterm-256color"
config.status_update_interval = 10 -- refresh status frequently

-- ---------- Cursor ----------
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- ---------- Font ----------
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"FiraCode Nerd Font Mono",
})
config.font_size = 12.0
config.cell_width = 0.9

-- ---------- Window ----------
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = "TITLE | RESIZE" -- native Windows buttons
config.window_frame = {
	font = wezterm.font_with_fallback({ "FiraCode Nerd Font", "FiraCode Nerd Font Mono" }),
	active_titlebar_bg = "#0c0b0f",
}

-- Dim inactive panes for visual focus
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.75 }

-- ---------- Tabs (needed for status areas) ----------
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

-- ---------- Shell ----------
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- ---------- Colors / toggling ----------
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {
	background = "#0c0b0f",
	cursor_border = "#bea3c7",
	cursor_bg = "#bea3c7",
	tab_bar = {
		background = "#0c0b0f",
		active_tab = { bg_color = "#0c0b0f", fg_color = "#bea3c7" },
		inactive_tab = { bg_color = "#0c0b0f", fg_color = "#f8f2f5" },
		new_tab = { bg_color = "#0c0b0f", fg_color = "white" },
	},
}

config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 2000 }

wezterm.on("toggle-colorscheme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = (overrides.color_scheme == "Zenburn") and "Cloud (terminal.sexy)" or "Zenburn"
	window:set_config_overrides(overrides)
end)

-- ---------- Status: left shows mode badge; right shows time | workspace | battery ----------

local function battery_text()
	local list = wezterm.battery_info() or {}
	if #list == 0 then
		return ""
	end
	local pct_sum, charging = 0, false
	for _, b in ipairs(list) do
		pct_sum = pct_sum + ((b.state_of_charge or 0) * 100)
		local st = (b.state or ""):lower()
		charging = charging or st:find("charging")
	end
	local pct = math.floor(pct_sum / #list + 0.5)
	local glyph = charging and "⚡" or "🔋"
	return string.format("%s %d%%", glyph, pct)
end

local function mode_badge(mode)
	-- Bright, obvious badge so it's impossible to miss
	local bg = "#d33682" -- magenta-ish
	if mode == "[WIN]" then
		bg = "#268bd2" -- blue
	elseif mode == "[RESIZE]" then
		bg = "#b58900" -- yellow
	end
	-- return wezterm.format({
	-- 	{ Background = { Color = bg } },
	-- 	{ Foreground = { Color = "#0c0b0f" } },
	-- 	{ Attribute = { Bold = true } },
	-- 	{ Text = " " .. mode .. " " },
	-- 	{ Background = { Color = "none" } },
	-- 	{ Foreground = { Color = "none" } },
	-- })

	return wezterm.format({
		{ Background = { Color = bg } },
		{ Foreground = { Color = "#0c0b0f" } },
		{ Attribute = { Intensity = "Bold" } }, -- valid form
		{ Text = " " .. mode .. " " },
		"ResetAttributes", -- clean reset
	})
end

local function cwd_status(pane)
	local uri = pane and pane:get_current_working_dir()
	if not uri then
		return ""
	end
	uri = tostring(uri)
	-- ssh://user@host/path  |  file:///C:/Users/...
	local host = uri:match("^ssh://[^@]+@([^/]+)") or ""
	local path = uri:gsub("^%a+://[^/]*/?", "/")
	if path:match("^/[A-Za-z]:") then
		path = path:sub(2)
	end -- strip leading slash on Windows drive paths
	local base = path:match("([^/\\]+)/*$") or path
	if host ~= "" then
		return string.format("  %s · %s  ", host, base)
	else
		return string.format("  %s  ", base)
	end
end

local spin_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spin_i = 1
wezterm.on("update-right-status", function(window, _pane)
	spin_i = (spin_i % #spin_frames) + 1
	local kt = window:active_key_table()

	local mode = (kt == "leader" and "[LEADER]")
		or (kt == "resize" and "[RESIZE]")
		or (kt == "window" and "[WIN]")
		or (kt == "copy_mode" and "[COPY]")
		or (kt == "search_mode" and "[SEARCH]")
		or ((window.leader_is_active and window:leader_is_active()) and "[LEADER]")
		or ""
	if mode == "[LEADER]" then
		mode = mode .. " " .. spin_frames[spin_i]
	end

	local time = wezterm.strftime("%Y-%m-%d %H:%M")
	local ws = mux.get_active_workspace() or "default"
	local batt = battery_text()

	-- local dbg =
	-- string.format(" [kt:%s L:%s] ", tostring(kt), tostring(window.leader_is_active and window:leader_is_active()))

	-- Build the right status; put the mode badge first if active
	local right = ""
	if mode ~= "" then
		right = mode_badge(mode) .. "  "
		window:set_left_status("") -- keep left side empty so it doesn't duplicate
	end

	right = right
		.. wezterm.format({
			{ Attribute = { Italic = true } },
			{ Text = string.format("%s  |   %s  |  %s ", time, ws, batt) },
		})
	right = right -- .. wezterm.format({ { Foreground = { Color = "#888888" } }, { Text = dbg } })

	window:set_right_status(right)

	window:set_left_status(wezterm.format({ { Text = cwd_status(window:active_pane()) } }))
end)

-- ---------- Broadcast helper (prompt → send one line to all panes in current tab) ----------
wezterm.on("broadcast_line_to_panes", function(window, pane)
	window:perform_action(
		act.PromptInputLine({
			description = "Broadcast one line to all panes in this tab",
			action = wezterm.action_callback(function(win, _p, line)
				if not line or #line == 0 then
					return
				end
				local tab = win:active_tab()
				if tab then
					for _, p in ipairs(tab:panes()) do
						p:send_text(line .. "\n")
					end
				end
			end),
		}),
		pane
	)
end)

-- ---------- Key tables ----------
config.key_tables = {

	leader = {
		-- hand off to your existing modes
		{ key = "w", action = act.ActivateKeyTable({ name = "window", one_shot = true, timeout_milliseconds = 2000 }) },
		{ key = "e", action = act.ActivateKeyTable({ name = "resize", one_shot = false }) },

		-- passthrough helpers you already use on LEADER
		{ key = "p", action = act.ActivateCommandPalette },
		{ key = "s", action = act.ShowLauncherArgs({ flags = "WORKSPACES|TABS|LAUNCH_MENU_ITEMS" }) },
		{ key = "/", action = act.Search("CurrentSelectionOrEmptyString") },
		{ key = "c", action = act.ActivateCopyMode },

		-- exit fallback
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Space", action = "PopKeyTable" },
	},
	-- Window/pane management (leader → w)
	window = {
		-- Split side-by-side / top-bottom
		{ key = "b", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
		{ key = "v", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
		-- Close pane
		{ key = "q", action = act.CloseCurrentPane({ confirm = true }) },
		-- Pane select overlay
		{ key = "p", action = act.PaneSelect },
		-- Zoom toggle
		{ key = "z", action = act.TogglePaneZoomState },
		-- Broadcast one line to all panes in the tab
		{ key = "a", action = act.EmitEvent("broadcast_line_to_panes") },
		-- Directional pane focus with hjkl
		{ key = "h", action = act.ActivatePaneDirection("Left") },
		{ key = "j", action = act.ActivatePaneDirection("Down") },
		{ key = "k", action = act.ActivatePaneDirection("Up") },
		{ key = "l", action = act.ActivatePaneDirection("Right") },
		{ key = "Escape", action = "PopKeyTable" },
	},

	-- Resize mode: leader → e; h/j/k/l to resize; e or Esc to exit
	resize = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "e", action = "PopKeyTable" },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

-- ---------- Global keys ----------
config.keys = {

	-- Enter a visible leader *table* so status can see kt=="leader"
	{
		key = "Space",
		mods = "SHIFT",
		action = act.ActivateKeyTable({ name = "leader", one_shot = false, timeout_milliseconds = 2000 }),
	},

	-- Quick reload
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },

	-- One-shot paste of current working directory
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			local uri = pane:get_current_working_dir()
			if not uri then
				return
			end
			local path = tostring(uri):gsub("^%a+://[^/]*/?", "/")
			if path:match("^/[A-Za-z]:") then
				path = path:sub(2)
			end
			win:copy_to_clipboard(path)
			win:toast_notification("WezTerm", "Copied CWD to clipboard", nil, 1200)
		end),
	},

	{
		key = "w",
		mods = "LEADER",
		action = act.ActivateKeyTable({ name = "window", one_shot = true, timeout_milliseconds = 2000 }),
	},
	{ key = "e", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize", one_shot = false }) },
	{ key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES|TABS|LAUNCH_MENU_ITEMS" }) },
	{ key = "p", mods = "LEADER", action = act.ActivateCommandPalette },
	{ key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
	{
		key = "y",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local ts = wezterm.strftime("%Y%m%d-%H%M%S")
			local home = os.getenv("USERPROFILE") or os.getenv("HOME") or "."
			local sep = package.config:sub(1, 1)
			local dir = home .. sep .. "Downloads"
			local file = string.format("%s%swezterm_scrollback_%s.txt", dir, sep, ts)
			window:perform_action(act.SaveScrollbackToFile(file), pane)
		end),
	},
	-- Color scheme toggle
	{ key = "E", mods = "CTRL|SHIFT|ALT", action = act.EmitEvent("toggle-colorscheme") },

	-- Extra splits (kept)
	{ key = "h", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "v", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },

	-- Debug overlay
	{ key = "l", mods = "CTRL", action = act.ShowDebugOverlay },

	-- Opacity toggle
	{
		key = "O",
		mods = "CTRL|ALT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = (overrides.window_background_opacity == 1.0) and 0.9 or 1.0
			window:set_config_overrides(overrides)
		end),
	},
}

-- ---------- Size ----------
config.initial_cols = 80

return config

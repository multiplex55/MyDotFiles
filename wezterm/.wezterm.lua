local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

------------ Render / perf ----------
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 60
config.prefer_egl = true
config.term = "xterm-256color"
config.status_update_interval = 50 -- refresh status frequently

------------ Cursor ----------
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

------------ Font ----------
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"FiraCode Nerd Font Mono",
})
config.font_size = 12.0
config.cell_width = 0.9

------------ Window ----------
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = "TITLE | RESIZE" -- native Windows buttons
config.window_frame = {
	font = wezterm.font_with_fallback({ "FiraCode Nerd Font", "FiraCode Nerd Font Mono" }),
	active_titlebar_bg = "#0c0b0f",
}

-- Dim inactive panes for visual focus
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.75 }

------------ Tabs (needed for status areas) ----------
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

-- ---------- Shell ----------
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- ---------- Colors / toggling ----------
config.color_scheme = "Cloud (terminal.sexy)"

-- Dark base with amber/yellow highlights
config.colors = {
	foreground = "#E6E6E6",
	background = "#0B0E10",

	-- Cursor & selection tuned toward amber
	cursor_bg = "#FACC15", -- amber 400
	cursor_border = "#FACC15",
	cursor_fg = "#0B0E10",
	selection_bg = "#1E1B0E", -- deep amber wash
	selection_fg = "#FDE68A", -- soft yellow text

	-- Subtle UI bits
	scrollbar_thumb = "#4B5563",
	split = "#1F2937",

	-- Tab bar with a clear amber accent
	tab_bar = {
		background = "#0B0E10",
		active_tab = { bg_color = "#0B0E10", fg_color = "#FACC15", intensity = "Bold", underline = "Single" },
		inactive_tab = { bg_color = "#0B0E10", fg_color = "#9CA3AF" },
		inactive_tab_hover = { bg_color = "#111317", fg_color = "#FDE68A", italic = true },
		new_tab = { bg_color = "#0B0E10", fg_color = "#FACC15" },
		new_tab_hover = { bg_color = "#111317", fg_color = "#FDE68A", italic = true },
	},

	-- ANSI ramps nudged warmer (more yellow presence)
	ansi = { "#0B0E10", "#F87171", "#A3E635", "#FACC15", "#60A5FA", "#D8B4FE", "#34D399", "#E5E7EB" },
	brights = { "#1F2937", "#FCA5A5", "#BEF264", "#FDE68A", "#93C5FD", "#E9D5FF", "#6EE7B7", "#F9FAFB" },
}

-- local function mode_badge(mode)
-- 	-- Amber-first palette for badges
-- 	local bg = "#EAB308" -- default (LEADER): amber 500
-- 	if mode == "[WIN]" then
-- 		bg = "#F59E0B"
-- 	end -- amber 600
-- 	if mode == "[RESIZE]" then
-- 		bg = "#FACC15"
-- 	end -- amber 400
--
-- 	return wezterm.format({
-- 		{ Background = { Color = bg } },
-- 		{ Foreground = { Color = "#0B0E10" } },
-- 		{ Attribute = { Intensity = "Bold" } },
-- 		{ Text = " " .. mode .. " " },
-- 		"ResetAttributes",
-- 	})
-- end

-- OG colors
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

-- Make inactive panes only slightly dim (or not dim at all)
config.inactive_pane_hsb = {
	saturation = 1.0, -- keep colors vivid
	brightness = 0.92, -- try 0.90–0.96; 1.0 disables dimming
}

wezterm.on("toggle-colorscheme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = (overrides.color_scheme == "Zenburn") and "Cloud (terminal.sexy)" or "Zenburn"
	window:set_config_overrides(overrides)
end)

-- === Themes ===
local THEMES = {
	{
		name = "Amber Night", -- your current vibe
		colors = {
			foreground = "#E6E6E6",
			background = "#0B0E10",
			cursor_bg = "#FACC15",
			cursor_border = "#FACC15",
			cursor_fg = "#0B0E10",
			selection_bg = "#1E1B0E",
			selection_fg = "#FDE68A",
			tab_bar = {
				background = "#0B0E10",
				active_tab = { bg_color = "#0B0E10", fg_color = "#FACC15", intensity = "Bold", underline = "Single" },
				inactive_tab = { bg_color = "#0B0E10", fg_color = "#9CA3AF" },
				inactive_tab_hover = { bg_color = "#111317", fg_color = "#FDE68A", italic = true },
				new_tab = { bg_color = "#0B0E10", fg_color = "#FACC15" },
				new_tab_hover = { bg_color = "#111317", fg_color = "#FDE68A", italic = true },
			},
			ansi = { "#0B0E10", "#F87171", "#A3E635", "#FACC15", "#60A5FA", "#D8B4FE", "#34D399", "#E5E7EB" },
			brights = { "#1F2937", "#FCA5A5", "#BEF264", "#FDE68A", "#93C5FD", "#E9D5FF", "#6EE7B7", "#F9FAFB" },
		},
		accents = { leader = "#EAB308", win = "#F59E0B", resize = "#FACC15" },
	},
	{
		name = "Forest Matrix", -- deep green, “hacker” monitor
		colors = {
			foreground = "#D8FCD8",
			background = "#0A0F0A",
			cursor_bg = "#22C55E",
			cursor_border = "#22C55E",
			cursor_fg = "#071107",
			selection_bg = "#0F1A10",
			selection_fg = "#CFF7CF",
			tab_bar = {
				background = "#0A0F0A",
				active_tab = { bg_color = "#0A0F0A", fg_color = "#22C55E", intensity = "Bold" },
				inactive_tab = { bg_color = "#0A0F0A", fg_color = "#7FBF7F" },
				inactive_tab_hover = { bg_color = "#0C140C", fg_color = "#A7F3D0", italic = true },
				new_tab = { bg_color = "#0A0F0A", fg_color = "#22C55E" },
				new_tab_hover = { bg_color = "#0C140C", fg_color = "#A7F3D0", italic = true },
			},
			ansi = { "#0A0F0A", "#9EE493", "#74C69D", "#22C55E", "#22D3EE", "#C084FC", "#34D399", "#E1FFE1" },
			brights = { "#122012", "#B7F3AD", "#98E6B8", "#86EFAC", "#67E8F9", "#E9D5FF", "#6EE7B7", "#F0FFF0" },
		},
		accents = { leader = "#22C55E", win = "#16A34A", resize = "#34D399" },
	},
	{
		name = "Oceanic",
		colors = {
			foreground = "#E9F2FF",
			background = "#0B1115",
			cursor_bg = "#38BDF8",
			cursor_border = "#38BDF8",
			cursor_fg = "#081014",
			selection_bg = "#0F1C24",
			selection_fg = "#D1E7FF",
			tab_bar = {
				background = "#0B1115",
				active_tab = { bg_color = "#0B1115", fg_color = "#38BDF8", intensity = "Bold" },
				inactive_tab = { bg_color = "#0B1115", fg_color = "#91A4B7" },
				inactive_tab_hover = { bg_color = "#0F161B", fg_color = "#7DD3FC", italic = true },
				new_tab = { bg_color = "#0B1115", fg_color = "#38BDF8" },
				new_tab_hover = { bg_color = "#0F161B", fg_color = "#7DD3FC", italic = true },
			},
			ansi = { "#0B1115", "#FCA5A5", "#86EFAC", "#FDE68A", "#7DD3FC", "#D8B4FE", "#67E8F9", "#ECF5FF" },
			brights = { "#19242B", "#FEB2B2", "#BBF7D0", "#FEF3C7", "#BAE6FD", "#E9D5FF", "#A5F3FC", "#F8FBFF" },
		},
		accents = { leader = "#38BDF8", win = "#0EA5E9", resize = "#22D3EE" },
	},
	{
		name = "Grape Soda",
		colors = {
			foreground = "#F3EAFF",
			background = "#0E0A12",
			cursor_bg = "#A78BFA",
			cursor_border = "#A78BFA",
			cursor_fg = "#0E0A12",
			selection_bg = "#140F1D",
			selection_fg = "#F5E1FF",
			tab_bar = {
				background = "#0E0A12",
				active_tab = { bg_color = "#0E0A12", fg_color = "#C084FC", intensity = "Bold" },
				inactive_tab = { bg_color = "#0E0A12", fg_color = "#B9A3CC" },
				inactive_tab_hover = { bg_color = "#130E1A", fg_color = "#E879F9", italic = true },
				new_tab = { bg_color = "#0E0A12", fg_color = "#C084FC" },
				new_tab_hover = { bg_color = "#130E1A", fg_color = "#E879F9", italic = true },
			},
			ansi = { "#0E0A12", "#F472B6", "#A7F3D0", "#FDE68A", "#A78BFA", "#E879F9", "#67E8F9", "#F3EAFF" },
			brights = { "#1B1324", "#FDA4AF", "#D1FAE5", "#FEF3C7", "#DDD6FE", "#F0ABFC", "#A5F3FC", "#FFFFFF" },
		},
		accents = { leader = "#A78BFA", win = "#C084FC", resize = "#E879F9" },
	},
}

-- Track current theme (used by mode_badge)
local CURRENT_THEME = THEMES[1]

-- Apply a theme to a given window via config overrides
local function apply_theme_to_window(window, theme)
	local o = window:get_config_overrides() or {}
	o.colors = o.colors or {}
	-- shallow-copy color fields
	for k, v in pairs(theme.colors or {}) do
		o.colors[k] = v
	end
	window:set_config_overrides(o)
end

-- Cycle through themes
wezterm.on("cycle-theme", function(window, _)
	local idx = 1
	for i, t in ipairs(THEMES) do
		if t == CURRENT_THEME then
			idx = i
			break
		end
	end
	idx = (idx % #THEMES) + 1
	CURRENT_THEME = THEMES[idx]
	apply_theme_to_window(window, CURRENT_THEME)
	-- window:toast_notification("WezTerm", "Theme → " .. CURRENT_THEME.name, nil, 1000)
end)

-- Pick a theme by name (case-insensitive)
wezterm.on("pick-theme", function(window, pane)
	local names = {}
	for _, t in ipairs(THEMES) do
		table.insert(names, t.name)
	end
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Theme name (" .. table.concat(names, ", ") .. "):",
			action = wezterm.action_callback(function(win, _, line)
				if not line or line == "" then
					return
				end
				for _, t in ipairs(THEMES) do
					if line:lower() == t.name:lower() then
						CURRENT_THEME = t
						apply_theme_to_window(win, t)
						-- win:toast_notification("WezTerm", "Theme → " .. t.name, nil, 1000)
						return
					end
				end
				win:toast_notification("WezTerm", "No such theme: " .. line, nil, 1500)
			end),
		}),
		pane
	)
end)

-- Ensure new windows pick up the current theme
wezterm.on("window-created", function(window, _)
	if CURRENT_THEME then
		apply_theme_to_window(window, CURRENT_THEME)
	end
end)
wezterm.on("window-config-reloaded", function(window, _)
	if CURRENT_THEME then
		apply_theme_to_window(window, CURRENT_THEME)
	end
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

------------ Keybinds - Leader ----------
config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 2000 }

------------ Key tables ----------
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
		{ key = "b", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
		{ key = "v", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
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
  {
    key = "r",
    action = act.PromptInputLine({
      description = "Rename workspace to:",
      action = wezterm.action_callback(function(win, _pane, line)
        if not line then return end
        -- trim whitespace
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line == "" then return end

        local old = mux.get_active_workspace()
        if line == old then return end

        -- prevent accidental duplicate names
        local names = mux.get_workspace_names() or {}
        for _, n in ipairs(names) do
          if n == line then
            win:toast_notification("WezTerm", "Workspace name already exists", nil, 1600)
            return
          end
        end

        mux.rename_workspace(old, line)
        -- win:toast_notification("WezTerm", ("Workspace: %s → %s"):format(old, line), nil, 1500)
      end),
    }),
  },
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
		key = "o",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = (overrides.window_background_opacity == 1.0) and 0.9 or 1.0
			window:set_config_overrides(overrides)
		end),
	},
}

-- Leader + f  → Open current directory in Windows Explorer
table.insert(config.keys, {
	key = "f",
	mods = "LEADER",
	action = wezterm.action_callback(function(window, pane)
		local uri = pane:get_current_working_dir()
		if not uri then
			window:toast_notification("WezTerm", "No working directory for this pane", nil, 1500)
			return
		end

		local s = tostring(uri)
		if s:match("^file://") then
			-- Convert file:// URI → Windows path
			local path = s:gsub("^file://", "")
			if path:match("^/[A-Za-z]:") then
				path = path:sub(1 + 1)
			end -- drop leading '/'
			path = path:gsub("/", "\\") -- normalize slashes
			wezterm.run_child_process({ "explorer.exe", path })
		else
			-- Remote (ssh://...) cannot be opened by Explorer directly
			window:toast_notification("WezTerm", "Remote cwd can't be opened in Explorer", nil, 2000)
		end
	end),
})

------ COLOR Keybinds ------

-- Leader + a : cycle themes
table.insert(config.keys, { key = "a", mods = "LEADER", action = act.EmitEvent("cycle-theme") })

-- Leader + A (Shift+a) : pick theme by name
table.insert(config.keys, { key = "A", mods = "LEADER", action = act.EmitEvent("pick-theme") })

------------ Size ----------
config.initial_cols = 80

return config

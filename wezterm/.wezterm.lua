local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

-- ---------- Render / perf ----------
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 1
config.prefer_egl = true
config.term = "xterm-256color"
config.status_update_interval = 200 -- refresh status frequently

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

wezterm.on("toggle-colorscheme", function(window, _pane)
  local overrides = window:get_config_overrides() or {}
  overrides.color_scheme = (overrides.color_scheme == "Zenburn") and "Cloud (terminal.sexy)" or "Zenburn"
  window:set_config_overrides(overrides)
end)

-- ---------- Status: left shows mode badge; right shows time | workspace | battery ----------
local function battery_text()
  local info = wezterm.battery_info()
  if not info or not info[1] then return "" end
  local b = info[1]
  local pct = math.floor((b.state_of_charge or 0) * 100 + 0.5)
  local state = (b.state or ""):lower()
  local glyph = state:find("charging") and "⚡" or (state:find("discharging") and "🔋" or "🔌")
  return string.format("%s %d%%", glyph, pct)
end

local function mode_badge(mode)
  -- Bright, obvious badge so it's impossible to miss
  local bg = "#d33682" -- magenta-ish
  if mode == "[WIN]" then bg = "#268bd2"      -- blue
  elseif mode == "[RESIZE]" then bg = "#b58900" -- yellow
  end
  return wezterm.format({
    { Background = { Color = bg } },
    { Foreground = { Color = "#0c0b0f" } },
    { Attribute = { Bold = true } },
    { Text = " " .. mode .. " " },
    { Background = { Color = "none" } },
    { Foreground = { Color = "none" } },
  })
end

wezterm.on("update-right-status", function(window, _pane)
  -- LEFT: active key-table indicator
  local kt = window:active_key_table()
  local mode =
      (kt == "leader" and "[LEADER]") or
      (kt == "window" and "[WIN]") or
      (kt == "resize" and "[RESIZE]") or
      ""
  if mode ~= "" then
    window:set_left_status(mode_badge(mode))
  else
    window:set_left_status("") -- clear when no mode
  end

  -- RIGHT: time | workspace | battery
  local time = wezterm.strftime("%Y-%m-%d %H:%M")
  local ws = mux.get_active_workspace() or "default"
  local batt = battery_text()
  window:set_right_status(wezterm.format({
    { Attribute = { Italic = true } },
    { Text = string.format(" %s  |   %s  |  %s ", time, ws, batt) },
  }))
end)

-- ---------- Broadcast helper (prompt → send one line to all panes in current tab) ----------
wezterm.on("broadcast_line_to_panes", function(window, pane)
  window:perform_action(
    act.PromptInputLine {
      description = "Broadcast one line to all panes in this tab",
      action = wezterm.action_callback(function(win, _p, line)
        if not line or #line == 0 then return end
        local tab = win:active_tab()
        if tab then
          for _, p in ipairs(tab:panes()) do
            p:send_text(line .. "\n")
          end
        end
      end),
    },
    pane
  )
end)

-- ---------- Key tables ----------
config.key_tables = {
  -- Pseudo-leader so WezTerm can expose active_key_table()
  leader = {
    -- leader → w → (b/v/q/p/h/j/k/l/z/a)
    { key = "w", action = act.ActivateKeyTable { name = "window", one_shot = true, timeout_milliseconds = 2000 } },
    -- leader → e => resize mode (h/j/k/l to resize; e or Esc to exit)
    { key = "e", action = act.ActivateKeyTable { name = "resize", one_shot = false } },
    -- Workspaces + Launcher/Palette
    { key = "s", action = act.ShowLauncherArgs { flags = "WORKSPACES|TABS|LAUNCH_MENU_ITEMS" } },
    { key = "p", action = act.ActivateCommandPalette },
    -- Search & Copy mode
    { key = "/", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "c", action = act.ActivateCopyMode },
    -- Save scrollback to file (Downloads/wezterm_scrollback_YYYYMMDD-HHMMSS.txt)
    {
      key = "y",
      action = wezterm.action_callback(function(window, pane)
        local ts = wezterm.strftime("%Y%m%d-%H%M%S")
        local home = os.getenv("USERPROFILE") or os.getenv("HOME") or "."
        local sep = package.config:sub(1,1)
        local dir = home .. sep .. "Downloads"
        local file = string.format("%s%swezterm_scrollback_%s.txt", dir, sep, ts)
        window:perform_action(act.SaveScrollbackToFile(file), pane)
      end),
    },
    { key = "Escape", action = "PopKeyTable" },
  },

  -- Window/pane management (leader → w)
  window = {
    -- Split side-by-side / top-bottom
    { key = "b", action = act.SplitPane { direction = "Right", size = { Percent = 50 } } },
    { key = "v", action = act.SplitPane { direction = "Down",  size = { Percent = 50 } } },
    -- Close pane
    { key = "q", action = act.CloseCurrentPane { confirm = true } },
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
    { key = "h", action = act.AdjustPaneSize({ "Left",  5 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down",  5 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up",    5 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "e", action = "PopKeyTable" },
    { key = "Escape", action = "PopKeyTable" },
  },
}

-- ---------- Global keys ----------
config.keys = {
  -- SHIFT+Space: enter pseudo-leader (2s)
  { key = "Space", mods = "SHIFT",
    action = act.ActivateKeyTable { name = "leader", one_shot = false, timeout_milliseconds = 2000 } },

  -- Color scheme toggle
  { key = "E", mods = "CTRL|SHIFT|ALT", action = act.EmitEvent("toggle-colorscheme") },

  -- Extra splits (kept)
  { key = "h", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
  { key = "v", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Down",  size = { Percent = 50 } }) },

  -- Debug overlay
  { key = "L", mods = "CTRL", action = act.ShowDebugOverlay },

  -- Opacity toggle
  {
    key = "O", mods = "CTRL|ALT",
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

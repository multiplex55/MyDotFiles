# Wezterm

The .config file goes to the following location

`%USERPROFILE%`

# WezTerm Cheatsheet

Place your config file as:

```
%USERPROFILE%\.wezterm.lua
```

# WezTerm Config — Cheat Sheet

## Overview

* **Shell:** PowerShell (`pwsh.exe -NoLogo`)
* **Leader:** `Shift + Space` → shows a `[LEADER]` badge (with spinner) while “armed”
* **Status bar:**

  * **Right:** **mode badge** (only when active) · `YYYY-MM-DD HH:MM |  <workspace> | 🔋/⚡ <battery%>`
  * **Left:** current folder (and remote host when over SSH)
* **Theme toggle:** `Ctrl + Shift + Alt + E` (Cloud ⇄ Zenburn)
* **Opacity toggle:** `Leader + o` (0.9 ⇄ 1.0)

---

## PowerShell setup for accurate CWD (required for CWD-based features)

WezTerm learns the pane’s current directory from **OSC 7** escape codes. PowerShell doesn’t emit these by default, so add this to your **PowerShell profile**:

```powershell
# Open your profile:
# notepad $PROFILE

function prompt {
  $p = $executionContext.SessionState.Path.CurrentLocation
  $osc7 = ""
  if ($p.Provider.Name -eq "FileSystem") {
    $ansi_escape = [char]27
    $provider_path = $p.ProviderPath -Replace "\\", "/"
    $osc7 = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}${ansi_escape}\"
  }
  "${osc7}PS $p$('>' * ($nestedPromptLevel + 1)) ";
}
```

**Why this matters:**

* Enables the **left status** to show the *correct* folder.
* Makes CWD-dependent keybinds (e.g., “open in Explorer”) work.
* For an immediate one-off test (no profile change), run in a pane:
  `wezterm cli set-working-directory .`

> Note: Remote panes (e.g., `ssh://…`) don’t map to local Explorer.

---

## Modes & Badges

* `[LEADER]` — while the leader is waiting for the next key
* `[WIN]` — Window actions key-table (one-shot)
* `[RESIZE]` — Resize mode (sticky until exit)
* `[COPY]`, `[SEARCH]` — show when built-ins are active

**Enter modes**

* `Leader + w` → **Window actions** (`[WIN]`, exits after one key)
* `Leader + e` → **Resize mode** (`[RESIZE]`, exit with `e` or `Esc`)

---

## Keybinds (most useful)

### Leader combos (present)

* `Leader + w` — enter **Window actions** (one-shot)
* `Leader + e` — enter **Resize** mode
* `Leader + s` — **Launcher** (Workspaces | Tabs | Launch Menu)
* `Leader + p` — **Command Palette**
* `Leader + /` — **Search** (current selection or empty)
* `Leader + c` — **Copy mode**
* `Leader + y` — Save scrollback to `Downloads\wezterm_scrollback_<timestamp>.txt`
* `Leader + r` — **Reload configuration**
* `Leader + o` — Toggle **window opacity**

### Leader combos (optional, add if you want)

* `Leader + f` — **Open current directory in Windows Explorer** *(requires OSC-7 via `$PROFILE` above)*

  > If you haven’t added this key yet, ask me and I’ll give you the exact snippet for your file.
* `Leader + d` — **Copy current directory** to clipboard *(optional utility key)*

### Window actions (inside `[WIN]`)

* `b` — Split **Right** 50%
* `v` — Split **Down** 50%
* `q` — **Close** pane (confirm)
* `p` — Pane **Select** overlay
* `z` — Toggle **Pane Zoom**
* `h / j / k / l` — Focus panes (Left/Down/Up/Right)
* `Esc` — Exit window actions

### Resize mode `[RESIZE]`

* `h / j / k / l` — Resize by 5 cells
* `e` or `Esc` — Exit

### Global (always available)

* `Ctrl + L` — **Debug overlay**
* `Ctrl + Shift + Alt + h` — Split **Right** 50%
* `Ctrl + Shift + Alt + v` — Split **Down** 50%
* `Ctrl + Shift + Alt + E` — Toggle **color scheme**

---

## Status Bar Details

* **Left:** Current working directory (plus SSH host if remote)
* **Right:** `[MODE]` (when active) · `YYYY-MM-DD HH:MM |  <workspace> | 🔋/⚡ <battery%>`
* Updates frequently for smooth badges/clock

---

## Tips

* **Workspaces:** Switch via `Leader + s` → **Workspaces** list. A workspace “closes” when **all** its tabs/windows are closed.
* **Fonts:** Install a Nerd Font (e.g., *FiraCode Nerd Font*) for full glyph coverage.

---

## Customize Quickly

* **Leader chord:** Edit `config.leader` near the top.
* **Default shell:** Set `config.default_prog`.
* **Battery/clock format:** Tweak inside `update-right-status`.
* **Colors:** Use `Ctrl + Shift + Alt + E` in-session, or set `config.color_scheme`.


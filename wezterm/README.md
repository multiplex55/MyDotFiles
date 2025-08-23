# Wezterm

The .config file goes to the following location

`%USERPROFILE%`


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

## Modes & Badges

* `[LEADER]` — while the leader is waiting for the next key
* `[WIN]` — Window actions key-table (one-shot)
* `[RESIZE]` — Resize mode (sticky until exit)
* `[COPY]`, `[SEARCH]` — show when built-ins are active

**Enter modes**

* `Leader + w` → **Window actions** (`[WIN]`, exits after one key)
* `Leader + e` → **Resize mode** (`[RESIZE]`, exit with `e` or `Esc`)

---

## Status Bar Details

* **Left:** Current working directory (plus SSH host if remote)
* **Right:** `[MODE]` (when active) · `YYYY-MM-DD HH:MM |  <workspace> | 🔋/⚡ <battery%>`
* Updates frequently for smooth badges/clock

---

## Keybinds (most useful)

### Leader combos

* `Leader + w` — enter **Window actions** (one-shot)
* `Leader + e` — enter **Resize** mode
* `Leader + s` — **Launcher** (Workspaces | Tabs | Launch Menu)
* `Leader + p` — **Command Palette**
* `Leader + /` — **Search** (current selection or empty)
* `Leader + c` — **Copy mode**
* `Leader + y` — Save scrollback to `Downloads\wezterm_scrollback_<timestamp>.txt`
* `Leader + r` — **Reload configuration**
* `Leader + d` — Copy **current directory** to clipboard (toast confirms)
* `Leader + o` — Toggle **window opacity**

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

## Tips

* **Workspaces:** Switch via `Leader + s` → **Workspaces** list. A workspace “closes” when all its tabs/windows are closed.
* **CWD on left:** Quick context when bouncing between projects/SSH.
* **Fonts:** Install a Nerd Font (e.g., *FiraCode Nerd Font*) for full glyph coverage.

---

## Customize Quickly

* **Leader chord:** Edit `config.leader` near the top.
* **Default shell:** Set `config.default_prog`.
* **Battery/clock format:** Tweak inside `update-right-status`.
* **Colors:** Use `Ctrl + Shift + Alt + E` in-session, or set `config.color_scheme`.


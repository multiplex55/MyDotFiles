# GitUI on Windows (wezterm + PowerShell)

A blazing-fast, keyboard-driven Git TUI that lives in your terminal. GitUI lets you stage/commit, push/fetch, manage branches, stash, browse logs, and diff — all from one screen. ([GitHub][1])

## Install (Windows)

```powershell
# WinGet (recommended)
winget install -e --id StephanDilly.gitui
# verify
gitui --version
```

The project also lists `winget install gitui` as a valid command; either works depending on your source metadata. ([Winstall][2], [GitHub][1])

## Add a PowerShell helper (open at repo root)

Append this to your PowerShell profile:

```powershell
# Open GitUI at the repo's top-level (falls back to current dir)
function gitui-root {
  $orig = Get-Location
  $top  = git rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -eq 0 -and $top) { Set-Location $top }
  gitui
  Set-Location $orig
}
Set-Alias gui gitui-root   # so you can just run: gui
```

> Tip: Your profile is usually at `$PROFILE` (e.g., `C:\Users\<you>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`).

## Quick start (90 seconds)

* **Launch:** `gitui` (or `gui` from the helper above) inside any Git repo.
* **Navigate:** Arrow keys (or `hjkl` if you enable the optional vim-style mapping). GitUI shows context actions and hotkeys along the bottom, so you don’t need to memorize much. ([DEV Community][3], [Linux Uprising Blog][4])
* **Stage & commit:**

  1. In the *Staging* view, select a changed file.
  2. Press **Enter** to toggle stage for that file. ([DEV Community][3])
  3. Use the on-screen **Commit** action (hotkey shown in the status bar), type your message, confirm.
* **Push / Fetch:** Use the **Push** / **Fetch** actions from the main UI (hotkeys shown at the bottom bar). Make sure your branch tracks a remote (first push may prompt to set upstream). Features listed in the README include push/fetch to/from remotes. ([GitHub][1])
* **Branches:** Open the *Branches* view from the top tabs to create, rename, delete, or check out branches (including remotes). It’s built in and discoverable in the UI. ([GitHub][1])
* **Diffs & stashing:** View diffs, stage per hunk/line, and stash (save/apply/drop) — all from the TUI. ([GitHub][1])

## Optional: vim-style keys

If you prefer `hjkl`, GitUI ships a sample config you can copy as your keymap:

* Copy `vim_style_key_config.ron` into your GitUI config directory as `key_bindings.ron` (run GitUI once to have the folder created; on Windows this is typically under your roaming AppData).
* This enables vim-like navigation; you can customize further. ([DEV Community][3], [Crates][5])

## Troubleshooting

* **Logging:** `gitui -l` writes a log you can inspect at `%LOCALAPPDATA%\gitui\gitui.log` on Windows. ([GitHub][1])
* **Credentials:** GitUI uses your existing Git remotes and credential helpers (HTTPS or SSH); ensure `git` commands work in the same shell.

---

[1]: https://github.com/gitui-org/gitui "GitHub - gitui-org/gitui: Blazing  fast terminal-ui for git written in rust "
[2]: https://winstall.app/apps/StephanDilly.gitui?utm_source=chatgpt.com "Install gitui with winget"
[3]: https://dev.to/waylonwalker/gitui-is-a-blazing-fast-terminal-git-interface-32nd?utm_source=chatgpt.com "Gitui is a blazing fast terminal git interface"
[4]: https://www.linuxuprising.com/2021/08/gitui-017-adds-ability-to-compare.html?utm_source=chatgpt.com "GitUI 0.17 Adds The Ability To Compare Commits, New ..."
[5]: https://crates.io/crates/gitui/0.12.0-rc1?utm_source=chatgpt.com "gitui - crates.io: Rust Package Registry"






# Yazi on Windows (WezTerm/PowerShell) — Quick Start

Blazing-fast TUI file manager with previews, bulk copy/move, and **smart “cd back to shell”** on exit.

## Install

**Via WinGet (recommended)**

```powershell
winget install sxyazi.yazi
```

**Via Cargo (builds the CLI + FM)**

```powershell
cargo install --force yazi-build
```

> After install, restart WezTerm once so PATH updates are picked up.

---

## Enable file-type detection (Windows)

Yazi uses the Unix `file` tool on Windows. Since Git for Windows bundles it, just point Yazi to it.

```powershell
# One-time, persistent:
[Environment]::SetEnvironmentVariable(
  'YAZI_FILE_ONE',
  'C:\Program Files\Git\usr\bin\file.exe',
  'User'
)

# (Optional) Verify:
$Env:YAZI_FILE_ONE
```

> If Git is installed elsewhere, adjust the path accordingly. Restart WezTerm after setting it.

---

## Make `y` change your shell’s directory

Create a small wrapper so leaving Yazi updates your **current pane’s CWD**.

1. Open your PowerShell profile:

```powershell
notepad $PROFILE
```

2. Add this function and save:

```powershell
function y {
  $tmp = (New-TemporaryFile).FullName
  yazi $args --cwd-file="$tmp"
  if (Test-Path $tmp) {
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if ($cwd) { Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path }
    Remove-Item -Path $tmp -Force
  }
}
```

3. Reload your profile (or open a new pane):

```powershell
. $PROFILE
```

Use **`y`** (not `yazi`) to launch. Press **`q`** to quit back to the shell in the folder you navigated to.

---

## Open files with **Neovim** or **Notepad**

Yazi looks for config in **`%AppData%\yazi\config\yazi.toml`** on Windows.

1. Create the folder:

```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\yazi\config" | Out-Null
```

2. Create/edit **`%AppData%\yazi\config\yazi.toml`** with this minimal config:

```toml
# %AppData%\yazi\config\yazi.toml

[opener]
nvim = [
  { run = "nvim %*", block = true, for = "windows", desc = "Neovim" },
]
notepad = [
  { run = "notepad.exe %*", orphan = true, for = "windows", desc = "Notepad" },
]
open = [
  { run = 'cmd /c start "" %*', orphan = true, for = "windows", desc = "Open (default app)" },
]

[open]
# Replace defaults so the chooser shows Neovim/Notepad
rules = [
  { mime = "text/*", use = ["nvim", "notepad", "open"] },
  { name = "*.toml", use = ["nvim", "notepad", "open"] },
  { name = "*",      use = ["open"] },
]
```

**How it behaves**

* **Enter** on a text file → opens in **Neovim** (blocks Yazi until you `:q`).
* **Shift+Enter** (or `O`) → **Open with** menu: pick **Neovim**, **Notepad**, or **Open (default app)**.

---

## Quick usage (the 90% you’ll use)

* **Arrows / `j` `k`** – move up/down
* **`Enter` / `l`** – open file / enter directory
* **`h` / `Backspace`** – go up a directory
* **`.`** – toggle hidden files
* **`a`** – create (end with `/` to create a folder)
* **`r`** – rename
* **`d`** – delete (to Recycle Bin if you use a trash tool; otherwise permanent)
* **`y` / `x` / `p`** – copy / cut / paste
* **`Shift+Enter` (or `O`)** – choose an opener (Neovim, Notepad, etc.)
* **`q`** – quit back to the shell (with the `y` wrapper, your shell CWD changes)

Tip: multi-select with **Space**, then copy/cut/paste.

---

## Troubleshooting

* You still see “code / code (block) / Reveal / Open” in the opener list
  → Your config isn’t being read. Make sure the file is at **`%AppData%\yazi\config\yazi.toml`** and that you used the **`[open].rules`** block above (which replaces defaults).

* Text files don’t open with your rules
  → Verify `YAZI_FILE_ONE` is set correctly and restart WezTerm:

  ```powershell
  $Env:YAZI_FILE_ONE
  ```

* The shell doesn’t change directory after quitting
  → Launch with **`y`** (the wrapper), not `yazi`. Re-source your profile: `. $PROFILE`.

---

**That’s it.** You now have Yazi installed, files opening in **Neovim** or **Notepad**, and a `y` command that makes Yazi behave like a “graphical cd” inside WezTerm.


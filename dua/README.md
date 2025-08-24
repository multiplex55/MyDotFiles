# dua (Disk Usage Analyzer) — Windows Quick Start

`dua` is a fast, Rust-based disk usage tool. It can print a quick size summary **or** launch an interactive TUI to explore and clean space.

---

## Install (Windows)

### With Cargo (recommended)

```powershell
# Enable the cross-platform TUI on Windows
cargo install dua-cli --no-default-features --features tui-crossplatform
```

> Make sure Cargo’s bin folder is on PATH:
>
> ```
> %USERPROFILE%\.cargo\bin
> ```
>
> If needed, add this to your PowerShell profile:
>
> ```powershell
> $env:Path += ";$HOME\.cargo\bin"
> ```

### Verify

```powershell
dua --version
```

---

## Everyday Use

### Quick one-liners (non-interactive)

```powershell
# Show sizes of the current folder and its subfolders
dua .

# Analyze a specific path
dua D:\Projects

# Summarize multiple roots at once
dua C:\Users\multi D:\Media
```

### Interactive TUI (space hunting & cleanup)

```powershell
dua i
# or analyze a specific path
dua i D:\Downloads
```

**Common keys (inside TUI):**

* **↑/↓** – move selection
* **Enter** – drill into directory
* **Backspace** – go up
* **Space** – (multi)select item(s)
* **Del** – delete selected (permanent!)
* **q** – quit
* **?** – show help / all keybinds

> Tip: Start at a drive root (e.g., `dua i C:\`) to find the biggest offenders fast.

---

## Handy PowerShell alias (optional)

Put this in your PowerShell profile (`%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) to open the TUI with a short command:

```powershell
function di { dua i @Args }   # now run: di, di C:\, di D:\Downloads
```

Reload:

```powershell
. $PROFILE
```

---

## Notes

* **Deletes are permanent** (no Recycle Bin). Review selections carefully before pressing **Del**.
* Run your terminal **as Administrator** if you need to inspect/delete protected folders.
* Uninstall: `cargo uninstall dua-cli`.

# Scoop

# How to Install and Use Scoop (Windows)

Scoop is a command-line installer for Windows that manages portable apps without requiring administrator permissions (for standard installs).

---

## 1) Prerequisites

- **PowerShell 5.1+** (included with modern Windows 10/11)
- **.NET Framework 4.5+** (typically present by default)

---

## 2) Installation

### 2.1 Enable RemoteSigned for the current user
Allows running local signed scripts and downloaded scripts.

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

When prompted, type **Y** and press **Enter**.

### 2.2 Run the Scoop installer
```powershell
irm get.scoop.sh | iex
```

This installs Scoop under your user profile (`~/scoop`).

---

## 3) Basic Usage

### Install a package
```powershell
scoop install git
```

### Search for packages
```powershell
scoop search vlc
```

### List installed packages
```powershell
scoop list
```

### Uninstall a package
```powershell
scoop uninstall git
```

---

## 4) Advanced Features

### Add the “extras” bucket
Buckets are repositories of app manifests.

```powershell
scoop bucket add extras
```

### Update Scoop and apps
```powershell
# Update Scoop and bucket manifests
scoop update

# Update all installed applications
scoop update *
```

### Open an app’s homepage
```powershell
scoop home git
```

### Check for potential issues
```powershell
scoop checkup
```

---

## 5) Why use Scoop?

- **No Admin Needed:** Installs to your user directory.
- **Portable:** Minimal impact on system folders, registry, and PATH.
- **Clean Uninstalls:** Easy removal without leftover files.
- **Minimalist & Fast:** Simple CLI workflow for dev tools and utilities.


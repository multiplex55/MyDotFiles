# apps_launcher.py
from talon import Module, actions, ui
import os
import platform
import subprocess

mod = Module()

# Per-app config: spoken name -> {exe, path}
# exe  = process name to look for in ui.apps()
# path = how to launch it if not running
APP_CONFIG = {
    "code": {
        "exe": "Code.exe",
        "path": r"C:\Users\multi\AppData\Local\Programs\Microsoft VS Code\Code.exe",
    },
    "multi manager": {
        "exe": "MultiManager.exe",
        "path": r"C:\Tools\MultiManager\MultiManager.exe",
    },
    "obsidian": {
        "exe": "Obsidian.exe",
        "path": r"C:\Users\multi\AppData\Local\Programs\Obsidian\Obsidian.exe",
    },
    "discord kill": {
        "exe": "StopDiscord.exe",
        "path": r"C:\Tools\TalonApps\discord_scripts\StopDiscord.exe",
    },
    "discord start": {
        "exe": "RestartDiscord.exe",
        "path": r"C:\Tools\TalonApps\discord_scripts\RestartDiscord.exe",
    },
    "github desktop": {
        "exe": "GithubDesktop.exe",
        "path": r"C:\Users\multi\AppData\Local\GitHubDesktop\GitHubDesktop.exe",
    },
}

FOLDER_PATHS = {
    "tools": r"C:\Tools",
    "workspace": r"C:\Workspaces",
    "downloads": r"C:\Users\multi\Downloads",
}


def _open_path(path: str):
    """Open a file/folder in the system file manager."""
    system = platform.system()
    if system == "Windows":
        os.startfile(path)
    elif system == "Darwin":
        subprocess.Popen(["open", path])
    else:
        subprocess.Popen(["xdg-open", path])


def _focus_existing_app(spoken_name: str) -> bool:
    """
    Try to focus an already-running app for this spoken name.
    Returns True if we focused something, False otherwise.
    """
    cfg = APP_CONFIG.get(spoken_name)
    exe_hint = None
    if cfg:
        exe_hint = cfg.get("exe")
        if exe_hint:
            exe_hint = exe_hint.lower()

    # Scan all running apps
    for app in ui.apps():
        if app.background:
            continue

        # Prefer exe match if we have one
        if exe_hint and app.exe and app.exe.lower().endswith(exe_hint):
            app.focus()
            return True

        # Fallback: fuzzy match by window title
        if spoken_name.lower() in app.name.lower():
            app.focus()
            return True

    return False


@mod.action_class
class Actions:
    def launch_app(spoken_name: str):
        """ALWAYS launch app, ignoring whether it's already running."""
        cfg = APP_CONFIG.get(spoken_name)
        if not cfg or not cfg.get("path"):
            actions.app.notify(
                title="Launcher",
                subtitle="Unknown app",
                body=f"No launch command for: {spoken_name}",
                sound=True,
            )
            return

        path = cfg["path"]
        # On Windows, this will happily launch EXEs by path
        if platform.system() == "Windows":
            os.startfile(path)
        else:
            subprocess.Popen([path])

    def launch_or_focus_app(spoken_name: str):
        """Focus app if running; otherwise launch it."""
        cfg = APP_CONFIG.get(spoken_name)
        if not cfg:
            actions.app.notify(
                title="Launcher",
                subtitle="Unknown app",
                body=f"No config for: {spoken_name}",
                sound=True,
            )
            return

        # 1) Try to focus an existing window
        if _focus_existing_app(spoken_name):
            return

        # 2) Nothing found → launch it
        path = cfg.get("path")
        if not path:
            actions.app.notify(
                title="Launcher",
                subtitle="Missing path",
                body=f"No path configured for: {spoken_name}",
                sound=True,
            )
            return

        if platform.system() == "Windows":
            os.startfile(path)
        else:
            subprocess.Popen([path])

    def open_folder(spoken_name: str):
        """Open a folder in the system file manager by spoken name."""
        path = FOLDER_PATHS.get(spoken_name)
        if not path:
            actions.app.notify(
                title="Launcher",
                subtitle="Unknown folder",
                body=f"No folder path for: {spoken_name}",
                sound=True,
            )
            return
        _open_path(path)

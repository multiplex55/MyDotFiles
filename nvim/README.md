# kickstart.nvim

## Introduction

A starting point for Neovim that is:

* Small
* Single-file
* Completely Documented

**NOT** a Neovim distribution, but instead a starting point for your configuration.

## UI enhancements

This fork bundles [folke/noice.nvim](https://github.com/folke/noice.nvim) to modernize the
command line, popup menus, and Neovim's built-in `vim.ui.input`/`vim.ui.select` prompts.
The plugin is lazy-loaded and picks up your notify configuration to present polished
floating windows for helper workflows like Koto, Rhai, and AutoHotkey.
When the Noice-powered command-line menu offers a suggestion you want to accept, press
`<C-y>` to confirm it explicitly. The `<CR>` key now always runs the exact command you
typed, so you can continue working muscle memory for write/quit commands like `:w` or
`:wq` without having to dismiss completion entries first.

## Custom Keymaps

### Folding defaults

Buffers now start with Treesitter-powered expression folds enabled (`foldmethod=expr`),
so commands like `zc` and `zo` operate on syntax-aware regions instead of manual markers.
The default fold level is raised to keep files open on first load, so you can still drill
into nested sections only when you need them. If you relied on creating manual folds, use
`zf` to define them per buffer or switch the method back temporarily with `:setlocal foldmethod=manual`.

### Rust tools

| Shortcut | Action |
| --- | --- |
| `<leader>crd` | Generate a docstring for the Rust item under the cursor with `:RustDocstring`. |
| `<leader>crD` | Insert docstrings for every supported Rust item in the current buffer via `:RustDocstringAllKinds`. |
| `<leader>crr` | Open the `RustLsp runnables` picker. |
| `<leader>crp` | Jump to the parent module using `RustLsp parentModule`. |
| `<leader>crm` | Expand the macro call at the cursor through `RustLsp expandMacro`. |
| `<leader>ccD` | Ask `crates.nvim` to open the metadata popup for the crate under the cursor, giving you version, feature, and documentation links without leaving the manifest. |
| `<leader>ccU` | Upgrade the crate at the cursor directly to the newest release on crates.io, rewriting the dependency specification to match the latest published version. |
| `<leader>ccu` | Update the crate at the cursor only within the current semver requirement, keeping compatibility while bumping to the most recent allowed version. |

### Navigation

| Shortcut | Action |
| --- | --- |
| `s` / `S` | Trigger `flash.nvim` jump navigation or the Treesitter-powered variant without overriding native `f` / `t` motions. |
| `<leader>hf` | Start a `flash.nvim` jump while staying alongside the existing Hop leader mappings. |
| `<leader>hF` | Launch the Treesitter-based Flash search from the hop leader group. |
| `<leader>tD` | Duplicate the current tab, cloning the entire window layout and buffers using the TabScope integration. |

> See [`tests/manual/tab-duplication.md`](tests/manual/tab-duplication.md) for a quick manual regression checklist covering the tab duplication workflow.

### Comment toggles

| Shortcut | Action |
| --- | --- |
| `gcc` | Toggle a line comment for the current line. |
| `gbc` | Toggle a block comment surrounding the current line when supported. |
| `gc{motion}` | Comment the text covered by the following motion using Treesitter-aware delimiters. |

### Macro management

| Shortcut | Source | Action |
| --- | --- | --- |
| `q` | NeoComposer | Toggle macro recording on and off, saving the captured macro when you stop. |
| `Q` | NeoComposer | Play the queued macro immediately (respecting the delay toggle when enabled). |
| `cq` | NeoComposer | Halt the currently playing macro loop. |
| `yq` | NeoComposer | Yank the queued macro into the unnamed, clipboard, and system registers. |
| `<C-n>` | NeoComposer | Queue the next macro in your stored list. |
| `<C-p>` | NeoComposer | Queue the previous macro in your stored list. |
| `<M-q>` | NeoComposer | Toggle the floating macro menu window. |
| `<leader>qm` | Leader | Toggle the NeoComposer macro menu from the leader macro group. |
| `<leader>qe` | Leader | Open the editable NeoComposer macro buffer (`:EditMacros`). |
| `<leader>qd` | Leader | Toggle playback delay for macros (`:ToggleDelay`). |
| `<leader>qs` | Leader | Halt macro playback via the NeoComposer macro module. |
| `<leader>sm` | Telescope | Launch the Telescope macros picker for browsing and selecting stored macros. |

## Installation

### Install Neovim

Kickstart.nvim targets *only* the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have the latest versions.

### Install External Dependencies

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
- Clipboard tool (xclip/xsel/win32yank or other depending on platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `vim.g.have_nerd_font` in `init.lua` to true
- Language Setup:
  - If you want to write Typescript, you need `npm`
  - If you want to write Golang, you will need `go`
  - etc.

> **NOTE**
> See [Install Recipes](#Install-Recipes) for additional Windows and Linux specific notes
> and quick install snippets

### Install Kickstart

> **NOTE**
> [Backup](#FAQ) your previous configuration (if any exists)

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :- | :--- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%localappdata%\nvim\` |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\` |

#### Recommended Step

[Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
so that you have your own copy that you can modify, then install by cloning the
fork to your machine using one of the commands below, depending on your OS.

> **NOTE**
> Your fork's url will be something like this:
> `https://github.com/<your_github_username>/kickstart.nvim.git`

You likely want to remove `lazy-lock.json` from your fork's `.gitignore` file
too - it's ignored in the kickstart repo to make maintenance easier, but it's
[recommmended to track it in version control](https://lazy.folke.io/usage/lockfile).

#### Clone kickstart.nvim
> **NOTE**
> If following the recommended step above (i.e., forking the repo), replace
> `nvim-lua` with `<your_github_username>` in the commands below

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/nvim-lua/kickstart.nvim.git "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/nvim-lua/kickstart.nvim.git "${env:LOCALAPPDATA}\nvim"
```

</details>

### Post Installation

Start Neovim

```sh
nvim
```

That's it! Lazy will install all the plugins you have. Use `:Lazy` to view
current plugin status. Hit `q` to close the window.

Read through the `init.lua` file in your configuration folder for more
information about extending and exploring Neovim. That also includes
examples of adding popularly requested plugins.


### Getting Started

[The Only Video You Need to Get Started with Neovim](https://youtu.be/m8C0Cq9Uv9o)

### FAQ

* What should I do if I already have a pre-existing neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to kickstart?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-kickstart` and create an alias:
    ```
    alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
    ```
    When you run Neovim using `nvim-kickstart` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-kickstart`. You can apply this approach to any Neovim
    distribution that you would like to try out.
* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling) information
* Why is the kickstart `init.lua` a single file? Wouldn't it make sense to split it into multiple files?
  * The main purpose of kickstart is to serve as a teaching tool and a reference
    configuration that someone can easily use to `git clone` as a basis for their own.
    As you progress in learning Neovim and Lua, you might consider splitting `init.lua`
    into smaller parts. A fork of kickstart that does this while maintaining the 
    same functionality is available here:
    * [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim)
  * Discussions on this topic can be found here:
    * [Restructure the configuration](https://github.com/nvim-lua/kickstart.nvim/issues/218)
    * [Reorganize init.lua into a multi-file setup](https://github.com/nvim-lua/kickstart.nvim/pull/473)

### Install Recipes

Below you can find OS specific install instructions for Neovim and dependencies.

After installing all the dependencies continue with the [Install Kickstart](#Install-Kickstart) step.

#### Windows Installation

<details><summary>Windows with Microsoft C++ Build Tools and CMake</summary>
Installation may require installing build tools and updating the run command for `telescope-fzf-native`

See `telescope-fzf-native` documentation for [more details](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation)

This requires:

- Install CMake and the Microsoft C++ Build Tools on Windows

```lua
{'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
```
</details>
<details><summary>Windows with gcc/make using chocolatey</summary>
Alternatively, one can install gcc and make which don't require changing the config,
the easiest way is to use choco:

1. install [chocolatey](https://chocolatey.org/install)
either follow the instructions on the page or use winget,
run in cmd as **admin**:
```
winget install --accept-source-agreements chocolatey.chocolatey
```

2. install all requirements using choco, exit previous cmd and
open a new one so that choco path is set, and run in cmd as **admin**:
```
choco install -y neovim git ripgrep wget fd unzip gzip mingw make
```
</details>
<details><summary>WSL (Windows Subsystem for Linux)</summary>

```
wsl --install
wsl
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>

#### Linux Install
<details><summary>Ubuntu Install Steps</summary>

```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip curl

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim-linux64
sudo mkdir -p /opt/nvim-linux64
sudo chmod a+rX /opt/nvim-linux64
sudo tar -C /opt -xzf nvim-linux64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/
```
</details>
<details><summary>Fedora Install Steps</summary>

```
sudo dnf install -y gcc make git ripgrep fd-find unzip neovim
```
</details>

<details><summary>Arch Install Steps</summary>

```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd unzip neovim
```
</details>


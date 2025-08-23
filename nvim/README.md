# Neovim Config — Feature Overview

A fast, Windows-friendly Neovim setup focused on **productive coding (Rust-first), smooth navigation, smart search/replace, tasks & debugging**, and a clean UI. It’s modular (Lazy.nvim) and easy to extend.

---

## Quick Start

1. **Requirements**

   * Neovim 0.9+ (0.10+ recommended)
   * Git, a Nerd Font (e.g. FiraCode Nerd Font)
   * On Windows/Neovide: see `config/neovide/config.toml` for font/size

2. **Install**

   * Place this repo as your config (e.g. `~\AppData\Local\nvim` on Windows).
   * Launch Neovim → Lazy.nvim will sync plugins.
   * `:Mason` to install LSPs/formatters/debuggers as needed.

3. **Pick a theme**

   * Default is **Tokyonight Night**. Catppuccin and other dark themes are available (see `custom/plugins/*-themes.lua`).
   * Toggle/choose in-session or set in `init.lua`.

---

## Headline Features

### Start & Session UX

* **Snacks Dashboard** on startup with: recent files, projects, git status, handy actions.
* **Sessions**: auto-session + session-lens for quick session search/restore (no auto-restore on boot).

### Navigation & Files

* **Oil.nvim** (directory-as-a-buffer) with a custom winbar; `-` to open parent dir, `<space>-` for floating Oil.
* **Telescope** + FZF & UI Select: files, grep, buffers, LSP symbols, diagnostics, and more.
* **Which-key** labels every leader group and mapping.

### Buffers, Tabs, Windows

* **barbar.nvim** smart bufferline: pin, reorder, sort by dir/lang, pick by letter.
* **Window picker** and **winresizer**; consistent `<leader>w…` moves/resizes.

### LSP, Completion, UI polish

* **Mason** + **LSPConfig** – one-stop install/manage.
* **nvim-cmp** + LuaSnip + friendly-snippets.
* **lspsaga** for code actions, finder, symbol-in-winbar, nicer UI.
* **lsp-lines**, **nvim-notify**, **devicons**, **lualine**, rainbow indents/delimiters.

### Formatting, Search/Replace

* **Conform** for on-demand formatting (`<leader>fb`).
* **Spectre** for project-wide search/replace (`<leader>srs`, etc.).

### Git Toolkit

* **gitsigns** (inline hunks, blame, stage/reset)
* **Neogit** (magit-like UI), **Diffview**, **mini.diff** overlay
* Snacks Git status on the dashboard.

### Tasks & Term

* **Overseer** task runner with rich keybinds (build/run/test pipelines, cached bundles).
* **toggleterm** optional strategy; terminal workflow integrated with Overseer.

### Debugging (Rust-ready)

* **nvim-dap** + **dap-ui** + **codelldb** (Mason path wired) with Rust-specific LLDB defaults.
* Rust debugging just works: breakpoints, expressions, repl, scopes, code lenses.

### Language Focus

* **Rust**: rustaceanvim with tuned rust-analyzer settings; DAP preconfigured.
* **Markdown/Notes**: render-markdown.nvim for live, minimal rendering; **obsidian.nvim** integration.
* **Nim**: a helper to compile/run the current Nim file in a new tab (see keybinds).

---

## Keybinding Conventions (high level)

> Use `Space` as `<leader>`. Which-key will show the menus live.

### Search `[S]`

* Files, live grep, buffers, help, keymaps, diagnostics, quickfix lists, etc. via Telescope.
* `[/]` fuzzy search in current buffer (dropdown theme).

### Windows `[w]`

* Move: `<leader>wh/wj/wk/wl`
* Split: `<leader>wv` (vertical), `<leader>wb` (horizontal)
* Close: `<leader>wq`
* Picker: `<leader>wp` (jump to window by letter)

### Tabs/Buffers `[t]` (barbar)

* Next/Prev: `<Tab>` / `<S-Tab>`
* Pin: `<leader>tp`
* Close: `<leader>tq`, close others/left/right (`to`, `tl`, `tr`)
* Reorder: `tm`/`tM`; Sort: `tsd` (dir) / `tsl` (lang)
* Pick by letter: `tt`; New tab: `tn`; Close tab: `tc`
* Delete buffer (soft/force): `td` / `tD`

### Code & Build `[C]`

* **Rust Cargo group** under `[C]ode [C]argo`:

  * Run/Release: `ccr` / `ccR`
  * Build/Release: `ccb` / `ccB`
  * Test: `cct` (with options baked in)
  * Check, Clippy, Fmt, Doc, Update: `ccC`, `ccl`, `ccf`, `ccd`, `ccu`
* **Format buffer**: `<leader>fb` (Conform)
* Zig inlay hints toggle: `czi` (fallback toggles if LSP API differs)

### Hop `[h]` (motions)

* Words/Lines/Char: `hw`, `hl`, `hc`, `hC`
* Multi-window words: `hW` (search across windows)

### Git `[G]`

* Neogit: `Gn`
* Diffview: `Gd`
* Mini.diff overlay: `GD`

### Overseer `[o]`

* Toggle/List/Run/Stop: `oo`, `or`, `oS`, `oT`
* Clear/Save/Load/Delete bundles: `oc`, `os`, `ol`, `od`
* Build Tasks: `ob`
* Quick Action: `oq`

### Spectre (Search/Replace) `[sr…]`

* Toggle: `srs`
* Visual/Word: `srv`, `srw`
* Current file: `src`

### Utilities

* **Nim run (release)** current file in a tab: `<leader>npr`
* **Debug overlay**: `Ctrl-L`

> Note: Some chords may be adjusted by your local edits; use **which-key** to discover the authoritative map at any time.

---

## UI & Theming

* **Tokyonight Night** default; Catppuccin and a curated set of dark themes available.
* **Lualine** statusline; **notify** popups; **precognition** assists motion choices.
* Indentation guides with rainbow, bracket colorization, file icons everywhere.

---

## Windows-friendly Details

* **Neovide** settings in `config/neovide/config.toml` (font = *FiraCode Nerd Font*, size = 12).
* **Path-case fix** (`custom/windows_uri_fix.lua`): keeps drive letters normalized (e.g., `C:` vs `c:`).
* Most tools default to PowerShell and Windows paths; adjust as desired in plugin configs.

---

## Rust Extras

* `rustaceanvim` tuned for performance (reduced proc-macros/build scripts, filtered targets).
* DAP prewired to Mason’s `codelldb`; injects handy LLDB settings (Rust language mode, inline breakpoint strategy).
* Optional **rustdocstring** helper plugin (Treesitter-based) to scaffold Rust doc comments with `# Arguments`, `# Returns`, `# Safety`, etc.

---

## Markdown & Notes

* **render-markdown.nvim**: clean inline rendering (headings, lists, tables).
* **obsidian.nvim**: vault workflows, backlinks, and templates from inside Neovim.

---

## Tasks & Term

* **Overseer** defaults to terminal strategy with horizontal layout, smart window focus when tasks start.
* Great for per-project scripts (build, run, test). Save/load **bundles** of tasks.

---

## Customize Quickly

* **Leader**: set in `init.lua` (`vim.g.mapleader = ' '`).
* **Themes**: change in `init.lua` or use the theme switcher mapping if you added one.
* **Formatters/Linters**: tweak **Conform** sources in `custom/plugins/conform.lua`.
* **LSP servers**: install via `:Mason` and configure overrides in `custom/plugins/mason.lua` / project configs.
* **Dashboard**: adjust Snacks sections/keys in `custom/plugins/snacks.lua`.
* **Oil** keymaps/columns in `custom/plugins/oil.lua`.
* **Overseer** strategies/layout in `custom/plugins/overseer.lua`.

---

## Tips

* If a key doesn’t behave as expected, press `<leader>` and pause—**which-key** will reveal the available sub-maps and descriptions.
* Keep `lazy-lock.json` committed to pin versions; run `:Lazy sync` after plugin changes.
* For language servers/formatters/debuggers, use `:Mason` first, then re-open a file to attach LSP/DAP.


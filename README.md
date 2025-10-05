# MyDotFiles



MyDotFiles



* Wezterm
* Neovim
  * Statusline configuration lives in `nvim/lua/custom/plugins/lualine.lua`. If you
    prefer the lightweight `mini.statusline`, set `vim.g.custom_enable_mini_statusline = true`
    before the plugin manager loads to activate the fallback configuration in
    `nvim/lua/custom/plugins/mini.lua`.
  * Debug breakpoint signs now follow the `kickstart.nvim` approach: Nerd Font glyphs are
    used when `vim.g.have_nerd_font` is truthy, and simple Unicode icons are used otherwise so
    the gutter always shows a visible marker. We automatically fall back to the Unicode set when
    a WezTerm TUI is detected (some setups still hide private-use glyphs there); set
    `vim.g.custom_dap_force_nerd_font = true` before loading plugins if you want to force the
    Nerd Font icons even in that environment.

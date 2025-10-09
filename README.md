# MyDotFiles



MyDotFiles



* Wezterm
* Neovim
  * Statusline configuration lives in `nvim/lua/custom/plugins/lualine.lua`. If you
    prefer the lightweight `mini.statusline`, set `vim.g.custom_enable_mini_statusline = true`
    before the plugin manager loads to activate the fallback configuration in
    `nvim/lua/custom/plugins/mini.lua`.

## Custom Keymaps

### Bookmarks

| Keymap | Description |
| --- | --- |
| `<leader>bm` | Toggle a bookmark at the current location. |
| `<leader>bg` | Open the bookmark picker to jump to a saved location. |
| `<leader>bl` | Choose an alternate bookmark list. |
| `<leader>bt` | Toggle the bookmark tree view. |
| `<leader>bn` / `<leader>bp` | Jump to the next or previous bookmark in the current buffer. |
| `<leader>bR` | Remove the bookmark at the current location. |
| `<leader>bN` / `<leader>bP` | Jump to the next or previous bookmark following list order. |
| `<leader>bG` | Search across bookmarks with Telescope. |
| `<leader>bc` | Access bookmark command shortcuts. |
| `<leader>bd` | Attach or edit the bookmark description. |
| `<leader>bi` | Show bookmark plugin information. |
| `<leader>bI` | Display information about the current bookmark. |

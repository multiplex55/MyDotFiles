return {
  {
    'LintaoAmons/bookmarks.nvim',
    tag = '3.2.0',
    cmd = {
      'BookmarksMark',
      'BookmarksGoto',
      'BookmarksTree',
      'BookmarksLists',
      'BookmarksCommands',
      'BookmarksGrep',
      'BookmarksInfo',
      'BookmarksInfoCurrentBookmark',
      'BookmarksGotoNext',
      'BookmarksGotoPrev',
      'BookmarksGotoNextInList',
      'BookmarksGotoPrevInList',
      'BookmarksDesc',
      'BookmarkRebindOrphanNode',
    },
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
      { 'stevearc/dressing.nvim', optional = true },
    },
    opts = function()
      local default_config = require('bookmarks.config').default_config
      local opts = vim.deepcopy(default_config)

      opts.signs = opts.signs or {}
      local mark_sign = vim.tbl_deep_extend('force', {}, opts.signs.mark or {})

      mark_sign.icon = (vim.g.have_nerd_font and '󰃁') or '🔖'

      local ok, hint_hl = pcall(vim.api.nvim_get_hl, 0, { name = 'DiagnosticHint', link = false })
      if ok and hint_hl then
        local fg = hint_hl.fg or hint_hl.foreground
        if type(fg) == 'number' then
          fg = string.format('#%06x', fg)
        elseif type(fg) == 'string' and not fg:match('^#') then
          local num = tonumber(fg)
          if num then
            fg = string.format('#%06x', num)
          end
        end

        if type(fg) == 'string' and fg ~= '' then
          mark_sign.hl = mark_sign.hl or {}
          mark_sign.hl.fg = fg
        end
      end

      mark_sign.line_bg = nil

      opts.signs.mark = mark_sign

      return opts
    end,
    config = function(_, opts)
      require('bookmarks').setup(opts)

      local ok, telescope = pcall(require, 'telescope')
      if ok and telescope.load_extension then
        pcall(telescope.load_extension, 'bookmarks')
      end
    end,
  },
}

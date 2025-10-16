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
    keys = {
      {
        '<leader>bm',
        function()
          require('bookmarks').toggle_mark()
        end,
        desc = '[B]ookmarks Toggle [M]ark',
      },
      {
        '<leader>bg',
        function()
          require('bookmarks').goto_bookmark()
        end,
        desc = '[B]ookmarks [G]oto picker',
      },
      {
        '<leader>bl',
        function()
          require('bookmarks').bookmark_lists()
        end,
        desc = '[B]ookmarks choose [L]ist',
      },
      {
        '<leader>bt',
        function()
          local utils = require 'custom.utils'
          local function toggle()
            require('bookmarks').toggle_treeview()
          end

          if utils.toggle_edgy_view {
            ft = 'BookmarksTree',
            open = toggle,
            close = toggle,
          } then
            return
          end

          toggle()
        end,
        desc = '[B]ookmarks [T]ree view',
      },
      {
        '<leader>bn',
        function()
          require('bookmarks').goto_next_bookmark()
        end,
        desc = '[B]ookmarks [N]ext',
      },
      {
        '<leader>bp',
        function()
          require('bookmarks').goto_prev_bookmark()
        end,
        desc = '[B]ookmarks [P]revious',
      },
      {
        '<leader>bR',
        function()
          local service = require('bookmarks.domain.service')
          local bookmark = service.find_bookmark_by_location()

          if not bookmark then
            vim.notify('No bookmark at the current location to remove', vim.log.levels.INFO)
            return
          end

          service.remove_bookmark(bookmark.id)
          require('bookmarks.sign').safe_refresh_signs()
          pcall(require('bookmarks.tree').refresh)
        end,
        desc = '[B]ookmarks [R]emove mark',
      },
      {
        '<leader>bN',
        function()
          require('bookmarks').goto_next_list_bookmark()
        end,
        desc = '[B]ookmarks [N]ext by list order',
      },
      {
        '<leader>bP',
        function()
          require('bookmarks').goto_prev_list_bookmark()
        end,
        desc = '[B]ookmarks [P]revious by list order',
      },
      {
        '<leader>bG',
        function()
          require('bookmarks').grep_bookmarks()
        end,
        desc = '[B]ookmarks [G]rep',
      },
      {
        '<leader>bc',
        function()
          require('bookmarks').commands()
        end,
        desc = '[B]ookmarks [C]ommands',
      },
      {
        '<leader>bd',
        function()
          require('bookmarks').attach_desc()
        end,
        desc = '[B]ookmarks attach [D]escription',
      },
      {
        '<leader>bi',
        function()
          require('bookmarks').info()
        end,
        desc = '[B]ookmarks [I]nfo',
      },
      {
        '<leader>bI',
        function()
          require('bookmarks').bookmark_info()
        end,
        desc = '[B]ookmarks bookmark [I]nfo',
      },
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

      local utils = require 'custom.utils'
      if utils.is_edgy_enabled() then
        opts.treeview = opts.treeview or {}
        opts.treeview.window_split_dimension = 1
      end

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

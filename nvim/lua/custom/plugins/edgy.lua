return {
  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = function()
      local function load_plugin(name)
        local ok_lazy, lazy = pcall(require, 'lazy')
        if ok_lazy then
          lazy.load { plugins = { name } }
        end
      end

      local function open_aerial()
        load_plugin 'aerial.nvim'
        local ok, aerial = pcall(require, 'aerial')
        if ok then
          aerial.open { focus = false }
        else
          vim.cmd.AerialOpen()
        end
      end

      local function open_neotest_summary()
        load_plugin 'neotest'
        local ok, neotest = pcall(require, 'neotest')
        if ok and neotest.summary and neotest.summary.open then
          neotest.summary.open()
        else
          pcall(vim.cmd, 'Neotest summary')
        end
      end

      local function open_bookmarks_tree()
        load_plugin 'bookmarks.nvim'
        local ok, bookmarks = pcall(require, 'bookmarks')
        if ok and bookmarks.toggle_treeview then
          bookmarks.toggle_treeview()
        else
          vim.cmd.BookmarksTree()
        end
      end

      return {
        left = {
          {
            ft = 'aerial',
            title = 'Aerial',
            pinned = true,
            open = open_aerial,
          },
        },
        right = {
          {
            ft = 'BookmarksTree',
            title = 'Bookmarks',
            pinned = true,
            open = open_bookmarks_tree,
          },
        },
        bottom = {
          {
            ft = 'neotest-summary',
            title = 'Tests',
            pinned = true,
            open = open_neotest_summary,
          },
        },
      }
    end,
  },
}

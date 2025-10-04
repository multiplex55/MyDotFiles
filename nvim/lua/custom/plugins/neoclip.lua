return {
  {
    'AckslD/nvim-neoclip.lua',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      {
        'tami5/sqlite.lua',
        module = 'sqlite',
      },
    },
    cond = function()
      local has_sqlite, sqlite = pcall(require, 'sqlite')
      if not has_sqlite then
        vim.notify(
          'nvim-neoclip.lua disabled: sqlite dependency is not available',
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
        return false
      end

      -- Ensure sqlite module is fully initialised before continuing.
      if type(sqlite) ~= 'table' then
        vim.notify(
          'nvim-neoclip.lua disabled: sqlite dependency did not return a module table',
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
        return false
      end

      return true
    end,
    config = function()
      local ok, neoclip = pcall(require, 'neoclip')
      if not ok then
        vim.notify(
          'nvim-neoclip.lua disabled: plugin is not installed or failed to load',
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
        return
      end

      neoclip.setup {
        history = 1000,
        enable_persistent_history = true,
        continuous_sync = true,
        enable_macro_history = true,
        db_path = vim.fn.stdpath 'data' .. '/databases/neoclip.sqlite3',
        filter = nil,
        preview = true,
      }
    end,
  },
}

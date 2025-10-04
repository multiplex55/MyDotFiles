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
    config = function()
      local function detect_sqlite()
        local has_sqlite, sqlite = pcall(require, 'sqlite')
        if not has_sqlite then
          return false, 'sqlite dependency is not available'
        end

        if type(sqlite) ~= 'table' then
          return false, 'sqlite dependency did not return a module table'
        end

        local has_defs, defs_err = pcall(require, 'sqlite.defs')
        if not has_defs then
          local message = defs_err or 'sqlite native bindings failed to load'
          return false, message
        end

        return true
      end

      local sqlite_available, sqlite_error = detect_sqlite()

      if not sqlite_available then
        vim.notify(
          'nvim-neoclip.lua disabled: sqlite unavailable - ' .. tostring(sqlite_error),
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
        return
      end

      local ok, neoclip = pcall(require, 'neoclip')
      if not ok then
        vim.notify(
          'nvim-neoclip.lua disabled: plugin is not installed or failed to load',
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
        return
      end

      local setup_ok, setup_err = pcall(neoclip.setup, {
        history = 1000,
        enable_persistent_history = true,
        continuous_sync = true,
        enable_macro_history = true,
        db_path = vim.fn.stdpath 'data' .. '/databases/neoclip.sqlite3',
        filter = nil,
        preview = true,
      })

      if not setup_ok then
        vim.notify(
          'nvim-neoclip.lua disabled: setup failed - ' .. tostring(setup_err),
          vim.log.levels.WARN,
          { title = 'Neoclip' }
        )
      end
    end,
  },
}

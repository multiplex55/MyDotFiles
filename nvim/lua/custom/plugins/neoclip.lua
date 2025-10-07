return {
  {
    'AckslD/nvim-neoclip.lua',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kkharji/sqlite.lua',
    },
    config = function()
      local ok, neoclip = pcall(require, 'neoclip')
      if not ok then
        vim.notify('nvim-neoclip: failed to load plugin module', vim.log.levels.ERROR)
        return
      end

      local has_sqlite = pcall(require, 'sqlite')
      if not has_sqlite then
        vim.notify(
          'nvim-neoclip: sqlite.lua dependency unavailable; persistent history disabled',
          vim.log.levels.WARN
        )
      end

      neoclip.setup {
        history = 1000,
        enable_persistent_history = has_sqlite,
      }
    end,
  },
}

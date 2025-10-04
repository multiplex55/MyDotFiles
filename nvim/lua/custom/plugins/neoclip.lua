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
      require('neoclip').setup {
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

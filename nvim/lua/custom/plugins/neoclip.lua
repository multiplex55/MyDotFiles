return {
  {
    'AckslD/nvim-neoclip.lua',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kkharji/sqlite.lua',
    },
    opts = {
      enable_persistent_history = true,
      db_path = vim.fn.stdpath 'data' .. '/neoclip.sqlite3',
    },
    config = function(_, opts)
      -- SQLite support (configured in init.lua) is required for persistence, especially on Windows setups.
      require('neoclip').setup(opts)
      pcall(require('telescope').load_extension, 'neoclip')
    end,
  },
}

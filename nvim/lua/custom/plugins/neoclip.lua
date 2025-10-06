return {
  {
    'AckslD/nvim-neoclip.lua',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kkharji/sqlite.lua',
    },
    config = function()
      require('neoclip').setup {
        history = 1000,
        enable_persistent_history = true,
      }
    end,
  },
}

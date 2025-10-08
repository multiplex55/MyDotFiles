return {
  {
    'ecthelionvi/NeoComposer.nvim',
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-lua/plenary.nvim',
    },
    event = 'VeryLazy',
    opts = {
      queue_most_recent = true,
      window = {
        winhl = {
          Normal = 'NormalFloat',
          FloatBorder = 'FloatBorder',
          FloatTitle = 'FloatTitle',
        },
      },
    },
    config = function(_, opts)
      require('NeoComposer').setup(opts)
    end,
  },
}

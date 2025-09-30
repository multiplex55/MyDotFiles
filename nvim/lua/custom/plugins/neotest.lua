return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
    'rouge8/neotest-rust',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require('neotest-rust') {
          args = { '--nocapture' },
        },
      },
    }
  end,
}

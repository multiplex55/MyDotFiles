return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      modes = {
        -- keep native f/t motions intact
        char = {
          enabled = false,
        },
      },
    },
    config = function(_, opts)
      local flash = require 'flash'
      flash.setup(opts)

      local map = vim.keymap.set
      local modes = { 'n', 'x', 'o' }

      map(modes, 's', function()
        flash.jump()
      end, { desc = 'Flash jump' })

      map(modes, 'S', function()
        flash.treesitter()
      end, { desc = 'Flash Treesitter search' })

      map('n', '<leader>hf', function()
        flash.jump()
      end, { desc = '[h]op Flash [f]ind' })

      map('n', '<leader>hF', function()
        flash.treesitter()
      end, { desc = '[h]op Flash [F]orest (TS)' })
    end,
  },
}

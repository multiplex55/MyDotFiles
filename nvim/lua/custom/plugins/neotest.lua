return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
    'rouge8/neotest-rust',
  },
  opts = function()
    local utils = require 'custom.utils'

    local summary_open
    if utils.is_edgy_enabled() then
      summary_open = function()
        vim.cmd 'botright vsplit'
        return vim.api.nvim_get_current_win()
      end
    else
      summary_open = 'botright vsplit | vertical resize 50'
    end

    return {
      adapters = {
        require('neotest-rust') {
          args = { '--nocapture' },
        },
      },
      summary = {
        open = summary_open,
      },
    }
  end,
  config = function(_, opts)
    require('neotest').setup(opts)
  end,
}

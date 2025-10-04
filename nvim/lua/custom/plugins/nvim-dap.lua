return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require 'custom.dap-config'
    end,
  },
}

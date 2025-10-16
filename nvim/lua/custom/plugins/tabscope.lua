-- Toggle this flag to enable or disable the TabScope integration.
-- Set it to `false` if you want to turn off the plugin and its keymaps.
local enable_tabscope = true

return {
  {
    'backdround/tabscope.nvim',
    enabled = enable_tabscope,
    event = 'VeryLazy',
    config = function()
      require('tabscope').setup({})
    end,
  },
}

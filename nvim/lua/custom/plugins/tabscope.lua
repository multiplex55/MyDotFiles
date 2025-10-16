-- Toggle this flag to enable or disable TabScope integration and keymaps.
-- Set it to false to turn off the plugin without removing this file.
local enable_tabscope = true

return {
  'backdround/tabscope.nvim',
  name = 'tabscope.nvim',
  enabled = enable_tabscope,
  event = 'VeryLazy',
  config = function()
    require('tabscope').setup {}
  end,
}

return {
  'romgrk/barbar.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    icons = {
      filetype = {
        enabled = false,
      },
      separator = { left = '', right = '' }, -- optional: remove separators
      modified = { button = '●' }, -- you can still show a modified icon:
    },
  },
}

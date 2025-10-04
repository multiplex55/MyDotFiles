return {

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto', -- auto picks up current colorscheme
          section_separators = { left = '', right = '' },
          component_separators = '|',
          globalstatus = true,
          disabled_filetypes = {
            winbar = {
              'dashboard',
              'snacks_dashboard',
              'help',
              'terminal',
            },
          },
        },
        winbar = nil,
        inactive_winbar = nil,
      }
    end,
  },
}

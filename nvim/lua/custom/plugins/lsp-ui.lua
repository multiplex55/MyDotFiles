return {
  {
    'glepnir/lspsaga.nvim',
    event = 'LspAttach',
    config = function()
      require('lspsaga').setup {
        ui = {
          border = 'rounded',
          title = true,
          code_action = '💡',
        },
        lightbulb = {
          enable = false,
          sign = true,
          virtual_text = true,
        },
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
        },
        symbol_in_winbar = {
          enable = true,
          separator = '  ',
          show_file = true,
          folder_level = 2,
        },
      }
    end,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
  },
}

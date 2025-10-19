return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      {
        '<leader>tt',
        function()
          require('toggleterm').toggle(1)
        end,
        desc = 'Toggle primary terminal',
        mode = { 'n' },
      },
      {
        '<leader>tv',
        function()
          require('toggleterm').toggle(2, 80, nil, 'vertical')
        end,
        desc = 'Toggle vertical terminal',
        mode = { 'n' },
      },
    },
    config = function()
      require('toggleterm').setup {
        direction = 'horizontal',
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
      }
    end,
  },
}

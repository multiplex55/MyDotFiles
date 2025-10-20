return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      {
        '<leader>Tt',
        function()
          require('toggleterm').toggle(1)
        end,
        desc = 'Toggle primary terminal',
        mode = { 'n', 't' },
      },
      {
        '<leader>Tv',
        function()
          require('toggleterm').toggle(2, 80, nil, 'vertical')
        end,
        desc = 'Toggle vertical terminal',
        mode = { 'n', 't' },
      },
      {
        '<leader>TF',
        function()
          require('toggleterm').toggle(3, nil, nil, 'float')
        end,
        desc = 'Toggle floating terminal',
        mode = { 'n', 't' },
      },
      {
        '<leader>TT',
        function()
          require('toggleterm').toggle(4, nil, nil, 'tab')
        end,
        desc = 'Toggle tab terminal',
        mode = { 'n', 't' },
      },
      {
        '<leader>Ts',
        function()
          vim.cmd 'ToggleTermSendCurrentLine'
        end,
        desc = 'Send line to terminal',
        mode = { 'n' },
      },
      {
        '<leader>TS',
        function()
          vim.cmd 'ToggleTermSendVisualSelection'
        end,
        desc = 'Send selection to terminal',
        mode = { 'x' },
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

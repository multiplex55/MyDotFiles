return {
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    opts = function()
      local has_tmux = vim.env.TMUX ~= nil and vim.fn.executable 'tmux' == 1
      return {
        tmux_integration = has_tmux,
      }
    end,
  },
  {
    'sindrets/winshift.nvim',
    cmd = 'WinShift',
    opts = {
      highlight_moving_win = true,
      focused_hl_group = 'Visual',
      moving_win_options = {
        wrap = false,
        cursorline = true,
        cursorcolumn = true,
        colorcolumn = '',
      },
    },
  },
}

return {
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    opts = {
      tmux = {
        enable = false,
      },
    },
  },
  {
    'sindrets/winshift.nvim',
    event = 'VeryLazy',
    opts = {
      highlight_moving_win = true,
      focused_hl_group = 'Visual',
      moving_win_options = {
        winblend = 0,
      },
    },
  },
}

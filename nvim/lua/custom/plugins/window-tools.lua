return {
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    opts = {
      tmux = {
        -- Disable tmux integration by default; flip to `true` if you prefer pane hopping
        enable = false,
      },
    },
  },
  {
    'sindrets/winshift.nvim',
    cmd = { 'WinShift' },
    opts = {
      highlight_moving_win = true,
      focused_hl_group = 'Visual',
    },
  },
}

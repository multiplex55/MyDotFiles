return {
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      require('smart-splits').setup {
        -- Enable tmux-aware navigation without forcing tmux integration.
        -- Toggle this to true if tmux pane targeting is desired.
        tmux_integration = false,
        default_amount = 2,
      }
    end,
  },
  {
    'sindrets/winshift.nvim',
    event = 'VeryLazy',
    config = function()
      require('winshift').setup {
        highlight_moving_win = true,
        focused_hl_group = 'Visual',
      }
    end,
  },
}

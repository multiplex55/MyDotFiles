return {
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      require('smart-splits').setup {
        tmux_integration = true,
      }
    end,
  },
  {
    'sindrets/winshift.nvim',
    cmd = 'WinShift',
    event = 'VeryLazy',
    config = function()
      require('winshift').setup {}
    end,
  },
}

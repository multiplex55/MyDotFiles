return {
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    opts = {
      hint = 'floating-big-letter',
      filter_rules = {
        bo = {
          -- Set 'terminal' to false to include terminals
          buftype = {
            terminal = false,
          },
        },
      },
    },
  },
}

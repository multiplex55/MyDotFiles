return {
  'AckslD/muren.nvim',
  cmd = { 'MurenToggle', 'MurenOpen', 'MurenReplace' },
  config = function()
    require('muren').setup {
      patterns_width = 40,
      replace_single_buffer = false,
      default_options = {
        search_method = 'fixed', -- exact match, no regex
        ui = {
          border = 'rounded',
        },
      },
    }
  end,
}

return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('spectre').setup {
      default = {
        find = {
          cmd = 'rg',
          options = {
            '--no-ignore',
            '--hidden',
            '--glob=!**/.git/*',
            '--fixed-strings', -- Disable regex, exact string matching
          },
        },
      },
    }
  end,
}

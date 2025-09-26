return {
  'neovim/nvim-lspconfig',
  ft = { 'ahk', 'autohotkey', 'ah2' },
  config = function()
    require('custom.ahk2').setup()
  end,
}

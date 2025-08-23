return {

  {
    'echasnovski/mini.diff',
    version = false, -- Use 'version = "*"‘ for the latest stable release
    event = 'VeryLazy',
    opts = {
      view = {
        style = 'sign', -- Options: 'sign' or 'number'
        signs = { add = '▎', change = '▎', delete = '' },
      },
    },
  },
}

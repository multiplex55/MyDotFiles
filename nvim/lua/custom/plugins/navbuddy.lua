local kind_icons = {
  File = ' ',
  Module = ' ',
  Namespace = ' ',
  Package = ' ',
  Class = ' ',
  Method = ' ',
  Property = ' ',
  Field = ' ',
  Constructor = ' ',
  Enum = ' ',
  Interface = ' ',
  Function = ' ',
  Variable = ' ',
  Constant = ' ',
  String = ' ',
  Number = ' ',
  Boolean = ' ',
  Array = ' ',
  Object = ' ',
  Key = ' ',
  Null = ' ',
  EnumMember = ' ',
  Struct = ' ',
  Event = ' ',
  Operator = ' ',
  TypeParameter = ' ',
}

return {
  {
    'SmiteshP/nvim-navbuddy',
    cmd = 'Navbuddy',
    keys = {
      {
        '<leader>sN',
        function()
          require('nvim-navbuddy').open()
        end,
        desc = '[S]earch [N]avbuddy',
        mode = { 'n' },
      },
    },
    dependencies = {
      {
        'SmiteshP/nvim-navic',
        config = function()
          require('nvim-navic').setup {
            icons = kind_icons,
            highlight = true,
            separator = '  ',
            depth_limit = 5,
            depth_limit_indicator = '…',
            safe_output = true,
          }
        end,
      },
      'MunifTanjim/nui.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = function()
      local actions = require 'nvim-navbuddy.actions'
      return {
        window = {
          border = 'rounded',
          size = '80%',
          position = '50%',
          sections = {
            left = {
              size = '20%',
            },
            mid = {
              size = '40%',
            },
            right = {
              preview = 'leaf',
            },
          },
        },
        source_buffer = {
          follow_node = true,
          highlight = true,
        },
        node_markers = {
          enabled = true,
          icons = {
            leaf = '  ',
            leaf_selected = ' →',
            branch = ' ',
          },
        },
        lsp = {
          auto_attach = true,
        },
        use_default_mappings = true,
        mappings = {
          ['<Up>'] = actions.previous_sibling(),
          ['<Down>'] = actions.next_sibling(),
          ['<Left>'] = actions.parent(),
          ['<Right>'] = actions.children(),
          ['<CR>'] = actions.select(),
        },
        icons = kind_icons,
      }
    end,
    config = function(_, opts)
      require('nvim-navbuddy').setup(opts)
    end,
  },
}

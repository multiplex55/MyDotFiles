return {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      auto_close = true,
      auto_open = false,
      auto_preview = false,
      modes = {
        diagnostics = {
          desc = 'Workspace Diagnostics',
        },
        buffer_diagnostics = {
          mode = 'diagnostics',
          desc = 'Buffer Diagnostics',
          filter = { buf = 0 },
        },
        lsp_references = {
          desc = 'LSP References',
          params = {
            include_declaration = true,
          },
        },
        quickfix = {
          desc = 'Quickfix List',
        },
        loclist = {
          desc = 'Location List',
        },
        todo = {
          mode = 'todo',
          desc = 'Todo Comments',
        },
      },
    },
    config = function(_, opts)
      local trouble = require 'trouble'

      trouble.setup(opts)
    end,
  },
  {
    'kevinhwang91/nvim-bqf',
    event = 'BufReadPost quickfix',
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      preview = {
        border = 'rounded',
        win_height = 14,
        win_vheight = 10,
        delay_syntax = 40,
        show_title = true,
        show_scroll_bar = true,
      },
      func_map = {
        open = '<CR>',
        openc = 'o',
        drop = 'O',
        split = '<C-x>',
        vsplit = '<C-v>',
        tab = 't',
        ptogglemode = 'zp',
        ptoggleauto = 'P',
        pscrollup = '<C-b>',
        pscrolldown = '<C-f>',
      },
    },
  },
}

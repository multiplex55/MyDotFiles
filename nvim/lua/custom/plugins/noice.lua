return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        optional = true,
      },
    },
    opts = function()
      local border = 'rounded'

      return {
        cmdline = {
          view = 'cmdline_popup',
        },
        messages = {
          view = 'notify',
          view_error = 'notify',
          view_warn = 'notify',
        },
        popupmenu = {
          enabled = true,
          backend = 'cmp', -- confirm behavior customized in cmp config
        },
        presets = {
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
        views = {
          cmdline_popup = {
            border = {
              style = border,
              padding = { 0, 1 },
            },
            position = {
              row = '40%',
              col = '50%',
            },
            size = {
              width = 60,
              height = 'auto',
            },
            win_options = {
              winblend = 10,
            },
          },
          popupmenu = {
            border = {
              style = border,
              padding = { 0, 1 },
            },
            position = {
              row = '50%',
              col = '50%',
            },
            size = {
              width = 60,
              height = 10,
            },
            win_options = {
              winblend = 10,
            },
          },
          mini = {
            win_options = {
              winblend = 10,
            },
          },
        },
      }
    end,
  },
}

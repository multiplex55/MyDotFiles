return {
  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      { 'nvim-treesitter/nvim-treesitter', optional = true },
      { 'MunifTanjim/nui.nvim', optional = true },
    },
    config = function()
      local dropbar = require 'dropbar'
      local configs = require 'dropbar.configs'

      local default_enable = configs.opts.bar.enable
      local excluded_filetypes = {
        help = true,
        dashboard = true,
        ['snacks_dashboard'] = true,
        ['alpha'] = true,
      }

      dropbar.setup {
        bar = {
          enable = function(buf, win, info)
            buf = vim._resolve_bufnr(buf)
            if not buf or not vim.api.nvim_buf_is_valid(buf) then
              return false
            end

            if vim.bo[buf].buftype == 'terminal' then
              return false
            end

            local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
            if excluded_filetypes[filetype] then
              return false
            end

            return default_enable(buf, win, info)
          end,
        },
      }

      vim.keymap.set('n', '<leader>sb', function()
        require('dropbar.api').pick()
      end, { desc = '[S]earch [B]readcrumbs' })
    end,
  },
}

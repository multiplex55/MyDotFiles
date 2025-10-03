return {
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      backends = { 'treesitter', 'lsp' },
      layout = {
        default_direction = 'prefer_right',
        placement = 'edge',
        max_width = { 40, 0.25 },
        min_width = 30,
      },
      attach_mode = 'global',
      show_guides = true,
    },
    config = function(_, opts)
      local aerial = require 'aerial'
      aerial.setup(opts)

      vim.keymap.set('n', '<leader>sa', function()
        aerial.toggle { focus = true }
      end, { desc = '[S]ymbols [A]erial toggle' })

      vim.keymap.set('n', '<leader>sj', function()
        aerial.next { skip_hidden = true }
      end, { desc = '[S]ymbols Next' })

      vim.keymap.set('n', '<leader>sk', function()
        aerial.prev { skip_hidden = true }
      end, { desc = '[S]ymbols Previous' })

      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add {
          { '<leader>sa', '[S]ymbols [A]erial toggle', mode = 'n' },
          { '<leader>sj', '[S]ymbols Next', mode = 'n' },
          { '<leader>sk', '[S]ymbols Previous', mode = 'n' },
        }
      end

      local telescope_ok, telescope = pcall(require, 'telescope')
      if telescope_ok then
        telescope.load_extension 'aerial'
      end
    end,
  },
}

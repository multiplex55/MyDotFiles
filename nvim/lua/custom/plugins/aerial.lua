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
      end, { desc = '[S]earch [A]erial Toggle' })

      vim.keymap.set('n', '<leader>saf', function()
        aerial.focus()
      end, { desc = '[S]earch [A]erial Focus' })

      vim.keymap.set('n', '<leader>sao', function()
        aerial.open { focus = true }
      end, { desc = '[S]earch [A]erial Open' })

      vim.keymap.set('n', '<leader>sac', function()
        aerial.close()
      end, { desc = '[S]earch [A]erial Close' })

      vim.keymap.set('n', '<leader>san', function()
        aerial.next { skip_hidden = true }
      end, { desc = '[S]earch [A]erial Next' })

      vim.keymap.set('n', '<leader>sap', function()
        aerial.prev { skip_hidden = true }
      end, { desc = '[S]earch [A]erial Previous' })

      local telescope_ok, telescope = pcall(require, 'telescope')
      if telescope_ok then
        telescope.load_extension 'aerial'
      end
    end,
  },
}

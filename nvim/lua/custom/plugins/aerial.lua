return {
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    opts = function()
      local utils = require 'custom.utils'
      local layout = {
        default_direction = 'prefer_right',
        max_width = { 40, 0.25 },
        min_width = 30,
      }

      if not utils.is_edgy_enabled() then
        layout.placement = 'edge'
      end

      return {
        backends = { 'treesitter', 'lsp' },
        layout = layout,
        attach_mode = 'global',
        show_guides = true,
      }
    end,
    config = function(_, opts)
      local utils = require 'custom.utils'
      local aerial = require 'aerial'
      aerial.setup(opts)

      local function open_aerial()
        aerial.open { focus = false }
      end

      local function close_aerial()
        aerial.close()
      end

      vim.keymap.set('n', '<leader>sat', function()
        if utils.toggle_edgy_view {
          ft = 'aerial',
          open = open_aerial,
          close = close_aerial,
        } then
          return
        end
        aerial.toggle { focus = true }
      end, { desc = '[S]earch [A]erial Toggle' })

      vim.keymap.set('n', '<leader>saf', function()
        if utils.focus_edgy_view {
          ft = 'aerial',
          open = open_aerial,
        } then
          return
        end
        aerial.focus()
      end, { desc = '[S]earch [A]erial Focus' })

      vim.keymap.set('n', '<leader>sao', function()
        if utils.focus_edgy_view {
          ft = 'aerial',
          open = open_aerial,
        } then
          return
        end
        aerial.open { focus = true }
      end, { desc = '[S]earch [A]erial Open' })

      vim.keymap.set('n', '<leader>sac', function()
        if utils.toggle_edgy_view {
          ft = 'aerial',
          close = close_aerial,
          focus_after = false,
        } then
          return
        end
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

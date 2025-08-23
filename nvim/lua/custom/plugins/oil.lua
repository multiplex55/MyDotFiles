return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      CustomOilBar = function()
        local path = vim.fn.expand '%'
        path = path:gsub('oil://', '')

        return '  ' .. vim.fn.fnamemodify(path, ':.')
      end

      require('oil').setup {
        columns = { 'icon', 'permissions', 'size', 'mtime' },
        keymaps = {
          ['<CR>'] = 'actions.select', -- Open file or directory
          ['<M-h>'] = 'actions.select_split', -- Open in horizontal split
          ['<M-v>'] = 'actions.select_vsplit', -- Open in vertical split
          ['<M-t>'] = 'actions.select_tab', -- Open in new tab
          ['<C-r>'] = 'actions.refresh', -- Refresh listing
          ['g.'] = 'actions.toggle_hidden', -- Toggle hidden files
          ['gs'] = 'actions.change_sort', -- Change sort mode
          ['q'] = 'actions.close', -- Close Oil
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
        },
        win_options = {
          winbar = '%{v:lua.CustomOilBar()}',
        },
        view_options = {
          show_hidden = true,
        },
      }

      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', {
        desc = 'Open parent directory',
      })

      -- Open parent directory in floating window
      vim.keymap.set('n', '<space>-', require('oil').toggle_float)
    end,
  },
}

return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED

      vim.keymap.set('n', '<leader>ba', function()
        harpoon:list():add()
      end, {
        desc = '[b]ookmark [a]dd Harpoon',
      })
      vim.keymap.set('n', '<leader>bq', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, {
        desc = '[b]ookmark Harpoon [q]uick-menu',
      })

      -- vim.keymap.set('n', '<C-h>', function()
      --     harpoon:list():select(1)
      -- end, {
      --     desc = 'ctrl + [h]first harpoon'
      -- })
      --
      -- vim.keymap.set('n', '<C-t>', function()
      --     harpoon:list():select(2)
      -- end, {
      --     desc = 'ctrl + [t]second harpoon'
      -- })

      -- vim.keymap.set('n', '<C-n>', function()
      -- harpoon:list():select(3)
      -- end, { desc = 'ctrl + [n]third harpoon' })

      -- vim.keymap.set('n', '<C-s>', function()
      -- harpoon:list():select(4)
      -- end, { desc = 'ctrl + [s]fourth harpoon' })

      -- Toggle previous & next buffers stored within Harpoon list
      -- vim.keymap.set('n', '<C-S-P>', function()
      -- harpoon:list():prev()
      -- end, { desc = 'ctrl + shift + [P]revious harpoon' })

      -- vim.keymap.set('n', '<C-S-N>', function()
      -- harpoon:list():next()
      -- end, { desc = 'ctrl + shift + [N]ext harpoon' })
    end,
  },
}

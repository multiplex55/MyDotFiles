return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required
      'sindrets/diffview.nvim', -- Optional: Diff integration
      'nvim-telescope/telescope.nvim', -- Optional: Enhanced UI
    },
    config = function()
      require('neogit').setup {
        kind = 'split', -- Opens Neogit in a split window
        integrations = {
          diffview = true, -- Enables diffview integration
        },
      }
    end,
  },
}

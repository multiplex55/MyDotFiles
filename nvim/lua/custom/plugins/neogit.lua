return {
  {
    'NeogitOrg/neogit',
    cmd = { 'Neogit' },
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required
      'sindrets/diffview.nvim', -- Optional: Diff integration
      'nvim-telescope/telescope.nvim', -- Optional: Enhanced UI
    },
    opts = {
      kind = 'split', -- Opens Neogit in a split window
      integrations = {
        diffview = true, -- Enables diffview integration
      },
    },
    config = function(_, opts)
      require('neogit').setup(opts)
    end,
  },
}

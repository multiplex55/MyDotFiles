local markdown_runtime = require 'custom.utils.markdown_runtime'

local workspace_paths = {
  'C:\\Users\\multi\\My Drive\\Obsidian\\MyNotes',
}

vim.g.custom_obsidian_workspace_paths = workspace_paths

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  event = markdown_runtime.obsidian_events(),
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- see above for full list of optional dependencies ☝️
  },
  ---@module 'obsidian'
  ---@type obsidian.config.ClientOpts
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = workspace_paths[1],
      },
    },

    -- Crash-signature guard: keep Obsidian scoped to vault buffers only to
    -- prevent dual activation races with render-markdown async footer/backlink
    -- handlers in non-vault markdown files.
    -- see below for full list of options 👇
  },
}

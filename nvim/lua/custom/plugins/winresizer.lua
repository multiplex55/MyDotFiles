return {
    'simeji/winresizer',
    event = 'VeryLazy',
    init = function()
      -- Optional: Set custom keybinding to activate winresizer mode
      vim.g.winresizer_start_key = '<C-e>' -- Default is <C-e>
  
      -- Optional: Configure other options if needed
      -- vim.g.winresizer_vert_resize = 2
      -- vim.g.winresizer_horiz_resize = 2
    end,
  }
  
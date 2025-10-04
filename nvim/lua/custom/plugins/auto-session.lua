return {
  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      auto_session_root_dir = vim.fn.stdpath 'data' .. '/sessions/',
      auto_save_enabled = false, -- ❌ disable autosave
      auto_restore_enabled = false, -- ❌ disable autorestore
      auto_session_use_git_branch = true,
      log_level = 'error',
    },
    config = function(_, opts)
      -- Explicitly configure auto-session so that the plugin populates its
      -- `conf` table before other plugins (like session-lens) attempt to read
      -- from it. Without this, session-lens tries to index `AutoSession.conf`
      -- and errors because lazy.nvim may not have invoked setup automatically.
      require('auto-session').setup(opts)
    end,
  },
}

return {
  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      auto_session_root_dir = vim.fn.stdpath 'data' .. '/sessions/',
      -- Keep autosave/autorestore explicit: we prefer manual restores through
      -- session-lens for reliability and predictable startup behavior.
      auto_save_enabled = false,
      auto_restore_enabled = false,
      auto_session_use_git_branch = true,
      log_level = 'error',

      pre_restore_cmds = {
        function()
          vim.g.session_restoring = true
        end,
      },
      post_restore_cmds = {
        function()
          vim.g.session_restoring = false
          vim.api.nvim_exec_autocmds('User', { pattern = 'AutoSessionRestoreDone' })
        end,
      },
    },
    config = function(_, opts)
      -- Default to not restoring to keep behavior explicit when launching nvim
      -- without session-lens/manual restore actions.
      vim.g.session_restoring = false

      -- Explicitly configure auto-session so that the plugin populates its
      -- `conf` table before other plugins (like session-lens) attempt to read
      -- from it. Without this, session-lens tries to index `AutoSession.conf`
      -- and errors because lazy.nvim may not have invoked setup automatically.
      require('auto-session').setup(opts)
    end,
  },
}

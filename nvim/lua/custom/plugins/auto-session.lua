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
  },
}

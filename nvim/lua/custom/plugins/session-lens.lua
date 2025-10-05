return {
  {
    'rmagatti/session-lens',
    dependencies = { 'rmagatti/auto-session', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('session-lens').setup {}
      local ok, telescope = pcall(require, 'telescope')
      if not ok then
        vim.notify('[session-lens] Telescope not available; extension not loaded', vim.log.levels.WARN)
        return
      end

      pcall(telescope.load_extension, 'session-lens')
    end,
    keys = {
      { '<leader>sss', '<cmd>Telescope session-lens search_session<cr>', desc = '[S]ession [S]ave [S]witch' },
    },
  },
}

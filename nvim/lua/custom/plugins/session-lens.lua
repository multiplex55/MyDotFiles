return {
  {
    'rmagatti/session-lens',
    dependencies = { 'rmagatti/auto-session', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('session-lens').setup {}
      require('telescope').load_extension 'session-lens'
    end,
    keys = {
      { '<leader>sss', '<cmd>Telescope session-lens search_session<cr>', desc = '[S]ession [S]ave [S]witch' },
    },
  },
}

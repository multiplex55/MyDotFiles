return {
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        opts = {
          enable_autocmd = false,
        },
      },
    },
    opts = function()
      local commentstring = require('ts_context_commentstring.integrations.comment_nvim')
      return {
        mappings = {
          basic = true,
          extra = false,
        },
        pre_hook = commentstring.create_pre_hook(),
      }
    end,
  },
}

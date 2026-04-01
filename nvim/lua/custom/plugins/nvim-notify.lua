return {

  {
    'rcarriga/nvim-notify',
    config = function(_, opts)
      local notify_opts = require('custom.config.notify').resolve(opts)
      local ok, notify = pcall(require, 'notify')
      if not ok then
        local fallback = '[nvim-notify] plugin unavailable; using built-in vim.notify'
        if vim.api and vim.api.nvim_echo then
          vim.api.nvim_echo({ { fallback, 'WarningMsg' } }, true, {})
        else
          print(fallback)
        end
        return
      end

      notify.setup(notify_opts)
      vim.notify = notify
    end,
  },
}

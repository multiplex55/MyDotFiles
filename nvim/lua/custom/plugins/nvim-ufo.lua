return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    event = 'BufReadPost',
    config = function()
      local ufo = require 'ufo'

      local hover_handler = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
        title = 'Hover',
      })

      ufo.setup {
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end,
        preview = {
          win_config = {
            border = { '', '─', '', '', '', '─', '', '' },
            winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
            maxheight = 20,
          },
          mappings = {
            scrollB = '<C-b>',
            scrollF = '<C-f>',
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            close = 'q',
            switch = '<Tab>',
            trace = '<CR>',
          },
        },
      }

      vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'UFO: Open all folds' })
      vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'UFO: Close all folds' })
      vim.keymap.set('n', 'zp', function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          local bufnr = vim.api.nvim_get_current_buf()
          local params = vim.lsp.util.make_position_params()
          vim.lsp.buf_request(bufnr, 'textDocument/hover', params, hover_handler)
        end
      end, { desc = 'UFO: Peek fold under cursor' })
    end,
  },
}

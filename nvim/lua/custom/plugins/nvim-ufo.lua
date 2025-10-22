return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },

    -- Load after UI is ready so we can open folds for the current buffer immediately.
    event = 'VeryLazy',

    -- Make every buffer start unfolded by default.
    init = function()
      vim.o.foldcolumn = '1' -- show fold column (optional)
      vim.o.foldlevel = 99 -- large foldlevel so everything is open
      vim.o.foldlevelstart = 99 -- start buffers opened
      vim.o.foldenable = true -- enable folding (but opened due to levels)
    end,

    config = function()
      local ufo = require 'ufo'

      local function should_skip(bufnr, winid)
        if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
          return true
        end
        if not winid or winid == 0 or not vim.api.nvim_win_is_valid(winid) then
          return true
        end
        local bt = vim.bo[bufnr].buftype
        if bt == 'nofile' or bt == 'prompt' then
          return true
        end
        local ft = vim.bo[bufnr].filetype
        if ft == 'TelescopePrompt' or ft == 'TelescopeResults' then
          return true
        end
        local cfg = vim.api.nvim_win_get_config(winid)
        if cfg.relative ~= '' then
          return true
        end -- floating windows, etc.
        return false
      end

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

      -- Always open folds when entering a window that shows a normal buffer.
      local aug = vim.api.nvim_create_augroup('ufo_auto_open', { clear = true })
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = aug,
        callback = function(ev)
          local winid = vim.api.nvim_get_current_win()
          if should_skip(ev.buf, winid) then
            return
          end
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_win_is_valid(winid) then
              ufo.openAllFolds()
            end
          end)
        end,
      })

      -- Do it once right now for the current buffer (since we loaded on VeryLazy).
      vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local winid = vim.api.nvim_get_current_win()
        if not should_skip(bufnr, winid) then
          ufo.openAllFolds()
        end
      end)

      -- Keymaps
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

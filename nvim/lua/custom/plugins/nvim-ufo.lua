return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    event = 'BufReadPost',
    config = function()
      local ufo = require 'ufo'

      local function should_skip(bufnr, winid)
        if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
          return true
        end
        if not winid or winid == 0 or not vim.api.nvim_win_is_valid(winid) then
          return true
        end

        local buftype = vim.bo[bufnr].buftype
        if buftype == 'nofile' or buftype == 'prompt' then
          return true
        end

        local filetype = vim.bo[bufnr].filetype
        if filetype == 'TelescopePrompt' or filetype == 'TelescopeResults' then
          return true
        end

        local config = vim.api.nvim_win_get_config(winid)
        if config.relative ~= '' then
          return true
        end

        return false
      end

      local foldlevel_group = vim.api.nvim_create_augroup('custom_ufo_foldlevel', { clear = true })

      vim.api.nvim_create_autocmd({ 'BufWinLeave', 'WinLeave' }, {
        group = foldlevel_group,
        callback = function(event)
          local bufnr = event.buf
          local winid = event.win
          if should_skip(bufnr, winid) then
            return
          end

          local ok, level = pcall(vim.api.nvim_win_call, winid, function()
            return vim.wo.foldlevel
          end)

          if ok and type(level) == 'number' then
            vim.b[bufnr]._ufo_saved_foldlevel = level
          end
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
        group = foldlevel_group,
        callback = function(event)
          local bufnr = event.buf
          local winid = event.win
          if should_skip(bufnr, winid) then
            return
          end

          local saved = vim.b[bufnr]._ufo_saved_foldlevel or 99

          local ok = pcall(vim.api.nvim_win_call, winid, function()
            vim.wo.foldlevel = saved
          end)

          if not ok then
            return
          end

          if saved >= 99 then
            vim.schedule(function()
              if should_skip(bufnr, winid) then
                return
              end

              vim.api.nvim_win_call(winid, function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  ufo.openAllFolds()
                end
              end)
            end)
          end
        end,
      })

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

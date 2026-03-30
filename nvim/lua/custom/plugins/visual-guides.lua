return {
  -- -- Rainbow delimiters using Treesitter
  -- {
  --   'HiPhish/rainbow-delimiters.nvim',
  --   event = 'VeryLazy',
  --   config = function()
  --     local function warn_once(msg)
  --       if vim.g.__rainbow_delimiters_warned then
  --         return
  --       end
  --
  --       vim.g.__rainbow_delimiters_warned = true
  --       vim.schedule(function()
  --         vim.notify(msg, vim.log.levels.WARN)
  --       end)
  --     end
  --
  --     local ok, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
  --     if not ok or type(rainbow_delimiters) ~= 'table' then
  --       warn_once 'rainbow-delimiters.nvim is unavailable; skipping setup.'
  --       return
  --     end
  --
  --     local global_strategy = rainbow_delimiters.strategy and rainbow_delimiters.strategy['global']
  --     local local_strategy = rainbow_delimiters.strategy and rainbow_delimiters.strategy['local']
  --     if type(global_strategy) ~= 'function' or type(local_strategy) ~= 'function' then
  --       warn_once 'rainbow-delimiters.nvim strategy API changed; skipping setup.'
  --       return
  --     end
  --
  --     local function safe_local_strategy(filetype)
  --       return function(bufnr)
  --         -- During session restore, always use the global strategy to avoid
  --         -- local Treesitter-node range callbacks firing against unstable state.
  --         if vim.g.session_restoring then
  --           return global_strategy(bufnr)
  --         end
  --
  --         local ok_local, result = pcall(local_strategy, bufnr)
  --         if ok_local then
  --           return result
  --         end
  --
  --         warn_once(string.format('rainbow-delimiters local strategy failed for %s; falling back to global strategy.', filetype))
  --         return global_strategy(bufnr)
  --       end
  --     end
  --
  --     vim.g.rainbow_delimiters = {
  --       strategy = {
  --         [''] = global_strategy,
  --         rust = safe_local_strategy 'rust',
  --       },
  --       query = {
  --         [''] = 'rainbow-delimiters',
  --         rust = 'rainbow-delimiters',
  --       },
  --       highlight = {
  --         'RainbowDelimiterRed',
  --         'RainbowDelimiterYellow',
  --         'RainbowDelimiterBlue',
  --         'RainbowDelimiterOrange',
  --         'RainbowDelimiterGreen',
  --         'RainbowDelimiterViolet',
  --         'RainbowDelimiterCyan',
  --       },
  --     }
  --
  --     -- If we're currently restoring a session, wait until restore completion
  --     -- before forcing re-attachment, so initial Treesitter state can settle.
  --     if vim.g.session_restoring then
  --       vim.api.nvim_create_autocmd('User', {
  --         pattern = 'AutoSessionRestoreDone',
  --         once = true,
  --         callback = function()
  --           vim.defer_fn(function()
  --             pcall(vim.cmd, 'silent! RainbowDelimitersEnable')
  --           end, 50)
  --         end,
  --       })
  --     end
  --   end,
  -- },

  -- Indentation guides

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'BufReadPre',
    config = function()
      local function set_rainbow_highlights()
        vim.api.nvim_set_hl(0, 'RainbowIndent1', { fg = '#E06C75' })
        vim.api.nvim_set_hl(0, 'RainbowIndent2', { fg = '#E5C07B' })
        vim.api.nvim_set_hl(0, 'RainbowIndent3', { fg = '#98C379' })
        vim.api.nvim_set_hl(0, 'RainbowIndent4', { fg = '#56B6C2' })
        vim.api.nvim_set_hl(0, 'RainbowIndent5', { fg = '#61AFEF' })
        vim.api.nvim_set_hl(0, 'RainbowIndent6', { fg = '#C678DD' })
        vim.api.nvim_set_hl(0, 'RainbowIndent7', { fg = '#ABB2BF' })
      end

      -- Set highlights initially
      set_rainbow_highlights()

      -- Set highlights again after colorscheme is applied
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = set_rainbow_highlights,
      })

      require('ibl').setup {
        indent = {
          char = '│',
          tab_char = '│',
          highlight = {
            'RainbowIndent1',
            'RainbowIndent2',
            'RainbowIndent3',
            'RainbowIndent4',
            'RainbowIndent5',
            'RainbowIndent6',
            'RainbowIndent7',
          },
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = {
            'RainbowIndent1',
            'RainbowIndent2',
            'RainbowIndent3',
            'RainbowIndent4',
            'RainbowIndent5',
            'RainbowIndent6',
            'RainbowIndent7',
          },
        },
      }
    end,
  },
}

return {
  -- Rainbow delimiters using Treesitter
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = 'VeryLazy',
    config = function()
      local rainbow_delimiters = require 'rainbow-delimiters'
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          rust = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          rust = 'rainbow-delimiters',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  },

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

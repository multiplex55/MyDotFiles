return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- This module intentionally targets the nvim-treesitter `main` rewrite API.
    -- Do not mix legacy `nvim-treesitter.configs.setup(...)` calls into this file.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      ts.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      ts.install {
        'bash',
        'c',
        'comment',
        'diff',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nim',
        'nim_format_string',
        'query',
        'ron',
        'rust',
        'toml',
        'typst',
        'vim',
        'vimdoc',
        'yaml',
        'zig',
      }

      local start_filetypes = {
        'bash',
        'c',
        'diff',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'html',
        'lua',
        'markdown',
        'md',
        'norg',
        'query',
        'ron',
        'rust',
        'toml',
        'typst',
        'vim',
        'yaml',
        'zig',
      }

      local ts_ft_group = vim.api.nvim_create_augroup('custom_treesitter_start', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = ts_ft_group,
        pattern = start_filetypes,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}

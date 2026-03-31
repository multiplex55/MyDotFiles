return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- Compatibility policy: Markdown rendering integrations require matching
    -- Neovim + Treesitter query APIs (notably parser/query predicate helpers).
    -- Guard markdown-dependent modules when parser/query APIs are unavailable.
    opts = {
      ensure_installed = {
        'nim_format_string',
        'bash',
        'c',
        'comment',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'nim',
        'zig',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = true,
        disable = { 'ruby' },
      },
    },
    config = function(_, opts)
      local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
      local markdown_parser_ready = false

      if ok_parsers and type(parsers.has_parser) == 'function' then
        markdown_parser_ready = parsers.has_parser 'markdown' and parsers.has_parser 'markdown_inline'
      end

      vim.g.markdown_treesitter_ready = markdown_parser_ready

      if not markdown_parser_ready then
        opts.highlight = opts.highlight or {}
        local highlight_disable = opts.highlight.disable or {}
        if type(highlight_disable) == 'string' then
          highlight_disable = { highlight_disable }
        end
        table.insert(highlight_disable, 'markdown')
        table.insert(highlight_disable, 'markdown_inline')
        opts.highlight.disable = highlight_disable

        opts.indent = opts.indent or {}
        local indent_disable = opts.indent.disable or {}
        if type(indent_disable) == 'string' then
          indent_disable = { indent_disable }
        end
        table.insert(indent_disable, 'markdown')
        table.insert(indent_disable, 'markdown_inline')
        opts.indent.disable = indent_disable
      end

      require('nvim-treesitter.configs').setup(opts)
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}

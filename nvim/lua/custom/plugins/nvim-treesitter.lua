return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- Markdown stack compatibility + upgrade notes:
    -- - API shape expected by this repo:
    --   * `vim.treesitter.start/get_parser`
    --   * `vim.treesitter.query.get/parse/add_predicate/add_directive`
    --   * parser.parse() -> tree root() -> node.range() must all be callable.
    -- - Branch/versioning strategy:
    --   * This config is maintained for the stable/default branch released by
    --     `nvim-treesitter/nvim-treesitter` plus `:TSUpdate`.
    --   * If pinning to a commit or switching branch, treat that as an API change
    --     and re-validate markdown runtime probes + :MarkdownHealth.
    -- - Known-good baseline for debugging:
    --   * Neovim v0.11.x + nvim-treesitter default/stable branch (HEAD updated
    --     via `:TSUpdate`) with markdown + markdown_inline parsers installed.
    opts = {
      ensure_installed = {
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
        -- Intentional fallback: disable markdown treesitter highlight/indent when
        -- markdown parser availability cannot be proven at setup time.
        -- This keeps non-markdown treesitter features enabled and avoids markdown
        -- highlighter startup paths that can later crash in callbacks.
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

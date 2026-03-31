return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.nvim',
    }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { 'markdown', 'rmd', 'markdown.mdx' },
    cmd = { 'RenderMarkdown' },
    -- Compatibility policy: Markdown rendering requires compatible Neovim +
    -- Treesitter query APIs. If parser/query support is unavailable, disable
    -- rendering for the current markdown buffer and warn once.
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown', 'rmd', 'markdown.mdx' },
      anti_conceal = {
        enabled = true,
      },
    },
    config = function(_, opts)
      local function markdown_parser_available()
        local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
        if not ok_parsers or type(parsers.has_parser) ~= 'function' then
          return false
        end

        return parsers.has_parser 'markdown' and parsers.has_parser 'markdown_inline'
      end

      require('render-markdown').setup(opts)

      local group = vim.api.nvim_create_augroup('render_markdown_parser_guard', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = { 'markdown', 'rmd', 'markdown.mdx' },
        callback = function(event)
          if vim.g.markdown_treesitter_ready or markdown_parser_available() then
            return
          end

          vim.b[event.buf].render_markdown_enabled = false
          vim.api.nvim_buf_call(event.buf, function()
            pcall(vim.cmd, 'silent! RenderMarkdown disable')
          end)

          if vim.g.render_markdown_parser_warned then
            return
          end

          vim.g.render_markdown_parser_warned = true
          vim.notify(
            "render-markdown.nvim disabled for markdown buffers: Treesitter markdown parser/query API unavailable.",
            vim.log.levels.WARN
          )
        end,
      })
    end,
  },
}

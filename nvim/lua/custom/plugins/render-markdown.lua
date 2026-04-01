return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.nvim',
    }, -- if you use the mini.nvim suite
    ft = { 'markdown', 'rmd', 'markdown.mdx' },
    cmd = { 'RenderMarkdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown', 'rmd', 'markdown.mdx' },
      anti_conceal = {
        enabled = true,
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
    end,
  },
}

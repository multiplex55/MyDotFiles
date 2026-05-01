return {
  {
    'delphinus/md-render.nvim',
    version = '*',
    ft = { 'markdown', 'rmd', 'markdown.mdx' },
    cmd = { 'MdRender', 'MdRenderTab', 'MdRenderPager', 'MdRenderDemo' },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>mp', '<Plug>(md-render-preview)', mode = 'n', ft = { 'markdown' } },
      { '<leader>mt', '<Plug>(md-render-preview-tab)', mode = 'n', ft = { 'markdown' } },
      { '<leader>md', '<Plug>(md-render-demo)', mode = 'n' },
      { 'sm', '<cmd>Telescope md_render find_files<cr>', mode = 'n', ft = { 'markdown' }, desc = '[S]earch [M]arkdown' },
    },
  },
}

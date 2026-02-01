return {
  {
    '2kabhishek/seeker.nvim',
    cmd = { 'Seeker' },
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {
      picker_provider = 'telescope',
      toggle_key = '<Tab>',
    },
  },
}

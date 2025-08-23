return {
  'danymat/neogen',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('neogen').setup {
      enabled = true,
      languages = {
        rust = {
          annotation_convention = 'rustdoc',
          templates = {
            rustdoc = {
              function_template = {
                { '/// $1', 'summary' },
                { '///', '' },
                { '/// # Arguments', '' },
                { '///', '' },
                {
                  '/// - `${param.name}` (`${param.type}`) - Describe this parameter.',
                  'param',
                },
                { '///', '' },
                { '/// # Returns', '' },
                { '///', '' },
                {
                  '/// - `${return.type}` - Describe the return value.',
                  'return',
                },
                { '///', '' },
                { '/// # Examples', '' },
                { '///', '' },
              },
            },
          },
        },
      },
    }
  end,
  keys = {
    {
      '<leader>cg',
      function()
        require('neogen').generate()
      end,
      desc = '[C]ode [G]enerate Rust doc comment',
      mode = { 'n' },
    },
  },
}

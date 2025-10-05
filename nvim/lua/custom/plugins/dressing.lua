return {
  {
    'folke/dressing.nvim',
    event = 'VeryLazy',
    opts = function()
      local telescope_opts
      local ok, themes = pcall(require, 'telescope.themes')
      if ok then
        telescope_opts = themes.get_dropdown {
          layout_config = { width = 0.4 },
          winblend = 10,
        }
      end

      return {
        input = {
          enabled = true,
          win_options = {
            winblend = 10,
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
        select = {
          enabled = true,
          backend = { 'telescope', 'builtin' },
          telescope = telescope_opts,
          builtin = {
            relative = 'editor',
            border = 'rounded',
            win_options = {
              winblend = 10,
            },
          },
        },
      }
    end,
  },
}

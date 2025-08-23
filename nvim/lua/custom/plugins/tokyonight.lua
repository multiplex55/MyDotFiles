return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000, -- high priority to ensure it's loaded first (if you make it default)
    opts = {
      style = 'storm', -- "storm" | "night" | "moon" | "day"
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
      sidebars = { 'qf', 'help' },
      on_highlights = function(hl, c)
        -- Customize highlights here if desired
      end,
    },
  },
}

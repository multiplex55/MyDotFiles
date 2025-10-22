return {
  -- Primary configured themes
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
          enabled = false,
          shade = 'dark',
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { 'italic' },
          conditionals = { 'italic' },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
        },
      }

      -- Move this inside config block to ensure it's called AFTER plugin is loaded
      vim.cmd.colorscheme 'catppuccin'
    end,
  },
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
  {
    '0Risotto/rainbow12',
    lazy = true, -- Provides the rainbow12 colorscheme without setting it as default
  },

  -- Theme families (Nord, OneDark, Nightfox, Kanagawa, etc.)
  { 'shaunsingh/nord.nvim', lazy = true },
  { 'navarasu/onedark.nvim', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'sainnhe/gruvbox-material', lazy = true },
  { 'projekt0n/github-nvim-theme', lazy = true },
  { 'marko-cerovac/material.nvim', lazy = true },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },

  -- VS Code inspired
  { 'nyoom-engineering/oxocarbon.nvim', lazy = true }, -- IBM Carbon-inspired dark
  { 'askfiy/visual_studio_code', lazy = true }, -- vs-code inspired
  { 'Mofiqul/vscode.nvim', lazy = true }, -- another solid VSCode-like theme
  { 'lunarvim/darkplus.nvim', lazy = true }, -- VS Code dark+

  -- Additional dark palettes
  { 'bluz71/vim-nightfly-colors', name = 'nightfly', lazy = true },
  { 'fenetikm/falcon', lazy = true }, -- Deep dark purple-blue
  { 'yashguptaz/calvera-dark.nvim', lazy = true },
  { 'kvrohit/mellow.nvim', lazy = true }, -- Calm dim purple
  { 'ramojus/mellifluous.nvim', lazy = true }, -- Elegant, purply hues
  { 'mcchrish/zenbones.nvim', dependencies = { 'rktjmp/lush.nvim' }, lazy = true },
  { 'maxmx03/fluoromachine.nvim', lazy = true }, -- high-contrast, retro-futuristic
  { 'savq/melange-nvim', lazy = true }, -- warm, soft dark
  { 'sainnhe/everforest', lazy = true }, -- earthy green-dark
  { 'glepnir/zephyr-nvim', lazy = true }, -- dark with purple/cyan accents
  { 'NTBBloodbath/sweetie.nvim', lazy = true }, -- candy-colored dark
  { 'Shatur/neovim-ayu', lazy = true }, -- ayu-mirage: stylish and dark
  { 'xeind/nightingale.nvim', lazy = true },

  -- Atmospheric minimalism
  {
    'vague-theme/vague.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('vague').setup {}

      local original = vim.g.colors_name
      vim.cmd 'colorscheme vague'
      if original and original ~= 'vague' then
        vim.cmd('colorscheme ' .. original)
      end
    end,
  },

  -- Base16 Black Metal variants
  { 'metalelf0/base16-black-metal-scheme', lazy = true },

  -- Jellybeans palettes
  {
    'WTFox/jellybeans.nvim',
    lazy = true,
    opts = {
      palette = 'default',
      background = 'dark',
    },
  },

  -- Sitruuna
  {
    'eemed/sitruuna.vim',
    lazy = true,
    init = function()
      vim.g.sitruuna_fzf = 1
    end,
  },

  -- Monokai Pro
  { 'loctvl842/monokai-pro.nvim', lazy = true },
}

return {
  -- Treesitter: Zig + Zir
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs { 'zig', 'zir' } do
        if not vim.tbl_contains(opts.ensure_installed, lang) then
          table.insert(opts.ensure_installed, lang)
        end
      end
    end,
  },

  -- Make sure zls (and codelldb if you want) stay installed
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, pkg in ipairs { 'zls', 'codelldb' } do
        if not vim.tbl_contains(opts.ensure_installed, pkg) then
          table.insert(opts.ensure_installed, pkg)
        end
      end
    end,
  },

  -- LSP: zls
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        zls = {
          -- Use cmp_nvim_lsp caps if available; otherwise plain caps
          capabilities = (function()
            local caps = vim.lsp.protocol.make_client_capabilities()
            pcall(function()
              caps = require('cmp_nvim_lsp').default_capabilities(caps)
            end)
            return caps
          end)(),
          -- Good roots for Zig projects
          root_dir = function(fname)
            local util = require 'lspconfig.util'
            return util.root_pattern('build.zig', 'zig.zon', '.git')(fname) or util.path.dirname(fname)
          end,
          -- Optional: pin zig.exe explicitly on Windows if zls doesn’t find it
          settings = {
            zls = {
              enable_inlay_hints = true,
              -- zig_exe_path = "C:\\Program Files\\Zig\\zig.exe", -- uncomment if needed
            },
          },
        },
      },
    },
  },

  -- Formatting: zig fmt via Conform
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.zig = { 'zigfmt' } -- Conform has this builtin
      -- If you want format-on-save for Zig only:
      -- opts.format_on_save = opts.format_on_save or {}
      -- opts.format_on_save.lsp_format = "fallback"
    end,
  },
}

return {
  { -- RUST
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- plugin is already lazy
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
    config = function()
      local mason_registry = require 'mason-registry'
      -- local codelldb = mason_registry.get_package 'codelldb'

      -- Use environment variable to get install path
      local install_path = vim.fn.expand '$MASON' .. '\\packages\\codelldb'
      local extension_path = install_path .. '\\extension\\'
      local codelldb_path = extension_path .. 'adapter\\codelldb.exe'
      local liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
      local cfg = require 'rustaceanvim.config'

      vim.g.rustaceanvim = {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }

      -- Example: minimal rustaceanvim settings mirroring the “lighter” RA config
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ['rust-analyzer'] = {
              cargo = { allTargets = false, buildScripts = { enable = false } },
              procMacro = { enable = false },
              check = { command = 'check', workspace = false },
              cachePriming = { enable = false },
              files = { exclude = { 'dist', 'generated' } },
            },
          },
        },
      }
    end,
  },
}

-- lua/custom/plugins/mason.luama.
return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- MASON OVERRIDE UNTIL LAZY IS FIXED
      { 'mason-org/mason.nvim', config = true, lazy = false },
      { 'mason-org/mason-lspconfig.nvim' },

      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },

    config = function()
      ---------------------------------------------------------------------------
      -- LspAttach UX
      ---------------------------------------------------------------------------
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local ok, builtin = pcall(require, 'telescope.builtin')
          if not ok then
            local lazy_ok, lazy = pcall(require, 'lazy')
            if lazy_ok then
              lazy.load { plugins = { 'telescope.nvim' } }
              ok, builtin = pcall(require, 'telescope.builtin')
            end
          end

          if ok then
            map('<leader>gd', builtin.lsp_definitions, '[G]oto [D]efinition')
            map('<leader>gr', builtin.lsp_references, '[G]oto [R]eferences')
            map('<leader>gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
            map('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
            map('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
            map('<leader>sW', builtin.lsp_workspace_symbols, '[S]earch [W]orkspace symbols')
            map('<leader>sS', builtin.lsp_dynamic_workspace_symbols, '[S]earch dynamic [S]ymbols')
          end
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local ok_navic, navic = pcall(require, 'nvim-navic')
          if ok_navic and client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
            navic.attach(client, event.buf)
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local aug = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = aug, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = aug, callback = vim.lsp.buf.clear_references })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = ev.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-navic-detach', { clear = true }),
        callback = function(event)
          local ok_navic, navic = pcall(require, 'nvim-navic')
          if not ok_navic then
            return
          end

          local detach = nil
          if type(navic.detach) == 'function' then
            detach = navic.detach
          elseif type(navic.detach_buffer) == 'function' then
            detach = navic.detach_buffer
          elseif type(navic.remove_buffer) == 'function' then
            detach = navic.remove_buffer
          end

          if detach then
            pcall(detach, event.buf)
            return
          end

          local ok_lib, lib = pcall(require, 'nvim-navic.lib')
          if ok_lib and type(lib.clear_buffer_data) == 'function' then
            pcall(lib.clear_buffer_data, event.buf)
          end
        end,
      })

      ---------------------------------------------------------------------------
      -- Diagnostics glyphs
      ---------------------------------------------------------------------------
      if vim.g.have_nerd_font then
        vim.diagnostic.config {
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = '',
              [vim.diagnostic.severity.WARN] = '',
              [vim.diagnostic.severity.HINT] = '',
              [vim.diagnostic.severity.INFO] = '',
            },
          },
        }
      end

      ---------------------------------------------------------------------------
      -- Capabilities
      ---------------------------------------------------------------------------
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local util = require 'lspconfig.util' -- safe submodule for root helpers

      local servers = {
        gopls = {},
        nim_langserver = {}, -- aliased to 'nimls' below
        zls = {
          root_dir = function(fname)
            return util.root_pattern('build.zig', 'zig.zon', '.git')(fname) or util.path.dirname(fname)
          end,
          settings = {
            zls = {
              enable_inlay_hints = true,
              -- zig_exe_path = "C:\\Program Files\\Zig\\zig.exe",
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { disable = { 'missing-fields' }, globals = { 'vim', 'require' } },
              telemetry = { enable = false },
            },
          },
        },
        -- rust_analyzer = {},
        -- ts_ls = {},
      }

      ---------------------------------------------------------------------------
      -- Mason
      ---------------------------------------------------------------------------
      require('mason').setup()

      local ensure_tools = { 'stylua' }
      require('mason-tool-installer').setup { ensure_installed = ensure_tools }

      local server_aliases = {
        nim_langserver = 'nimls',
        tsserver = 'ts_ls',
      }

      local function normalize_server_name(name)
        return server_aliases[name] or name
      end

      local mlsp = require 'mason-lspconfig'
      local ids = {}
      local seen = {}
      for name, _ in pairs(servers) do
        local id = normalize_server_name(name)
        if not seen[id] then
          table.insert(ids, id)
          seen[id] = true
        end
      end

      mlsp.setup {
        ensure_installed = ids,
        automatic_enable = false,
      }

      for name, cfg in pairs(servers) do
        local server_name = normalize_server_name(name)
        local merged_config = vim.tbl_deep_extend('force', {
          capabilities = vim.tbl_deep_extend('force', {}, capabilities),
        }, cfg or {})

        vim.lsp.config(server_name, merged_config)
        vim.lsp.enable(server_name)
      end
    end,
  },
}

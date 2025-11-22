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
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
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
        nim_langserver = {}, -- we'll alias this to 'nimls' below
        zls = {
          root_dir = function(fname)
            return util.root_pattern('build.zig', 'zig.zon', '.git')(fname) or util.path.dirname(fname)
          end,
          settings = {
            zls = {
              enable_inlay_hints = true,
              -- zig_exe_path = "C:\\\\Program Files\\\\Zig\\\\zig.exe",
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

      local mason_alias = { tsserver = 'ts_ls' }
      local function norm(name)
        return mason_alias[name] or name
      end

      local mlsp = require 'mason-lspconfig'
      local ids = {}
      for name, _ in pairs(servers) do
        table.insert(ids, norm(name))
      end
      mlsp.setup { ensure_installed = ids }

      ---------------------------------------------------------------------------
      -- Start servers WITHOUT touching lspconfig's deprecated root
      -- (No require('lspconfig'), no "unknown server" warnings)
      ---------------------------------------------------------------------------
      local builtin_defaults = {
        lua_ls = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_dir = function(fname)
            return util.root_pattern('.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', 'selene.toml', '.git')(fname) or util.path.dirname(fname)
          end,
        },
        gopls = {
          cmd = { 'gopls' },
          filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
          root_dir = function(fname)
            return util.root_pattern('go.work', 'go.mod', '.git')(fname) or util.path.dirname(fname)
          end,
        },
        zls = {
          cmd = { 'zls' },
          filetypes = { 'zig', 'zir' },
          root_dir = function(fname)
            return util.root_pattern('build.zig', 'zig.zon', '.git')(fname) or util.path.dirname(fname)
          end,
        },
        nimls = {
          cmd = { 'nimlangserver' }, -- mason installs this exe
          filetypes = { 'nim', 'nims' },
          root_dir = function(fname)
            return util.root_pattern '.git'(fname) or util.path.dirname(fname)
          end,
        },
      }

      local id_alias = { nim_langserver = 'nimls', tsserver = 'ts_ls' }

      local function start_server(name, user_cfg)
        local id = id_alias[name] or name
        local d = builtin_defaults[id] or {}

        local final = vim.tbl_deep_extend('force', {}, d, user_cfg or {})
        final.capabilities = vim.tbl_deep_extend('force', {}, capabilities, final.capabilities or {})
        final.name = final.name or id

        local fts = final.filetypes or {}
        if #fts == 0 then
          fts = { '*' }
        end

        vim.api.nvim_create_autocmd('FileType', {
          pattern = fts,
          callback = function(args)
            if vim.lsp.get_clients({ bufnr = args.buf, name = final.name })[1] then
              return
            end

            local fname = vim.api.nvim_buf_get_name(args.buf)
            local root = final.root_dir
            if type(root) == 'function' then
              root = root(fname)
            end
            if not root or root == '' then
              root = util.root_pattern '.git'(fname) or util.path.dirname(fname)
            end

            vim.lsp.start(vim.tbl_deep_extend('force', final, { root_dir = root }), { bufnr = args.buf })
          end,
        })
      end

      for name, cfg in pairs(servers) do
        start_server(name, cfg)
      end
    end,
  },
}

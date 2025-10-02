-- lua/custom/plugins/rhai.lua
return {
  { 'kuon/rhai.vim' },
  -------------------------------------------------------------------------
  -- 1) Treesitter: register external Rhai parser + ensure it's installed
  -------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.rhai = parser_config.rhai
        or {
          install_info = {
            url = 'https://github.com/elkowar/tree-sitter-rhai',
            files = { 'src/parser.c' },
          },
          filetype = 'rhai',
        }

      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, 'rhai') then
        table.insert(opts.ensure_installed, 'rhai')
      end
    end,
  },

  -------------------------------------------------------------------------
  -- 2) LSP + tooling integration for Rhai
  -------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    init = function()
      vim.filetype.add { extension = { rhai = 'rhai' } }

      require 'lspconfig'
      local rhai_utils = require 'custom.lang.rhai'

      local notified_roots = {}

      local function notify_status(success, root, err)
        root = root or vim.fn.getcwd()
        if success then
          if notified_roots[root] then
            return
          end
          notified_roots[root] = true
          vim.notify(('Rhai tooling ready (%s)'):format(root), vim.log.levels.INFO)
          return
        end
        local msg = 'Failed to start Rhai tooling'
        if err and err ~= '' then
          msg = ('%s: %s'):format(msg, err)
        end
        vim.notify(msg, vim.log.levels.ERROR)
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rhai',
        callback = function(args)
          local buf = args.buf
          local fname = vim.api.nvim_buf_get_name(buf)
          local root = rhai_utils.get_root(fname)

          if vim.lsp.get_clients { bufnr = buf, name = 'rhai-lsp' }[1] then
            notify_status(true, root)
            return
          end

          for _, client in ipairs(vim.lsp.get_clients { name = 'rhai-lsp' }) do
            if client.config and client.config.root_dir == root then
              vim.lsp.buf_attach_client(buf, client.id)
              notify_status(true, root)
              return
            end
          end

          if not rhai_utils.rhai_executable() then
            return
          end

          local ok, result = pcall(vim.lsp.start, {
            name = 'rhai-lsp',
            cmd = { 'rhai', 'lsp', 'stdio' },
            root_dir = root,
          }, { bufnr = buf })

          if not ok then
            notify_status(false, root, result)
            return
          end

          if result then
            notify_status(true, root)
          else
            notify_status(false, root)
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rhai',
        callback = function(ev)
          local buf = ev.buf
          rhai_utils.format_buffer(buf)
        end,
      })

      pcall(require('which-key').add, {
        { '<leader>cR', group = '[C]ode [R]hai' },
      })
    end,
  },
}

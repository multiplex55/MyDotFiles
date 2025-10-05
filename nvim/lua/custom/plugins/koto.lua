-- lua/custom/plugins/koto.lua
return {
  { 'koto-lang/koto.vim' },
  -------------------------------------------------------------------------
  -- 1) Treesitter: register external Koto parser + ensure it's installed
  -------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.koto = parser_config.koto
        or {
          install_info = {
            url = 'https://github.com/koto-lang/tree-sitter-koto',
            files = { 'src/parser.c', 'src/scanner.c' },
          },
          filetype = 'koto',
        }
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, 'koto') then
        table.insert(opts.ensure_installed, 'koto')
      end
    end,
  },

  -------------------------------------------------------------------------
  -- 2) LSP: start koto-ls when opening a *.koto file (no lspconfig root)
  -------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig', -- only for utilities; we won't call the deprecated root
    lazy = false,
    init = function()
      -- Make sure *.koto is recognized
      vim.filetype.add { extension = { koto = 'koto' } }

      -- Use lspconfig.util just for root detection (safe submodule)
      local util = require 'lspconfig.util'

      -- Start koto-ls on Koto buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'koto',
        callback = function(args)
          -- avoid duplicate attach
          if vim.lsp.get_clients({ bufnr = args.buf, name = 'koto-ls' })[1] then
            return
          end
          local fname = vim.api.nvim_buf_get_name(args.buf)
          local root = util.root_pattern '.git'(fname) or util.path.dirname(fname)

          vim.lsp.start({
            name = 'koto-ls',
            cmd = { 'koto-ls' }, -- ensure it's on PATH (cargo install koto-ls)
            root_dir = root,
          }, { bufnr = args.buf })
        end,
      })

      -- Format on save for Koto
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.koto',
        callback = function(ev)
          if vim.lsp.buf.format then
            vim.lsp.buf.format { bufnr = ev.buf, async = false }
          end
        end,
      })

      -------------------------------------------------------------------------
      -- 3) Keybinds: <leader>ck… group
      -------------------------------------------------------------------------
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'koto',
        callback = function(ev)
          local buf = ev.buf
          pcall(function()
            require('which-key').add {
              {
                '<leader>ck',
                group = '[C]ode [K]oto',
                mode = 'n',
                buffer = buf,
              },
            }
          end)
          local function map(lhs, rhs, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          local function ensure_koto_file()
            local file = vim.api.nvim_buf_get_name(buf)
            if file == '' or not file:match '%.koto$' then
              vim.notify('Not a .koto buffer', vim.log.levels.WARN)
              return nil
            end
            return file
          end

          local function run_overseer(cmd, args, cwd)
            local ok, overseer = pcall(require, 'overseer')
            if not ok then
              return false
            end
            local task = overseer.new_task {
              cmd = cmd,
              args = args or {},
              cwd = cwd or vim.fn.getcwd(),
              components = { 'default' },
            }
            task:start()
            overseer.open { enter = false, direction = 'bottom' }
            return true
          end

          local function term_run(cmdline)
            vim.cmd('botright 12split | terminal ' .. cmdline)
            vim.cmd 'startinsert'
          end

          -- <leader>ckr — Run current file
          map('<leader>ckr', function()
            local file = ensure_koto_file()
            if not file then
              return
            end
            if not run_overseer('koto', { file }) then
              term_run(string.format('koto "%s"', file))
            end
          end, '[C]ode [K]oto [R]un')

          -- <leader>ckR — Run current file with args (prompt)
          map('<leader>ckR', function()
            local file = ensure_koto_file()
            if not file then
              return
            end
            vim.ui.input({ prompt = 'koto args: ' }, function(input)
              local args = {}
              if input and #input > 0 then
                for a in string.gmatch(input, '%S+') do
                  table.insert(args, a)
                end
              end
              if not run_overseer('koto', vim.list_extend({ file }, args)) then
                local cmdline = 'koto "' .. file .. '" ' .. (input or '')
                term_run(cmdline)
              end
            end)
          end, '[C]ode [K]oto [R]un (args)')

          -- <leader>ckt — Koto REPL (terminal/task)
          map('<leader>ckt', function()
            if not run_overseer 'koto' then
              term_run 'koto'
            end
          end, '[C]ode [K]oto [T]erm REPL')

          -- LSP helpers (buffer-local)
          map('<leader>ckf', function()
            vim.lsp.buf.format { async = false }
          end, '[C]ode [K]oto [F]ormat')
          map('<leader>ckh', vim.lsp.buf.hover, '[C]ode [K]oto [H]over')
          map('<leader>ckg', vim.lsp.buf.definition, '[C]ode [K]oto [G]oto def')
          map('<leader>ckn', vim.lsp.buf.rename, '[C]ode [K]oto Re[n]ame')
          map('<leader>cka', vim.lsp.buf.code_action, '[C]ode [K]oto Code [A]ction', { 'n', 'x' })
        end,
      })
    end,
  },
}

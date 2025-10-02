-- lua/custom/plugins/rhai.lua
return {
  { 'kuon/rhai.vim' },

  -------------------------------------------------------------------------
  -- Treesitter: register external Rhai parser + ensure it's installed
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
  -- LSP + helpers: start rhai lsp/cli tooling when opening a *.rhai buffer
  -------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    init = function()
      vim.filetype.add { extension = { rhai = 'rhai' } }

      local util = require 'lspconfig.util'
      local root_pattern = util.root_pattern('Rhai.toml', '.git')

      local function ensure_rhai_file(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local file = vim.api.nvim_buf_get_name(buf)
        if file == '' or not file:match '%.rhai$' then
          vim.notify('Not a .rhai buffer', vim.log.levels.WARN)
          return nil
        end
        return file
      end

      local function has_rhai_cli(opts)
        if vim.fn.executable 'rhai' == 1 then
          return true
        end
        if not (opts and opts.silent) then
          vim.notify('`rhai` CLI not found (cargo install --git https://github.com/rhaiscript/lsp rhai-cli)', vim.log.levels.WARN)
        end
        return false
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

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rhai',
        callback = function(args)
          local buf = args.buf

          if not has_rhai_cli { silent = true } then
            return
          end

          if vim.lsp.get_clients { bufnr = buf, name = 'rhai-lsp' }[1] then
            return
          end

          local fname = vim.api.nvim_buf_get_name(buf)
          local root = root_pattern(fname) or util.path.dirname(fname)
          root = root or vim.loop.cwd() or vim.fn.getcwd()

          local client_id = vim.lsp.start({
            name = 'rhai-lsp',
            cmd = { 'rhai', 'lsp', 'stdio' },
            root_dir = root,
          }, { bufnr = buf })

          if client_id then
            vim.notify(
              string.format('Rhai LSP attached (client id: %s)', client_id),
              vim.log.levels.INFO
            )
          else
            vim.notify('Failed to start Rhai LSP', vim.log.levels.ERROR)
          end

          local function run_cli(args, term_cmd)
            if not has_rhai_cli() then
              return
            end
            if not run_overseer('rhai', args) then
              term_run(term_cmd)
            end
          end

          vim.keymap.set('n', '<leader>cRf', function()
            vim.lsp.buf.format { async = false }
          end, { buffer = buf, desc = '[C]ode [R]hai [F]ormat' })
          vim.keymap.set('n', '<leader>cRh', vim.lsp.buf.hover, { buffer = buf, desc = '[C]ode [R]hai [H]over' })
          vim.keymap.set('n', '<leader>cRg', vim.lsp.buf.definition, { buffer = buf, desc = '[C]ode [R]hai [G]oto def' })
          vim.keymap.set('n', '<leader>cRn', vim.lsp.buf.rename, { buffer = buf, desc = '[C]ode [R]hai Re[n]ame' })
          vim.keymap.set({ 'n', 'x' }, '<leader>cRa', vim.lsp.buf.code_action, {
            buffer = buf,
            desc = '[C]ode [R]hai Code [A]ction',
          })

          vim.keymap.set('n', '<leader>cRr', function()
            local file = ensure_rhai_file(buf)
            if not file then
              return
            end
            local escaped = vim.fn.shellescape(file)
            run_cli({ 'run', file }, string.format('rhai run %s', escaped))
          end, { buffer = buf, desc = '[C]ode [R]hai [R]un' })

          vim.keymap.set('n', '<leader>cRF', function()
            local file = ensure_rhai_file(buf)
            if not file then
              return
            end
            local escaped = vim.fn.shellescape(file)
            run_cli({ 'fmt', file }, string.format('rhai fmt %s', escaped))
          end, { buffer = buf, desc = '[C]ode [R]hai [F]mt (CLI)' })

          vim.keymap.set('n', '<leader>cRt', function()
            if not has_rhai_cli() then
              return
            end
            if not run_overseer('rhai', { 'repl' }) then
              term_run 'rhai repl'
            end
          end, { buffer = buf, desc = '[C]ode [R]hai [T]erm REPL' })
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rhai',
        callback = function(ev)
          local clients = vim.lsp.get_clients { bufnr = ev.buf }
          for _, client in ipairs(clients) do
            if client.name == 'rhai-lsp' and client.server_capabilities and client.server_capabilities.documentFormattingProvider then
              vim.lsp.buf.format { bufnr = ev.buf, async = false }
              return
            end
          end
        end,
      })

      pcall(function()
        require('which-key').add { { '<leader>cR', group = '[C]ode [R]hai' } }
      end)
    end,
  },
}

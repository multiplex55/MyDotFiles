-- lua/custom/plugins/rhai.lua
return {
  { 'kuon/rhai.vim' },

  ---------------------------------------------------------------------------
  -- Treesitter: register external Rhai parser and ensure it's installed
  ---------------------------------------------------------------------------
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

  ---------------------------------------------------------------------------
  -- LSP + keymaps for Rhai buffers
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    init = function()
      vim.filetype.add { extension = { rhai = 'rhai' } }

      local util = require 'lspconfig.util'

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rhai',
        callback = function(args)
          local buf = args.buf
          local fname = vim.api.nvim_buf_get_name(buf)

          if not vim.lsp.get_clients({ bufnr = buf, name = 'rhai-lsp' })[1] then
            local root = util.root_pattern('Rhai.toml', '.git')(fname) or util.path.dirname(fname)
            vim.lsp.start({
              name = 'rhai-lsp',
              cmd = { 'rhai', 'lsp', 'stdio' },
              root_dir = root,
            }, { bufnr = buf })
          end

          local function ensure_rhai_file()
            local file = vim.api.nvim_buf_get_name(buf)
            if file == '' or not file:match('%.rhai$') then
              vim.notify('Not a .rhai buffer', vim.log.levels.WARN)
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

          -- <leader>cRr — Run current file
          vim.keymap.set('n', '<leader>cRr', function()
            local file = ensure_rhai_file()
            if not file then
              return
            end
            if not run_overseer('rhai-run', { file }) then
              term_run(string.format('rhai-run "%s"', file))
            end
          end, { buffer = buf, desc = '[C]ode [R]hai [R]un' })

          -- <leader>cRt — Rhai REPL
          vim.keymap.set('n', '<leader>cRt', function()
            if not run_overseer 'rhai-repl' then
              term_run 'rhai-repl'
            end
          end, { buffer = buf, desc = '[C]ode [R]hai [T]erm REPL' })

          -- LSP helpers
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
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rhai',
        callback = function(ev)
          if vim.lsp.buf.format then
            vim.lsp.buf.format { bufnr = ev.buf, async = false }
          end
        end,
      })

      pcall(function()
        require('which-key').add { { '<leader>cR', group = '[C]ode [R]hai' } }
      end)
    end,
  },
}

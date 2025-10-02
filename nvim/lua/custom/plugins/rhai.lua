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

      local lspconfig = require 'lspconfig'
      local util = lspconfig.util

      local function get_root(fname)
        if fname and fname ~= '' then
          return util.root_pattern('Rhai.toml', '.git')(fname) or util.path.dirname(fname)
        end
        return vim.fn.getcwd()
      end

      local function has_formatter(bufnr)
        for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
          if client.supports_method and client:supports_method 'textDocument/formatting' then
            return true
          end
        end
        return false
      end

      local function rhai_executable(opts)
        if vim.fn.executable 'rhai' == 1 then
          return true
        end
        if not (opts and opts.silent) then
          vim.notify('`rhai` executable not found in PATH', vim.log.levels.WARN)
        end
        return false
      end

      local function cli_fmt(file, root, opts)
        if not rhai_executable(opts) then
          return false
        end
        local result = vim.system({ 'rhai', 'fmt', file }, { cwd = root, text = true }):wait()
        if result.code ~= 0 then
          local err = result.stderr
          if err == '' then
            err = result.stdout
          end
          vim.notify('rhai fmt failed: ' .. (err ~= '' and err or 'unknown error'), vim.log.levels.ERROR)
          return false
        end
        return true
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rhai',
        callback = function(args)
          local buf = args.buf
          local fname = vim.api.nvim_buf_get_name(buf)
          local root = get_root(fname)

          if vim.lsp.get_clients { bufnr = buf, name = 'rhai-lsp' }[1] then
            return
          end

          for _, client in ipairs(vim.lsp.get_clients { name = 'rhai-lsp' }) do
            if client.config and client.config.root_dir == root then
              vim.lsp.buf_attach_client(buf, client.id)
              return
            end
          end

          if not rhai_executable() then
            return
          end

          vim.lsp.start({
            name = 'rhai-lsp',
            cmd = { 'rhai', 'lsp', 'stdio' },
            root_dir = root,
          }, { bufnr = buf })
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rhai',
        callback = function(ev)
          local buf = ev.buf
          if has_formatter(buf) then
            vim.lsp.buf.format { bufnr = buf, async = false }
            return
          end

          local file = vim.api.nvim_buf_get_name(buf)
          if file == '' then
            return
          end

          local root = get_root(file)
          if cli_fmt(file, root) then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd('silent! keepalt keepjumps noautocmd edit!')
            end)
          end
        end,
      })

      pcall(require('which-key').add, {
        { '<leader>cR', group = '[C]ode [R]hai' },
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rhai',
        callback = function(ev)
          local buf = ev.buf
          local fname = vim.api.nvim_buf_get_name(buf)
          local root = get_root(fname)

          local function ensure_rhai_file()
            local file = vim.api.nvim_buf_get_name(buf)
            if file == '' or not file:match '%.rhai$' then
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
              cwd = cwd or root,
              components = { 'default' },
            }
            task:start()
            overseer.open { enter = false, direction = 'bottom' }
            return true
          end

          local function term_run(cmd, args, cwd)
            cwd = cwd or root
            vim.cmd 'botright 12split'
            local win = vim.api.nvim_get_current_win()
            local command = vim.list_extend({ cmd }, args or {})
            vim.fn.termopen(command, { cwd = cwd })
            vim.api.nvim_set_current_win(win)
            vim.cmd 'startinsert'
          end

          local function format_current_buffer()
            if has_formatter(buf) then
              vim.lsp.buf.format { bufnr = buf, async = false }
              return true
            end
            local file = ensure_rhai_file()
            if not file then
              return false
            end
            local ok = cli_fmt(file, root)
            if ok then
              vim.api.nvim_buf_call(buf, function()
                vim.cmd('silent! keepalt keepjumps noautocmd edit!')
              end)
            end
            return ok
          end

          vim.keymap.set('n', '<leader>cRf', function()
            format_current_buffer()
          end, { buffer = buf, desc = '[C]ode [R]hai [F]ormat buffer' })

          vim.keymap.set('n', '<leader>cRF', function()
            if not rhai_executable() then
              return
            end
            local args = { 'fmt' }
            if not run_overseer('rhai', args, root) then
              term_run('rhai', args, root)
            end
          end, { buffer = buf, desc = '[C]ode [R]hai [F]ormat workspace' })

          vim.keymap.set('n', '<leader>cRc', function()
            if not rhai_executable() then
              return
            end
            local args = { 'fmt', '--check' }
            if not run_overseer('rhai', args, root) then
              term_run('rhai', args, root)
            end
          end, { buffer = buf, desc = '[C]ode [R]hai [C]heck formatting' })

          vim.keymap.set('n', '<leader>cRh', vim.lsp.buf.hover, { buffer = buf, desc = '[C]ode [R]hai [H]over' })
          vim.keymap.set('n', '<leader>cRg', vim.lsp.buf.definition, { buffer = buf, desc = '[C]ode [R]hai [G]oto def' })
          vim.keymap.set('n', '<leader>cRn', vim.lsp.buf.rename, { buffer = buf, desc = '[C]ode [R]hai Re[n]ame' })
          vim.keymap.set({ 'n', 'x' }, '<leader>cRa', vim.lsp.buf.code_action, {
            buffer = buf,
            desc = '[C]ode [R]hai Code [A]ction',
          })
        end,
      })
    end,
  },
}

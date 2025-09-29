return {
  {
    'saecki/crates.nvim',
    version = '^0.4.0',
    event = {
      'BufReadPost Cargo.toml',
      'BufNewFile Cargo.toml',
      'BufReadPost *.crate',
      'BufNewFile *.crate',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      completion = {
        cmp = {
          enabled = true,
        },
      },
      popup = {
        autofocus = true,
      },
      notification = {
        title = 'Crates',
      },
    },
    config = function(_, opts)
      local crates = require 'crates'
      crates.setup(opts)

      local cmp_ok, cmp = pcall(require, 'cmp')

      local function attach(bufnr)
        if cmp_ok and cmp then
          local sources = cmp.get_config().sources or {}
          cmp.setup.buffer {
            sources = cmp.config.sources({ { name = 'crates' } }, sources),
          }
        end

        local keymap_opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', '<leader>ccD', crates.open_documentation, vim.tbl_extend('force', keymap_opts, {
          desc = '[C]ode [C]rates [D]ocumentation',
        })) -- Jump straight to the crates.io docs page for the dependency under the cursor.
        vim.keymap.set('n', '<leader>ccU', crates.upgrade_crate, vim.tbl_extend('force', keymap_opts, {
          desc = '[C]ode [C]rates [U]pgrade crate',
        })) -- Replace the current dependency specification with the newest published release, even if it breaks semver guarantees.
        vim.keymap.set('n', '<leader>ccu', crates.update_crate, vim.tbl_extend('force', keymap_opts, {
          desc = '[C]ode [C]rates [u]pdate compatible',
        })) -- Update the dependency only to the latest version that still satisfies the existing semver requirement.

        local ok, wk = pcall(require, 'which-key')
        if ok then
          wk.add {
            {
              '<leader>cc',
              group = '[C]ode [C]rates',
              mode = { 'n' },
              buffer = bufnr,
            },
            {
              '<leader>ccD',
              '[C]ode [C]rates [D]ocumentation',
              mode = 'n',
              buffer = bufnr,
            },
            {
              '<leader>ccU',
              '[C]ode [C]rates [U]pgrade crate',
              mode = 'n',
              buffer = bufnr,
            },
            {
              '<leader>ccu',
              '[C]ode [C]rates [u]pdate compatible',
              mode = 'n',
              buffer = bufnr,
            },
          }
        end
      end

      local group = vim.api.nvim_create_augroup('CratesNvimCustom', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
        group = group,
        pattern = { 'Cargo.toml', '*.crate' },
        callback = function(args)
          attach(args.buf)
        end,
      })

      local current = vim.api.nvim_get_current_buf()
      local name = vim.api.nvim_buf_get_name(current)
      if name:match('Cargo%.toml$') or name:match('%.crate$') then
        attach(current)
      end
    end,
  },
}

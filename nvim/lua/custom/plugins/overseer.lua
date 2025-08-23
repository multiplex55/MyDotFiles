return {
  {
    'stevearc/overseer.nvim',
    opts = {
      strategy = {
        'terminal', -- options: "terminal", "toggleterm", "jobstart"
        direction = 'horizontal', -- "horizontal", "vertical", "tab", "float"
        open_on_start = true,
        close_on_exit = true,
      },
      task_list = {
        direction = 'bottom',
        min_height = 15,
        max_height = 25,
        default_detail = 1,
      },
    },
    config = function(_, opts)
      local overseer = require 'overseer'
      overseer.setup(opts)

      local util = require 'overseer.util'

      -- Automatically jump to terminal window when a task starts
      vim.api.nvim_create_autocmd('User', {
        pattern = 'OverseerTaskStarted',
        callback = function()
          vim.defer_fn(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == 'terminal' then
                vim.api.nvim_set_current_win(win)
                break
              end
            end
          end, 50)
        end,
      })

      -- Register Nim template
      overseer.register_template {
        name = 'Run Nim File',
        builder = function()
          local file = vim.fn.expand '%:p'
          return {
            name = 'Run Nim File',
            cmd = { 'nim' },
            args = { 'compile', '--run', file },
            cwd = util.buffer_dir(),
            env = {},
            components = {
              { 'on_output_quickfix', open = false },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'nim' },
        },
      }

      -- Register Rust template
      overseer.register_template {
        name = 'Run Rust Project',
        builder = function()
          return {
            name = 'Run Rust',
            cmd = { 'cargo' },
            args = { 'run' },
            cwd = util.buffer_dir(),
            env = {},
            components = {
              { 'on_output_quickfix', open = false },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'rust' },
        },
      }

      -- Register Lua template
      overseer.register_template {
        name = 'Run Lua File',
        builder = function()
          local file = vim.fn.expand '%:p'
          return {
            name = 'Run Lua File',
            cmd = { 'lua' },
            args = { file },
            cwd = util.buffer_dir(),
            env = {},
            components = {
              { 'on_output_quickfix', open = false },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'lua' },
        },
      }
    end,
  },
}

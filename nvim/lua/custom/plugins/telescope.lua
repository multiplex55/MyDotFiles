return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      {
        '<leader>sh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = '[S]earch [H]elp',
      },
      {
        '<leader>sk',
        function()
          require('telescope.builtin').keymaps()
        end,
        desc = '[S]earch [K]eymaps',
      },
      {
        '<leader>sf',
        function()
          require('telescope.builtin').find_files()
        end,
        desc = '[S]earch [F]iles',
      },
      {
        '<leader>st',
        '<cmd>Telescope<cr>',
        desc = '[S]earch [S]elect Telescope',
      },
      {
        '<leader>sT',
        function()
          require('telescope-tabs').list_tabs()
        end,
        desc = '[S]earch [T]abs',
      },
      {
        '<leader>sw',
        function()
          require('telescope.builtin').grep_string()
        end,
        desc = '[S]earch current [W]ord',
      },
      {
        '<leader>sg',
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = '[S]earch by [G]rep',
      },
      {
        '<leader>sG',
        function()
          require('telescope.builtin').live_grep {
            additional_args = function()
              return { '--no-ignore' }
            end,
          }
        end,
        desc = '[s]earch [G]rep (ignore)',
      },
      {
        '<leader>se',
        function()
          require('telescope.builtin').live_grep {
            additional_args = function()
              return { '--no-ignore' }
            end,
          }
        end,
        desc = '[s]earch grep [e]xact',
      },
      {
        '<leader>sd',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = '[S]earch [D]iagnostics',
      },
      {
        '<leader>s.',
        function()
          require('telescope.builtin').oldfiles()
        end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      {
        '<leader><leader>',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = '[ ] Find existing buffers',
      },
      {
        '<leader>sq',
        function()
          vim.diagnostic.setqflist()
        end,
        desc = '[S]earch [Q]uickfix diagnostics (Trouble/Bqf)',
      },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = '[S]earch [/] in Open Files',
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files {
            cwd = vim.fn.stdpath 'config',
          }
        end,
        desc = '[S]earch [N]eovim files',
      },
      {
        '<leader>sR',
        function()
          require('telescope.builtin').registers()
        end,
        desc = '[S]earch Yanks / [R]egisters',
      },
      {
        '<leader>sy',
        function()
          local ok, neoclip = pcall(function()
            return require('telescope').extensions.neoclip
          end)
          if not ok or not neoclip or not neoclip.default then
            return
          end
          neoclip.default({
            extra = 'unnamed',
          })
        end,
        desc = '[S]earch [Y]ank history',
      },
      {
        '<leader>sY',
        function()
          local ok, neoclip = pcall(function()
            return require('telescope').extensions.neoclip
          end)
          if not ok or not neoclip or not neoclip.plus then
            return
          end
          neoclip.plus({
            extra = 'unnamed',
          })
        end,
        desc = '[S]earch system [Y]anks',
      },
      {
        '<leader>sW',
        function()
          require('telescope.builtin').lsp_workspace_symbols()
        end,
        desc = '[S]earch [W]orkspace symbols',
      },
      {
        '<leader>su',
        function()
          require('telescope').extensions.undo.undo()
        end,
        desc = '[S]earch [U]ndo history',
      },
      {
        '<leader>sS',
        function()
          require('telescope.builtin').lsp_dynamic_workspace_symbols()
        end,
        desc = '[S]earch dynamic [S]ymbols',
      },
    },
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' }, -- Useful for getting pretty icons, but requires a Nerd Font.
      'debugloop/telescope-undo.nvim',
      'LukasPietzschmann/telescope-tabs',
      {
        'nvim-tree/nvim-web-devicons',
        enabled = vim.g.have_nerd_font,
      },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      require('telescope-tabs').setup {}

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'undo')
      pcall(require('telescope').load_extension, 'telescope-tabs')

      pcall(require('telescope').load_extension, 'session-lens')
      pcall(require('telescope').load_extension, 'neoclip')

      -- See `:help telescope.builtin`
    end,
  },
}

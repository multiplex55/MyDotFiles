-- Color switching
local M = {}

M.switch_colorscheme = function()
  local themes = {
    -- Catppuccin
    'catppuccin',

    -- TokyoNight variants
    'tokyonight',
    'tokyonight-night',
    'tokyonight-moon',
    'tokyonight-day',

    -- OneDark & Nord
    'onedark',
    'nord',

    -- Nightfox variants
    'carbonfox',
    'duskfox',
    'nightfox',
    'dayfox',
    'nordfox',
    'terafox',

    -- Kanagawa variants
    'kanagawa',
    'kanagawa-wave',
    'kanagawa-dragon',
    'kanagawa-lotus',

    -- Gruvbox Material
    'gruvbox-material',

    -- GitHub variants
    'github_dark_default',
    'github_dark_dimmed',
    'github_dark_high_contrast',
    'github_light',
    'github_light_default',
    'github_light_high_contrast',

    -- Material
    'material',

    -- Rose Pine variants
    'rose-pine',
    'rose-pine-moon',
    'rose-pine-dawn',

    -- Others
    'oxocarbon',
    'nightfly',
    'falcon',
    'calvera-dark',
    'mellow',
    'mellifluous',
    'darkplus',
    'zenbones',
    'fluoromachine',
    'visual_studio_code',
    'vscode',
    'melange',
    'everforest',
    'zephyr',
    'sweetie',
    'ayu-mirage',

    -- Monokai Pro variants
    'monokai-pro',
    'monokai-pro-spectrum',
    'monokai-pro-octagon',
    'monokai-pro-machine',
    'monokai-pro-ristretto',
    'monokai-pro-classic',
  }

  local original = vim.g.colors_name

  require('telescope.pickers')
    .new({
      layout_config = {
        width = 0.33,
        height = 0.5,
        prompt_position = 'top',
      },
      layout_strategy = 'vertical',
    }, {
      prompt_title = '🎨 Switch Colorscheme',
      finder = require('telescope.finders').new_table { results = themes },
      sorter = require('telescope.config').values.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        local actions = require 'telescope.actions'
        local state = require 'telescope.actions.state'

        local function preview()
          local entry = state.get_selected_entry()
          if not entry then
            return
          end

          local ok = pcall(vim.cmd.colorscheme, entry.value)
          if not ok then
            return
          end

          local ibl_ok, ibl = pcall(require, 'ibl')
          if not ibl_ok then
            return
          end

          -- Define essential fallback highlights (colors may be adjusted)
          vim.api.nvim_set_hl(0, 'RainbowIndent1', { fg = '#E06C75' })
          vim.api.nvim_set_hl(0, 'RainbowIndent2', { fg = '#E5C07B' })
          vim.api.nvim_set_hl(0, 'RainbowIndent3', { fg = '#98C379' })
          vim.api.nvim_set_hl(0, 'RainbowIndent4', { fg = '#56B6C2' })
          vim.api.nvim_set_hl(0, 'RainbowIndent5', { fg = '#61AFEF' })
          vim.api.nvim_set_hl(0, 'RainbowIndent6', { fg = '#C678DD' })
          vim.api.nvim_set_hl(0, 'RainbowIndent7', { fg = '#ABB2BF' })

          -- Clear any virtual text IBL may have placed
          if ibl.clear_all then
            pcall(ibl.clear_all)
          end

          -- Setup IBL again
          pcall(ibl.setup, {
            indent = {
              char = '│',
              tab_char = '│',
              highlight = {
                'RainbowIndent1',
                'RainbowIndent2',
                'RainbowIndent3',
                'RainbowIndent4',
                'RainbowIndent5',
                'RainbowIndent6',
                'RainbowIndent7',
              },
            },
            scope = {
              enabled = true,
              highlight = {
                'RainbowIndent1',
                'RainbowIndent2',
                'RainbowIndent3',
                'RainbowIndent4',
                'RainbowIndent5',
                'RainbowIndent6',
                'RainbowIndent7',
              },
            },
          })
        end

        vim.defer_fn(preview, 0)

        -- Live preview on selection change
        map('i', '<Down>', function()
          actions.move_selection_next(prompt_bufnr)
          preview()
        end)
        map('i', '<Up>', function()
          actions.move_selection_previous(prompt_bufnr)
          preview()
        end)
        map('i', '<C-n>', function()
          actions.move_selection_next(prompt_bufnr)
          preview()
        end)
        map('i', '<C-p>', function()
          actions.move_selection_previous(prompt_bufnr)
          preview()
        end)

        -- Confirm selection
        map('i', '<CR>', function()
          actions.close(prompt_bufnr)
        end)

        -- Revert on cancel
        map('i', '<Esc>', function()
          pcall(vim.cmd.colorscheme, original)
          actions.close(prompt_bufnr)
        end)

        return true
      end,
    })
    :find()
end
return M

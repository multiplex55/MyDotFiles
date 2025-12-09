-- Color switching
local M = {}

M.switch_colorscheme = function()
  local themes = {
    -- Catppuccin
    'catppuccin',

    -- Vague
    'vague',

    -- Rainbow12 palette for vibrant contrast testing
    'rainbow12',

    -- TokyoNight variants
    'tokyonight',
    'tokyonight-night',
    'tokyonight-moon',
    -- 'tokyonight-day',

    -- OneDark & Nord
    'onedark',
    'nord',

    -- Nightfox variants
    'carbonfox',
    'duskfox',
    'nightfox',
    -- 'dayfox',
    'nordfox',
    'terafox',

    -- Kanagawa variants
    'kanagawa',
    'kanagawa-wave',
    'kanagawa-dragon',
    -- 'kanagawa-lotus',

    -- Gruvbox Material
    -- 'gruvbox-material',

    -- GitHub variants
    'github_dark_default',
    'github_dark_dimmed',
    'github_dark_high_contrast',
    -- 'github_light',
    -- 'github_light_default',
    -- 'github_light_high_contrast',

    -- Material
    'material',

    -- Rose Pine variants
    'rose-pine',
    'rose-pine-moon',
    -- 'rose-pine-dawn',

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

    -- Base16 Black Metal variants
    'base16-black-metal',
    'base16-black-metal-bathory',
    'base16-black-metal-burzum',
    'base16-black-metal-dark-funeral',
    'base16-black-metal-gorgoroth',
    'base16-black-metal-immortal',
    'base16-black-metal-khold',
    'base16-black-metal-marduk',
    'base16-black-metal-mayhem',
    'base16-black-metal-nile',
    'base16-black-metal-venom',

    -- Jellybeans palettes
    'jellybeans',
    'jellybeans-default',
    -- 'jellybeans-light',
    'jellybeans-muted',
    -- 'jellybeans-muted-light',
    'jellybeans-mono',
    -- 'jellybeans-mono-light',

    -- Sitruuna
    'sitruuna',

    -- Monokai Pro variants
    'monokai-pro',
    'monokai-pro-spectrum',
    'monokai-pro-octagon',
    'monokai-pro-machine',
    'monokai-pro-ristretto',
    'monokai-pro-classic',

    'nightingale',
    'hubbamax',
  }

  local original = vim.g.colors_name

  local sorted_themes = vim.deepcopy(themes)
  table.sort(sorted_themes, function(a, b)
    return a:lower() < b:lower()
  end)

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
      finder = require('telescope.finders').new_table { results = sorted_themes },
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

-- Edgy helpers
local function plugin_enabled(name)
  local ok_config, Config = pcall(require, 'lazy.core.config')
  if not ok_config or not Config.plugins then
    return false
  end

  local plugin = Config.plugins[name]
  if not plugin then
    return false
  end

  return plugin.enabled ~= false
end

local function ensure_edgy_loaded()
  if not M.is_edgy_enabled() then
    return false
  end

  local ok_lazy, lazy = pcall(require, 'lazy')
  if ok_lazy then
    lazy.load { plugins = { 'edgy.nvim' } }
  end

  return true
end

function M.is_edgy_enabled()
  return plugin_enabled 'edgy.nvim'
end

---@param opts {ft?: string, filter?: fun(win: any): boolean, open?: fun(), focus_after?: boolean?}?
---@return boolean handled
function M.focus_edgy_view(opts)
  opts = opts or {}

  if not ensure_edgy_loaded() then
    return false
  end

  local ok_config, Config = pcall(require, 'edgy.config')
  if not ok_config or not Config.layout then
    return false
  end

  for _, edgebar in pairs(Config.layout) do
    for _, win in ipairs(edgebar.wins) do
      local view = win.view
      if view and ((opts.ft and view.ft == opts.ft) or (opts.filter and opts.filter(win))) then
        if not win.visible then
          win:show(true)
        end
        win:focus()
        return true
      end
    end
  end

  if opts.open then
    opts.open()
    vim.schedule(function()
      M.focus_edgy_view(opts)
    end)
    return true
  end

  return false
end

---@param opts {ft?: string, filter?: fun(win: any): boolean, open?: fun(), close?: fun(), focus_after?: boolean?}?
---@return boolean handled
function M.toggle_edgy_view(opts)
  opts = opts or {}

  if not ensure_edgy_loaded() then
    return false
  end

  local ok_config, Config = pcall(require, 'edgy.config')
  if not ok_config or not Config.layout then
    return false
  end

  local found = false
  for _, edgebar in pairs(Config.layout) do
    for _, win in ipairs(edgebar.wins) do
      local view = win.view
      if view and ((opts.ft and view.ft == opts.ft) or (opts.filter and opts.filter(win))) then
        found = true
        local should_focus = opts.focus_after ~= false
        if win.visible then
          should_focus = false
          if opts.close then
            opts.close()
          else
            win:toggle()
          end
        else
          if opts.open then
            opts.open()
          else
            win:show(true)
          end
        end

        if should_focus then
          vim.schedule(function()
            M.focus_edgy_view(opts)
          end)
        end

        return true
      end
    end
  end

  if not found and opts.open then
    opts.open()
    if opts.focus_after ~= false then
      vim.schedule(function()
        M.focus_edgy_view(opts)
      end)
    end
    return true
  end

  return found
end

return M

local function tabscope_is_enabled()
  local ok, spec = pcall(require, 'custom.plugins.tabscope')
  if not ok then
    return false
  end

  local enabled = spec.enabled
  if enabled == nil then
    return true
  end

  if type(enabled) == 'function' then
    local success, value = pcall(enabled, spec)
    if not success then
      return false
    end
    return not not value
  end

  return not not enabled
end

return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'

    opts = {
      sort = { 'alphanum' },

      expand = 40, -- Expand groups with 10 or fewer mappings
      win = {
        height = {
          min = 30, -- which key min height
          max = 40,
        }, -- Increase max height of the popup
      },

      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        {
          '<leader>c',
          group = '[c]ode',
          mode = { 'n', 'x' },
        },
        {
          '<leader>cr',
          group = '[c]ode [r]ust',
          mode = { 'n' },
          cond = function()
            local ft = vim.bo.filetype
            return ft == 'rust' or ft == 'toml'
          end,
        },
        {
          '<leader>cn',
          group = '[c]ode [n]im',
          mode = { 'n' },
          cond = function()
            return vim.bo.filetype == 'nim'
          end,
        },
        {
          '<leader>cR',
          group = '[c]ode [R]hai',
          mode = { 'n', 'x' },
          cond = function()
            return vim.bo.filetype == 'rhai'
          end,
        },
        {
          '<leader>ck',
          group = '[c]ode [k]oto',
          mode = { 'n' },
          cond = function()
            return vim.bo.filetype == 'koto'
          end,
        },
        {
          '<leader>d',
          group = '[d]ocument and dashboard',
        },
        {
          '<leader>r',
          group = '[r]ename',
        },
        {
          '<leader>b',
          group = '[B]ookmarks',
          mode = { 'n' },
        },
        {
          '<leader>q',
          group = '[q]ueued macros',
        },
        {
          '<leader>qm',
          desc = '[Q]ueued macros menu',
          mode = { 'n' },
        },
        {
          '<leader>qe',
          desc = '[Q]ueued macros edit buffer',
          mode = { 'n' },
        },
        {
          '<leader>qd',
          desc = '[Q]ueued macros toggle delay',
          mode = { 'n' },
        },
        {
          '<leader>qs',
          desc = '[Q]ueued macros halt playback',
          mode = { 'n' },
        },
        {
          '<leader>s',
          group = '[s]earch',
        },
        {
          '<leader>sT',
          desc = '[S]earch [T]abs',
          mode = { 'n' },
        },
        {
          '<leader>sy',
          desc = '[S]earch [Y]ank history',
          mode = { 'n' },
        },
        {
          '<leader>sY',
          desc = '[S]earch system [Y]anks',
          mode = { 'n' },
        },
        {
          '<leader>sW',
          desc = '[S]earch [W]orkspace symbols',
          mode = { 'n' },
        },
        {
          '<leader>sS',
          desc = '[S]earch dynamic [S]ymbols',
          mode = { 'n' },
        },
        {
          '<leader>w',
          group = '[w]indows',
        },
        {
          '<leader>wb',
          group = '[w]indows tab-local buffers',
          mode = { 'n' },
          cond = tabscope_is_enabled,
        },
        {
          '<leader>wbr',
          desc = '[w]indows TabScope remove tab-local buffer',
          mode = { 'n' },
          cond = tabscope_is_enabled,
        },
        {
          '<leader>wbd',
          desc = '[w]indows TabScope debug tab-local buffers',
          mode = { 'n' },
          cond = tabscope_is_enabled,
        },
        {
          '<leader>G',
          group = '[G]it',
        },
        {
          '<leader>w',
          group = '[w]indow',
        },
        {
          '<leader>t',
          group = '[t]abs and Toggle',
        },
        {
          '<leader>x',
          group = '[x] Trouble & quickfix',
        },
        {
          '<leader>U',
          group = '[U]i',
        },
        {
          '<leader>h',
          group = '[h]op',
        },
        {
          '<leader>f',
          group = '[F]ormat',
          mode = { 'n' },
        },
      },
    },
  },
}

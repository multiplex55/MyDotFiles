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
          '<leader>d',
          group = '[d]ocument and dashboard',
        },
        {
          '<leader>r',
          group = '[r]ename',
        },
        {
          '<leader>s',
          group = '[s]earch',
        },
        {
          '<leader>w',
          group = '[w]indows',
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

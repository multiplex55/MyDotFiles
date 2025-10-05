return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        n_lines = 500,
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- This setup is intentionally disabled because `nvim-surround`
      -- provides the active surround mappings. Keeping this line
      -- commented avoids duplicate mappings while retaining the
      -- reference for future use if desired.
      -- require('mini.surround').setup()

      -- `mini.statusline` remains available as an optional fallback, but we
      -- only configure it when explicitly requested. This prevents duplicate
      -- statuslines when another provider (like lualine) is enabled.
      if vim.g.custom_enable_mini_statusline then
        local statusline = require 'mini.statusline'
        -- set use_icons to true if you have a Nerd Font
        statusline.setup {
          use_icons = vim.g.have_nerd_font,
        }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}

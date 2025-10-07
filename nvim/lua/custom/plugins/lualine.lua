return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function macro_recording()
        local recording = vim.fn.reg_recording()
        if recording == nil or recording == '' then
          recording = vim.fn.reg_executing()
        end

        if recording == nil or recording == '' then
          return ''
        end

        return ' @' .. recording
      end

      require('lualine').setup {
        options = {
          theme = 'auto', -- auto picks up current colorscheme
          section_separators = { left = '', right = '' },
          component_separators = '|',
          globalstatus = true,
          disabled_filetypes = {
            winbar = {
              'dashboard',
              'snacks_dashboard',
              'help',
              'terminal',
            },
          },
        },
        sections = {
          lualine_a = { macro_recording, 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = nil,
        inactive_winbar = nil,
      }

      local function refresh_lualine()
        local ok, lualine = pcall(require, 'lualine')
        if ok then
          lualine.refresh { place = { 'statusline' }, trigger = 'autocmd' }
        end
      end

      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = refresh_lualine,
      })

      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          vim.defer_fn(refresh_lualine, 50)
        end,
      })
    end,
  },
}

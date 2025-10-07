return {

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local macro_status = function()
        local recording = vim.fn.reg_recording()
        if recording ~= '' then
          return string.format('󰑋 REC @%s', recording)
        end

        local executing = vim.fn.reg_executing()
        if executing ~= '' then
          return string.format('󰑋 RUN @%s', executing)
        end

        return ''
      end

      local function refresh_lualine()
        vim.schedule(function()
          require('lualine').refresh()
        end)
      end

      vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave', 'CmdlineEnter', 'CmdlineLeave' }, {
        callback = refresh_lualine,
      })

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
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', macro_status },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        winbar = nil,
        inactive_winbar = nil,
      }
    end,
  },
}

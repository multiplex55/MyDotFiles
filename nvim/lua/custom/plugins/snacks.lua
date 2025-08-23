return {
  {
    'folke/snacks.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = {
      session = { enabled = false }, -- no auto-restore on startup
      dashboard = {
        enabled = true,
        width = 60,
        row = nil,
        col = nil,
        pane_gap = 4,
        autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
        preset = {
          pick = nil,
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = ' ', key = 's', desc = 'Restore Session', action = '<cmd>Telescope session-lens search_session<cr>' },
            { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
          header = [[
███╗   ███╗██╗   ██╗██╗     ████████╗██╗
████╗ ████║██║   ██║██║     ╚══██╔══╝██║
██╔████╔██║██║   ██║██║        ██║   ██║
██║╚██╔╝██║██║   ██║██║        ██║   ██║
██║ ╚═╝ ██║╚██████╔╝███████╗   ██║   ██║
╚═╝     ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝]],
        },
        formats = {
          icon = function(item)
            if item.file and (item.icon == 'file' or item.icon == 'directory') then
              return require('snacks.dashboard').icon(item.file, item.icon)
            end
            return { item.icon, width = 2, hl = 'icon' }
          end,
          footer = { '%s', align = 'center' },
          header = { '%s', align = 'center' },
          file = function(item, ctx)
            local fname = vim.fn.fnamemodify(item.file, ':~')
            fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
            if #fname > ctx.width then
              local dir = vim.fn.fnamemodify(fname, ':h')
              local file = vim.fn.fnamemodify(fname, ':t')
              if dir and file then
                file = file:sub(-(ctx.width - #dir - 2))
                fname = dir .. '/…' .. file
              end
            end
            local dir, file = fname:match '^(.*)/(.+)$'
            return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
          end,
        },
        sections = {
          { section = 'header' },
          {
            pane = 2,
            section = 'terminal',
            cmd = 'powershell -nologo -noprofile -Command "Write-Host \'Welcome to Neovim!\'"',
            height = 1,
            padding = 1,
          },

          { section = 'keys', gap = 1, padding = 1 },
          { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          {
            pane = 2,
            icon = ' ',
            title = 'Git Status',
            section = 'terminal',
            enabled = function()
              return require('snacks.git').get_root() ~= nil
            end,
            cmd = 'git status --short --branch --renames',
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = 'startup' },
        },
      },
    },
  },
}

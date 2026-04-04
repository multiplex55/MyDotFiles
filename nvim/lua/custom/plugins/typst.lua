return {
  {
    'chomosuke/typst-preview.nvim',
    ft = { 'typst' },
    version = '1.*',
    keys = {
      { '<leader>tp', '<cmd>TypstPreview<cr>', desc = 'Typst: Start preview' },
      { '<leader>tP', '<cmd>TypstPreviewToggle<cr>', desc = 'Typst: Toggle preview' },
      { '<leader>ts', '<cmd>TypstPreviewStop<cr>', desc = 'Typst: Stop preview' },
    },
    config = function()
      local function warn_missing(bin, reason)
        vim.notify(
          ('typst-preview: `%s` not found%s'):format(bin, reason and (' (' .. reason .. ')') or ''),
          vim.log.levels.WARN
        )
      end

      if vim.fn.executable('curl') ~= 1 then
        warn_missing('curl', 'required to download/update preview binaries')
      end

      if vim.fn.executable('typst') ~= 1 then
        warn_missing('typst', 'install Typst CLI for document compilation')
      end

      local has_tinymist = vim.fn.executable('tinymist') == 1 or vim.fn.executable('tinymist.cmd') == 1
      local has_websocat = vim.fn.executable('websocat') == 1 or vim.fn.executable('websocat.exe') == 1
      if not has_tinymist or not has_websocat then
        vim.notify(
          'typst-preview: tinymist/websocat not found in PATH; plugin can auto-download them via :TypstPreviewUpdate',
          vim.log.levels.WARN
        )
      end

      require('typst-preview').setup {
        follow_cursor = false,
        invert_colors = 'always',
        dependencies_bin = {
          tinymist = nil,
          websocat = nil,
        },
      }
    end,
  },
}

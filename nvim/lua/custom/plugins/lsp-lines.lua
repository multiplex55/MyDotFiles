return {
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()

      -- Default diagnostics still needed but disable virtual text
      vim.diagnostic.config {
        virtual_text = false,
        virtual_lines = { only_current_line = true },
      }

      -- Toggle virtual lines on/off easily
      vim.keymap.set('', '<Leader>l', require('lsp_lines').toggle, { desc = 'Toggle LSP Lines' })
    end,
  },
}

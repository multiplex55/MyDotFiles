if not vim.g.neovide then
  return
end

-- Start ocamllsp shortly after an OCaml buffer is ready.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  pattern = { '*.ml', '*.mli' },
  callback = function(args)
    vim.defer_fn(function()
      local ok, lspconfig = pcall(require, 'lspconfig')
      if not ok or not lspconfig.ocamllsp or not lspconfig.ocamllsp.manager then
        return
      end
      -- attach specifically to this buffer
      pcall(lspconfig.ocamllsp.manager.try_add, args.buf)
    end, 200) -- 200ms avoids Neovide’s startup race
  end,
})

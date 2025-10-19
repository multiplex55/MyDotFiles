local M = {}

local function apply_diagnostic_highlights()
  local highlights = {
    DiagnosticVirtualTextError = '#FF5370',
    DiagnosticVirtualTextWarn = '#FFCB6B',
    DiagnosticVirtualTextInfo = '#82AAFF',
    DiagnosticVirtualTextHint = '#C3E88D',
  }

  for group, color in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, { fg = color })
  end
end

M.apply = apply_diagnostic_highlights

apply_diagnostic_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = apply_diagnostic_highlights,
})

return M

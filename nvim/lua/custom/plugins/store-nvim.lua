return {
  'alex-popov-tech/store.nvim',
  dependencies = {
    { 'OXY2DEV/markview.nvim', opts = {} },
    -- optional: enables inline image preview in terminal
    -- { "3rd/image.nvim", opts = { integrations = { markdown = { enabled = false } } } },
  },
  opts = {
    -- optional: opens store in a full tab instead of floating window
    -- layout = "tab",
  },
  cmd = { 'Store' },
}

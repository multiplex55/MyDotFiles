-- return {
--   {
--     'brenoprata10/nvim-highlight-colors',
--     event = 'VeryLazy',
--     opts = {
--       render = 'background', -- options: 'background', 'foreground', 'virtual'
--       enable_named_colors = true, -- e.g., "red", "green"
--       enable_tailwind = true, -- highlight Tailwind classes like "bg-red-500"
--     },
--   },
-- }
--

-- custom/plugins/nvim-highlight.lua
return {
  {
    'brenoprata10/nvim-highlight-colors',
    ft = { 'css', 'scss', 'sass', 'less', 'html', 'javascript', 'typescript', 'tsx', 'jsx', 'lua' },
    opts = { render = 'background', enable_named_colors = true, enable_tailwind = true },
  },
}

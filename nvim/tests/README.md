# Neovim test notes

## md-render migration regression contract

`nvim/tests/unit/migrations/md_render_migration_spec.lua` is a pure Lua/spec-inspection regression test that protects the md-render migration contract without launching a full Neovim UI.

The contract checks:

- Positive assertions:
  - `MdRender`, `MdRenderTab`, `MdRenderPager`, `MdRenderDemo` remain declared as plugin command triggers.
  - `<leader>mp`, `<leader>mt`, `<leader>md` remain mapped to the expected `<Plug>` targets.
- Negative assertions:
  - No plugin or startup config references `RenderMarkdown`.
  - No startup hook loads `custom.autocmds.markdown`.
  - No plugin config calls `require('render-markdown')`.
- Fixture alignment:
  - `nvim/tests/fixtures/markdown/*.md|*.rmd|*.mdx` documents markdown-related filetypes and the test verifies plugin filetype scoping against them.

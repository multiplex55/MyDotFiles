local function load_md_render_spec()
  local spec = dofile('nvim/lua/custom/plugins/md-render.lua')
  assert(type(spec) == 'table', 'plugin spec must be a table')
  assert(type(spec[1]) == 'table', 'plugin spec must contain one plugin entry')
  return spec[1]
end

describe('md-render plugin spec', function()
  it('exposes expected commands', function()
    local plugin = load_md_render_spec()

    assert.are.same({ 'MdRender', 'MdRenderTab', 'MdRenderPager', 'MdRenderDemo' }, plugin.cmd)
  end)

  it('exposes expected key mappings', function()
    local plugin = load_md_render_spec()

    assert.are.same({ '<leader>mp', '<Plug>(md-render-preview)', mode = 'n', ft = { 'markdown' } }, plugin.keys[1])
    assert.are.same({ '<leader>mt', '<Plug>(md-render-preview-tab)', mode = 'n', ft = { 'markdown' } }, plugin.keys[2])
    assert.are.same({ '<leader>md', '<Plug>(md-render-demo)', mode = 'n' }, plugin.keys[3])
  end)

  it('does not define a config callback that calls setup', function()
    local plugin = load_md_render_spec()

    assert.is_nil(plugin.config)
    assert.is_nil(plugin.opts)
  end)

  it('regression: no longer includes MeanderingProgrammer/render-markdown.nvim', function()
    local plugin_files = vim.fn.globpath('nvim/lua/custom/plugins', '*.lua', false, true)

    for _, file in ipairs(plugin_files) do
      local lines = vim.fn.readfile(file)
      local content = table.concat(lines, '\n')
      assert.is_nil(content:match('MeanderingProgrammer/render%-markdown%.nvim'))
    end
  end)
end)

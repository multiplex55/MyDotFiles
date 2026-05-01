local function read(path)
  local lines = vim.fn.readfile(path)
  return table.concat(lines, '\n')
end

local function load_md_render_spec()
  local spec = dofile('nvim/lua/custom/plugins/md-render.lua')
  assert(type(spec) == 'table', 'plugin spec must be a table')
  assert(type(spec[1]) == 'table', 'plugin spec must contain one plugin entry')
  return spec[1]
end

describe('md-render migration regression contract', function()
  it('declares MdRender commands as plugin command triggers', function()
    local plugin = load_md_render_spec()

    assert.are.same({ 'MdRender', 'MdRenderTab', 'MdRenderPager', 'MdRenderDemo' }, plugin.cmd)
  end)

  it('declares markdown-scoped mappings with expected <Plug> targets', function()
    local plugin = load_md_render_spec()

    assert.are.same({ '<leader>mp', '<Plug>(md-render-preview)', mode = 'n', ft = { 'markdown' } }, plugin.keys[1])
    assert.are.same({ '<leader>mt', '<Plug>(md-render-preview-tab)', mode = 'n', ft = { 'markdown' } }, plugin.keys[2])
    assert.are.same({ '<leader>md', '<Plug>(md-render-demo)', mode = 'n' }, plugin.keys[3])
  end)

  it('keeps markdown keymap scopes tied to markdown filetypes used by fixtures', function()
    local plugin = load_md_render_spec()
    local fixtures = {
      ['nvim/tests/fixtures/markdown/example.md'] = 'markdown',
      ['nvim/tests/fixtures/markdown/example.rmd'] = 'rmd',
      ['nvim/tests/fixtures/markdown/example.mdx'] = 'markdown.mdx',
    }

    local declared_filetypes = {}
    for _, ft in ipairs(plugin.ft or {}) do
      declared_filetypes[ft] = true
    end

    for path, expected_ft in pairs(fixtures) do
      local fixture = read(path)
      assert.is_truthy(fixture:match('filetype:%s*' .. expected_ft), path .. ' should declare expected fixture filetype')
      assert.is_true(declared_filetypes[expected_ft] == true, 'plugin.ft must include ' .. expected_ft)
    end

    for _, keymap in ipairs({ plugin.keys[1], plugin.keys[2] }) do
      assert.is_true(vim.tbl_contains(keymap.ft or {}, 'markdown'))
      assert.is_false(vim.tbl_contains(keymap.ft or {}, 'lua'))
    end
  end)

  it('does not reference deprecated RenderMarkdown plugin/config/startup hooks', function()
    local plugin = load_md_render_spec()
    assert.is_nil(plugin[1]:match('RenderMarkdown'))

    local files_to_scan = {
      'nvim/init.lua',
      'nvim/lua/custom/plugins/init.lua',
      'nvim/lua/custom/plugins/md-render.lua',
    }

    for _, path in ipairs(files_to_scan) do
      local content = read(path)
      assert.is_nil(content:match('RenderMarkdown'), path .. ' should not reference RenderMarkdown')
      assert.is_nil(content:match("require%(['\"]custom%.autocmds%.markdown['\"]%)"), path .. ' should not load markdown startup autocmd')
      assert.is_nil(content:match("require%(['\"]render%-markdown['\"]%)"), path .. ' should not require render-markdown module')
    end
  end)
end)

local function read(path)
  local lines = vim.fn.readfile(path)
  return table.concat(lines, '\n')
end

describe('obsidian plugin spec', function()
  it('still consumes markdown_runtime.obsidian_events after markdown autocmd migration', function()
    local startup_files = {
      'nvim/init.lua',
      'nvim/lua/custom/plugins/init.lua',
    }

    for _, path in ipairs(startup_files) do
      local content = read(path)
      assert.is_nil(content:match("require%(['\"]custom%.autocmds%.markdown['\"]%)"), path .. ' should not require custom.autocmds.markdown')
    end

    local original_runtime = package.loaded['custom.utils.markdown_runtime']
    local calls = 0
    local sentinel_events = { 'BufReadPre /mock/**/*.md' }

    package.loaded['custom.utils.markdown_runtime'] = {
      obsidian_events = function()
        calls = calls + 1
        return sentinel_events
      end,
    }

    local ok, spec = pcall(dofile, 'nvim/lua/custom/plugins/obsidian.lua')
    package.loaded['custom.utils.markdown_runtime'] = original_runtime

    assert.is_true(ok, spec)
    assert.are.same(sentinel_events, spec.event)
    assert.are.equal(1, calls)
  end)
end)

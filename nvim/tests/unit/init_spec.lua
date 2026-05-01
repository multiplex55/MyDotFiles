local function read(path)
  local lines = vim.fn.readfile(path)
  return table.concat(lines, '\n')
end

describe('startup config', function()
  it('does not load custom.autocmds.markdown from startup paths', function()
    local startup_files = {
      'nvim/init.lua',
      'nvim/lua/custom/plugins/init.lua',
    }

    for _, path in ipairs(startup_files) do
      local content = read(path)
      assert.is_nil(content:match("require%(['\"]custom%.autocmds%.markdown['\"]%)"), path .. ' should not require custom.autocmds.markdown')
    end
  end)

  it('regression: startup config does not declare deprecated markdown commands', function()
    local startup_files = {
      'nvim/init.lua',
      'nvim/lua/custom/plugins/init.lua',
    }

    local deprecated_commands = {
      'MarkdownRecover',
      'MarkdownHealth',
      'RenderMarkdown',
    }

    for _, path in ipairs(startup_files) do
      local content = read(path)
      for _, cmd in ipairs(deprecated_commands) do
        assert.is_nil(content:match(cmd), path .. ' should not include deprecated command ' .. cmd)
      end
    end
  end)
end)

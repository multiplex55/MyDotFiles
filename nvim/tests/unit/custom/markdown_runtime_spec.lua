local markdown_runtime = require 'custom.utils.markdown_runtime'

describe('custom.utils.markdown_runtime', function()
  it('obsidian_events returns non-empty markdown event patterns', function()
    vim.g.custom_obsidian_workspace_paths = {
      '/tmp/notes',
    }

    local events = markdown_runtime.obsidian_events()

    assert.is_true(type(events) == 'table')
    assert.is_true(#events > 0)
    assert.is_truthy(vim.tbl_contains(events, 'BufReadPre /tmp/notes/**/*.md'))
    assert.is_truthy(vim.tbl_contains(events, 'BufNewFile /tmp/notes/**/*.md'))
  end)

  it('is_obsidian_buffer detects vault and non-vault paths', function()
    vim.g.custom_obsidian_workspace_paths = {
      '/vault/notes',
    }

    local original_get_name = vim.api.nvim_buf_get_name
    vim.api.nvim_buf_get_name = function(bufnr)
      if bufnr == 10 then
        return '/vault/notes/daily/today.md'
      end
      if bufnr == 11 then
        return '/other/place/today.md'
      end
      return ''
    end

    local ok, err = pcall(function()
      assert.is_true(markdown_runtime.is_obsidian_buffer(10))
      assert.is_false(markdown_runtime.is_obsidian_buffer(11))
    end)

    vim.api.nvim_buf_get_name = original_get_name

    assert.is_true(ok, err)
  end)
end)

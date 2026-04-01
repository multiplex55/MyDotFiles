local M = {}

local uv = vim.uv or vim.loop

local DEFAULT_VAULT_PATHS = {
  'C:/Users/multi/My Drive/Obsidian/MyNotes',
}

local LARGE_MARKDOWN_LINE_THRESHOLD = 4000
local LARGE_MARKDOWN_BYTE_THRESHOLD = 512 * 1024

local function normalize_path(path)
  if type(path) ~= 'string' or path == '' then
    return nil
  end

  local expanded = vim.fn.expand(path)
  if expanded == '' then
    return nil
  end

  expanded = expanded:gsub('\\', '/')
  expanded = expanded:gsub('/+$', '')

  return expanded
end

local function workspace_paths()
  local paths = vim.g.custom_obsidian_workspace_paths
  if type(paths) ~= 'table' or vim.tbl_isempty(paths) then
    paths = DEFAULT_VAULT_PATHS
  end

  local normalized = {}
  for _, path in ipairs(paths) do
    local value = normalize_path(path)
    if value then
      normalized[#normalized + 1] = value
    end
  end

  return normalized
end

function M.obsidian_events()
  local events = {}
  for _, path in ipairs(workspace_paths()) do
    events[#events + 1] = 'BufReadPre ' .. path .. '/**/*.md'
    events[#events + 1] = 'BufNewFile ' .. path .. '/**/*.md'
  end
  return events
end

function M.is_obsidian_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local name = normalize_path(vim.api.nvim_buf_get_name(bufnr))
  if not name then
    return false
  end

  for _, path in ipairs(workspace_paths()) do
    if name == path or name:sub(1, #path + 1) == (path .. '/') then
      return true
    end
  end

  return false
end

local function has_markdown_injections(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown')
  if not ok or not parser or type(parser.children) ~= 'function' then
    return false
  end

  return next(parser:children()) ~= nil
end

function M.should_run(bufnr, key, min_interval_ms)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  min_interval_ms = min_interval_ms or 250

  local now = uv.hrtime() / 1e6
  vim.b[bufnr].markdown_runtime_last_run = vim.b[bufnr].markdown_runtime_last_run or {}

  local last_run = vim.b[bufnr].markdown_runtime_last_run[key] or 0
  if now - last_run < min_interval_ms then
    return false
  end

  vim.b[bufnr].markdown_runtime_last_run[key] = now
  return true
end

function M.can_enable_render_markdown(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not M.should_run(bufnr, 'render_markdown_gate', 50) then
    return false
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > LARGE_MARKDOWN_LINE_THRESHOLD then
    return false
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= '' then
    local stat = uv.fs_stat(name)
    if stat and stat.size and stat.size > LARGE_MARKDOWN_BYTE_THRESHOLD then
      return false
    end
  end

  if has_markdown_injections(bufnr) then
    return false
  end

  local obsidian_ui_active = vim.b[bufnr].obsidian_ui_active == true
    or vim.b[bufnr].obsidian_backlinks_active == true
    or vim.b[bufnr].obsidian_footer_active == true

  if M.is_obsidian_buffer(bufnr) and (obsidian_ui_active or package.loaded['obsidian'] ~= nil) then
    return false
  end

  return true
end

function M.markdown_stack_compatible(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local function fail(reason)
    return { ok = false, reason = reason }
  end

  if type(vim.treesitter) ~= 'table' then
    return fail 'missing_treesitter_runtime'
  end

  if type(vim.treesitter.start) ~= 'function' then
    return fail 'missing_treesitter_start'
  end

  if type(vim.treesitter.get_parser) ~= 'function' then
    return fail 'missing_treesitter_get_parser'
  end

  if type(vim.treesitter.query) ~= 'table' then
    return fail 'missing_treesitter_query_module'
  end

  local query = vim.treesitter.query
  if type(query.get) ~= 'function' then
    return fail 'missing_query_get'
  end
  if type(query.parse) ~= 'function' then
    return fail 'missing_query_parse'
  end
  if type(query.add_predicate) ~= 'function' then
    return fail 'missing_query_add_predicate'
  end
  if type(query.add_directive) ~= 'function' then
    return fail 'missing_query_add_directive'
  end

  for _, language in ipairs { 'markdown', 'markdown_inline' } do
    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, language)
    if not ok_parser or parser == nil then
      return fail('missing_parser_' .. language)
    end

    if type(parser.parse) ~= 'function' then
      return fail('missing_parser_parse_' .. language)
    end

    local ok_parse, trees = pcall(parser.parse, parser)
    if not ok_parse or type(trees) ~= 'table' or trees[1] == nil then
      return fail('parser_parse_failed_' .. language)
    end

    local tree = trees[1]
    if type(tree.root) ~= 'function' then
      return fail('missing_tree_root_' .. language)
    end

    local ok_root, root = pcall(tree.root, tree)
    if not ok_root or root == nil then
      return fail('tree_root_failed_' .. language)
    end

    if type(root.range) ~= 'function' then
      return fail('missing_node_range_' .. language)
    end

    if not pcall(root.range, root) then
      return fail('node_range_call_failed_' .. language)
    end
  end

  return { ok = true, reason = 'ok' }
end

return M

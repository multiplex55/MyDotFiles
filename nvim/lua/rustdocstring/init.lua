-- rustdocstring.lua
-- This plugin adds docstring scaffolding for Rust functions, structs, enums, and impl blocks.
-- It uses Treesitter to parse the Rust syntax tree and inject appropriate documentation blocks
-- above the target node.

local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

-- Utility to describe common return types like Result, Option, Vec, etc.
local function format_return_type(type_str)
  local result_ok, result_err = type_str:match '^Result%s*<%s*(.-)%s*,%s*(.-)%s*>$'
  if result_ok and result_err then
    return string.format('`Ok(%s)` on success, or `Err(%s)` on failure.', result_ok, result_err)
  end

  local opt_inner = type_str:match '^Option%s*<%s*(.-)%s*>$'
  if opt_inner then
    return string.format('`Some(%s)` if available, or `None` otherwise.', opt_inner)
  end

  local vec_inner = type_str:match '^Vec%s*<%s*(.-)%s*>$'
  if vec_inner then
    return string.format('a vector of `%s` items.', vec_inner)
  end

  local box_inner = type_str:match '^Box%s*<%s*(.-)%s*>$'
  if box_inner then
    return string.format('a boxed `%s`.', box_inner)
  end

  local k, v = type_str:match '^HashMap%s*<%s*(.-)%s*,%s*(.-)%s*>$'
  if k and v then
    return string.format('a map from `%s` to `%s`.', k, v)
  end

  return string.format('`%s`.', type_str)
end

-- Main entry: determines what node the cursor is on, and dispatches to a specific doc generator.
function M.insert_docstring()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = parsers.get_parser(bufnr, 'rust')
  local root = parser:parse()[1]:root()
  local node = ts_utils.get_node_at_cursor()

  -- Walk up the syntax tree until we find a supported top-level item
  while node and not vim.tbl_contains({
    'function_item',
    'struct_item',
    'enum_item',
    'impl_item',
  }, node:type()) do
    node = node:parent()
  end

  if not node then
    print 'No supported Rust item found at cursor.'
    return
  end

  local doc_lines = {}

  if node:type() == 'function_item' then
    doc_lines = generate_function_doc(bufnr, node)
  elseif node:type() == 'struct_item' then
    doc_lines = generate_struct_doc(bufnr, node)
  elseif node:type() == 'enum_item' then
    doc_lines = generate_enum_doc(bufnr, node)
  elseif node:type() == 'impl_item' then
    doc_lines = {
      '/// Describe this impl block.',
      '///',
      '/// This block contains method implementations or trait impls.',
    }
  end

  if doc_lines and #doc_lines > 0 then
    local start_row = node:range()
    vim.api.nvim_buf_set_lines(bufnr, start_row, start_row, false, doc_lines)
  end
end

-- Generates function documentation, including async, unsafe, args, return, etc.
function generate_function_doc(bufnr, node)
  local ts = vim.treesitter

  local name_node = node:field('name')[1]
  local func_name = name_node and ts.get_node_text(name_node, bufnr) or 'unknown'

  local params_node = node:field('parameters')[1]

  -- Attempt to get return type from 'signature' node first
  local return_node = nil

  -- Try: signature -> return_type -> type
  local sig = node:field('signature')[1]
  if sig then
    local ret = sig:field('return_type')[1]
    if ret then
      return_node = ret:field('type')[1] or ret
    end
  end

  -- Fallback: check return_type directly on node
  if not return_node then
    local ret = node:field('return_type')[1]
    if ret then
      return_node = ret:field('type')[1] or ret
    end
  end

  -- Final fallback: type directly on node
  if not return_node then
    return_node = node:field('type')[1]
  end

  local signature_node = sig or node
  local is_async, is_unsafe, is_extern = false, false, false

  -- Recursively scan the node for modifiers
  local function scan(n)
    if not n then
      return
    end
    if n:type() == 'async' then
      is_async = true
    end
    if n:type() == 'unsafe' then
      is_unsafe = true
    end
    if n:type() == 'extern_modifier' then
      is_extern = true
    end
    for child in n:iter_children() do
      scan(child)
    end
  end
  scan(signature_node)

  local doc_lines = {
    '/// Describe this function.',
    '///',
  }

  -- Arguments
  if params_node and params_node:named_child_count() > 0 then
    table.insert(doc_lines, '/// # Arguments')
    table.insert(doc_lines, '///')
    for param in params_node:iter_children() do
      local pat = param:field('pattern')[1]
      local ty = param:field('type')[1]
      if pat and ty then
        local pname = ts.get_node_text(pat, bufnr)
        local ptype = ts.get_node_text(ty, bufnr)
        table.insert(doc_lines, string.format('/// - `%s` (`%s`) - Describe this parameter.', pname, ptype))
      end
    end
    table.insert(doc_lines, '///')
  end

  -- Return type
  if return_node then
    local return_type = ts.get_node_text(return_node, bufnr)
    if return_type and return_type ~= '()' then
      local desc = format_return_type(return_type)
      table.insert(doc_lines, '/// # Returns')
      table.insert(doc_lines, '///')
      table.insert(doc_lines, '/// - ' .. desc)
      table.insert(doc_lines, '///')
    end
  end

  -- Safety section
  if is_unsafe or is_extern then
    table.insert(doc_lines, '/// # Safety')
    table.insert(doc_lines, '///')
    table.insert(doc_lines, '/// - **The caller must ensure that:**')
    table.insert(doc_lines, '///   - Any internal state or memory accessed by this function is in a valid state.')
    table.insert(doc_lines, "///   - Preconditions specific to this function's logic are satisfied.")
    table.insert(doc_lines, '///   - This function is only called in the correct program state to avoid UB.')
    table.insert(doc_lines, '/// - **This function is `unsafe` because:**')
    table.insert(doc_lines, '///   - Describe unsafe behavior.')
    table.insert(doc_lines, '///')
  end

  -- Async section
  if is_async then
    table.insert(doc_lines, '/// # Async')
    table.insert(doc_lines, '///')
    table.insert(doc_lines, '/// This function is asynchronous and should be `.await`ed.')
    table.insert(doc_lines, '///')
  end

  -- Example
  table.insert(doc_lines, '/// # Examples')
  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// ```' .. (is_unsafe and 'no_run' or ''))
  table.insert(doc_lines, '/// use crate::...;')
  table.insert(doc_lines, '///')

  local ex = '/// let _ = '
  if is_unsafe then
    ex = ex .. 'unsafe { '
  end
  ex = ex .. func_name .. '()'
  if is_async then
    ex = ex .. '.await'
  end
  if is_unsafe then
    ex = ex .. ' }'
  end
  ex = ex .. ';'

  table.insert(doc_lines, ex)
  table.insert(doc_lines, '/// ```')

  return doc_lines
end

-- Generates documentation for structs
function generate_struct_doc(bufnr, node)
  local doc_lines = {
    '/// Describe this struct.',
    '///',
    '/// # Fields',
    '///',
  }

  local body = node:field('body')[1]
  if not body then
    return doc_lines
  end

  for field in body:iter_children() do
    if field:type() == 'field_declaration' then
      local name = vim.treesitter.get_node_text(field:field('name')[1], bufnr)
      local ty = vim.treesitter.get_node_text(field:field('type')[1], bufnr)
      table.insert(doc_lines, string.format('/// - `%s` (`%s`) - Describe this field.', name, ty))
    end
  end

  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// # Examples')
  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// ```')
  table.insert(doc_lines, '/// use crate::...;')
  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// let s = StructName { /* fields */ };')
  table.insert(doc_lines, '/// ```')

  return doc_lines
end

-- Generates documentation for enums and their variants
function generate_enum_doc(bufnr, node)
  local doc_lines = {
    '/// Describe this enum.',
    '///',
    '/// # Variants',
    '///',
  }

  local body = node:field('body')[1]
  if not body then
    return doc_lines
  end

  for variant in body:iter_children() do
    if variant:type() == 'enum_variant' then
      local name = vim.treesitter.get_node_text(variant:field('name')[1], bufnr)
      table.insert(doc_lines, string.format('/// - `%s` - Describe this variant.', name))
    end
  end

  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// # Examples')
  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// ```')
  table.insert(doc_lines, '/// use crate::...;')
  table.insert(doc_lines, '///')
  table.insert(doc_lines, '/// let e = EnumName::Variant;')
  table.insert(doc_lines, '/// match e { _ => {} }')
  table.insert(doc_lines, '/// ```')

  return doc_lines
end

M.generate_function_doc = generate_function_doc
M.generate_struct_doc = generate_struct_doc
M.generate_enum_doc = generate_enum_doc

return M

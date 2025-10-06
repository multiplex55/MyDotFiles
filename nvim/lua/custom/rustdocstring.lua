local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

local function get_node_text(node, bufnr)
  if not node then
    return nil
  end

  return vim.treesitter.get_node_text(node, bufnr)
end

local function extract_parameters(parameters_node, bufnr)
  if not parameters_node then
    return {}
  end

  local params = {}
  for param in parameters_node:iter_children() do
    local type_name = param:type()
    if type_name == 'parameter' then
      local pattern = param:child_by_field_name 'pattern'
      local name = get_node_text(pattern, bufnr)
      if name and name ~= '' then
        table.insert(params, name)
      end
    elseif type_name == 'self_parameter' or type_name == 'shorthand_parameter' then
      table.insert(params, 'self')
    elseif type_name == 'typed_self_parameter' then
      local self_node = param:child_by_field_name 'self'
      local name = get_node_text(self_node, bufnr) or 'self'
      table.insert(params, name)
    end
  end

  return params
end

local function extract_struct_fields(body_node, bufnr)
  if not body_node then
    return {}
  end

  local fields = {}
  local body_type = body_node:type()

  if body_type == 'field_declaration_list' then
    for field in body_node:iter_children() do
      if field:type() == 'field_declaration' then
        local name_node = field:child_by_field_name 'name'
        local name = get_node_text(name_node, bufnr)
        if name and name ~= '' then
          table.insert(fields, name)
        end
      end
    end
  elseif body_type == 'tuple_field_declarations' then
    local index = 0
    for field in body_node:iter_children() do
      if field:type() == 'tuple_field_declaration' then
        table.insert(fields, string.format('field_%d', index))
        index = index + 1
      end
    end
  end

  return fields
end

local function extract_enum_variants(body_node, bufnr)
  if not body_node then
    return {}
  end

  local variants = {}
  if body_node:type() == 'enum_variant_list' then
    for variant in body_node:iter_children() do
      if variant:type() == 'enum_variant' then
        local name_node = variant:child_by_field_name 'name'
        local name = get_node_text(name_node, bufnr)
        if name and name ~= '' then
          table.insert(variants, name)
        end
      end
    end
  end

  return variants
end

function M.generate_function_doc(bufnr, node)
  if not node or node:type() ~= 'function_item' then
    return nil
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local name_node = node:child_by_field_name 'name'
  local parameters_node = node:child_by_field_name 'parameters'
  local return_node = node:child_by_field_name 'return_type'

  local name = get_node_text(name_node, bufnr) or 'this function'
  local params = extract_parameters(parameters_node, bufnr)
  local return_type = get_node_text(return_node, bufnr)

  local lines = {
    string.format('/// TODO: Describe the `%s` function.', name),
  }

  if #params > 0 then
    table.insert(lines, '///')
    table.insert(lines, '/// # Arguments')
    for _, param in ipairs(params) do
      table.insert(lines, string.format('/// * `%s` - TODO: describe.', param))
    end
  end

  if return_type and return_type ~= '' and return_type ~= '()' then
    table.insert(lines, '///')
    table.insert(lines, '/// # Returns')
    table.insert(lines, string.format('/// %s', return_type))
  end

  return lines
end

function M.generate_struct_doc(bufnr, node)
  if not node or node:type() ~= 'struct_item' then
    return nil
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local name_node = node:child_by_field_name 'name'
  local body_node = node:child_by_field_name 'body'

  local name = get_node_text(name_node, bufnr) or 'this struct'
  local fields = extract_struct_fields(body_node, bufnr)

  local lines = {
    string.format('/// TODO: Describe the `%s` struct.', name),
  }

  if #fields > 0 then
    table.insert(lines, '///')
    table.insert(lines, '/// # Fields')
    for _, field in ipairs(fields) do
      table.insert(lines, string.format('/// * `%s` - TODO: describe.', field))
    end
  end

  return lines
end

function M.generate_enum_doc(bufnr, node)
  if not node or node:type() ~= 'enum_item' then
    return nil
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local name_node = node:child_by_field_name 'name'
  local body_node = node:child_by_field_name 'body'

  local name = get_node_text(name_node, bufnr) or 'this enum'
  local variants = extract_enum_variants(body_node, bufnr)

  local lines = {
    string.format('/// TODO: Describe the `%s` enum.', name),
  }

  if #variants > 0 then
    table.insert(lines, '///')
    table.insert(lines, '/// # Variants')
    for _, variant in ipairs(variants) do
      table.insert(lines, string.format('/// * `%s` - TODO: describe.', variant))
    end
  end

  return lines
end

local generators = {
  function_item = M.generate_function_doc,
  struct_item = M.generate_struct_doc,
  enum_item = M.generate_enum_doc,
}

function M.insert_docstring_for_node(bufnr, node)
  if not node then
    return nil
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local generator = generators[node:type()]
  if not generator then
    return nil
  end

  local lines = generator(bufnr, node)
  if not lines or vim.tbl_isempty(lines) then
    return nil
  end

  return lines
end

local function find_supported_ancestor(node)
  while node do
    if generators[node:type()] then
      return node
    end
    node = node:parent()
  end
  return nil
end

function M.insert_docstring()
  local bufnr = vim.api.nvim_get_current_buf()
  local node = ts_utils.get_node_at_cursor()
  local target = find_supported_ancestor(node)

  if not target then
    return nil
  end

  local lines = M.insert_docstring_for_node(bufnr, target)
  if not lines then
    return nil
  end

  local row = target:range()
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)

  return true
end

return M

local M = {}

local function safe_call(fn, ...)
  if type(fn) ~= 'function' then
    return false, 'not_callable'
  end

  local ok, result = pcall(fn, ...)
  if not ok then
    return false, tostring(result)
  end

  return true, result
end

local function parser_available(language)
  if type(vim.treesitter) ~= 'table' or type(vim.treesitter.get_parser) ~= 'function' then
    return {
      language = language,
      available = false,
      reason = 'get_parser_unavailable',
    }
  end

  local ok, parser_or_err = pcall(vim.treesitter.get_parser, 0, language)
  if not ok then
    return {
      language = language,
      available = false,
      reason = tostring(parser_or_err),
    }
  end

  return {
    language = language,
    available = parser_or_err ~= nil,
    parser_type = type(parser_or_err),
  }
end

function M.collect()
  local query_module = type(vim.treesitter) == 'table' and vim.treesitter.query or nil

  local report = {
    neovim_version = vim.version(),
    treesitter = {
      present = vim.treesitter ~= nil,
      type = type(vim.treesitter),
      has_query_module = query_module ~= nil,
      query_type = type(query_module),
      query_get = type(query_module) == 'table' and type(query_module.get) or 'absent',
      query_parse = type(query_module) == 'table' and type(query_module.parse) or 'absent',
      query_get_callable = type(query_module) == 'table' and type(query_module.get) == 'function' or false,
      query_parse_callable = type(query_module) == 'table' and type(query_module.parse) == 'function' or false,
      legacy_get_query = type(vim.treesitter) == 'table' and type(vim.treesitter.get_query) or 'absent',
      legacy_parse_query = type(vim.treesitter) == 'table' and type(vim.treesitter.parse_query) or 'absent',
      legacy_get_query_callable = type(vim.treesitter) == 'table' and type(vim.treesitter.get_query) == 'function' or false,
      legacy_parse_query_callable = type(vim.treesitter) == 'table' and type(vim.treesitter.parse_query) == 'function' or false,
    },
    parsers = {
      markdown = parser_available 'markdown',
      markdown_inline = parser_available 'markdown_inline',
    },
  }

  local get_ok, get_result = safe_call(type(query_module) == 'table' and query_module.get, 'markdown', 'highlights')
  report.treesitter.query_get_call = {
    ok = get_ok,
    detail = type(get_result),
    error = get_ok and nil or get_result,
  }

  local parse_ok, parse_result = safe_call(type(query_module) == 'table' and query_module.parse, 'markdown', '(atx_heading (inline) @x)')
  report.treesitter.query_parse_call = {
    ok = parse_ok,
    detail = type(parse_result),
    error = parse_ok and nil or parse_result,
  }

  return report
end

function M.print_report()
  local report = M.collect()
  vim.print(report)
  return report
end

return M

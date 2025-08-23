local M = {}

M.func = {
  { nil, '/// ${1:Function description}' },
  { nil, '///' },
  { nil, '/// # Arguments' },
  {
    nil,
    function(args)
      local lines = {}
      local index = 2
      for _, arg in ipairs(args.func.args or {}) do
        if arg.name ~= 'self' then
          table.insert(lines, '/// * `' .. arg.name .. '` - ${' .. index .. ':Description}')
          index = index + 1
        end
      end
      return lines
    end,
  },
  {
    nil,
    function(args)
      local ret = args.func.return_type
      if ret and ret ~= '()' then
        return {
          '///',
          '/// # Returns',
          '/// * `' .. ret .. '` - ${100:Description of return value}',
        }
      end
      return {}
    end,
  },
}

return M

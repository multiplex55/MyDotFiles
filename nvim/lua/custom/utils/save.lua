local M = {}

function M.write_all(opts)
  opts = opts or {}
  local ok, err = pcall(vim.cmd, 'wall')
  if ok then
    return true
  end

  if not opts.silent then
    vim.notify(('Failed to save all buffers before execution: %s'):format(err), vim.log.levels.WARN)
  end
  return false
end

return M

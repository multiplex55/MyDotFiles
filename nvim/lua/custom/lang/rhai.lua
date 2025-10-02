local M = {}

local function get_lsp_util()
  local ok, util = pcall(require, 'lspconfig.util')
  if ok then
    return util
  end
  local ok_alt, lspconfig = pcall(require, 'lspconfig')
  if ok_alt and lspconfig.util then
    return lspconfig.util
  end
  return nil
end

function M.get_root(fname)
  if not fname or fname == '' then
    return vim.fn.getcwd()
  end

  local util = get_lsp_util()
  if util then
    local root = util.root_pattern('Rhai.toml', '.git')(fname)
    if root and root ~= '' then
      return root
    end
    local parent = util.path and util.path.dirname and util.path.dirname(fname)
    if parent and parent ~= '' then
      return parent
    end
  end

  local dir = vim.fs.dirname(fname)
  if dir and dir ~= '' then
    local found = vim.fs.find({ 'Rhai.toml', '.git' }, { upward = true, path = dir })[1]
    if found then
      return vim.fs.dirname(found)
    end
    return dir
  end

  return vim.fn.getcwd()
end

function M.rhai_executable(opts)
  if vim.fn.executable 'rhai' == 1 then
    return true
  end
  if not (opts and opts.silent) then
    vim.notify('`rhai` executable not found in PATH', vim.log.levels.WARN)
  end
  return false
end

function M.has_formatter(bufnr)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client.supports_method and client:supports_method 'textDocument/formatting' then
      return true
    end
  end
  return false
end

function M.ensure_rhai_file(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr or 0)
  if file == '' or not file:match '%.rhai$' then
    vim.notify('Not a .rhai buffer', vim.log.levels.WARN)
    return nil
  end
  return file
end

function M.cli_fmt(file, root, opts)
  if not M.rhai_executable(opts) then
    return false
  end
  local result = vim.system({ 'rhai', 'fmt', file }, { cwd = root, text = true }):wait()
  if result.code ~= 0 then
    local err = result.stderr
    if err == '' then
      err = result.stdout
    end
    vim.notify('rhai fmt failed: ' .. (err ~= '' and err or 'unknown error'), vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.format_buffer(bufnr)
  if M.has_formatter(bufnr) then
    vim.lsp.buf.format { bufnr = bufnr, async = false }
    return true
  end

  local file = M.ensure_rhai_file(bufnr)
  if not file then
    return false
  end

  local root = M.get_root(file)
  local ok = M.cli_fmt(file, root)
  if ok then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd('silent! keepalt keepjumps noautocmd edit!')
    end)
  end
  return ok
end

function M.run_overseer(cmd, args, cwd)
  local ok, overseer = pcall(require, 'overseer')
  if not ok then
    return false
  end
  local task = overseer.new_task {
    cmd = cmd,
    args = args or {},
    cwd = cwd or vim.fn.getcwd(),
    components = { 'default' },
  }
  task:start()
  overseer.open { enter = false, direction = 'bottom' }
  return true
end

function M.term_run(cmd, args, cwd)
  cwd = cwd or vim.fn.getcwd()
  vim.cmd 'botright 12split'
  local win = vim.api.nvim_get_current_win()
  local command = { cmd }
  if args and #args > 0 then
    command = vim.list_extend(command, vim.deepcopy(args))
  end
  vim.fn.termopen(command, { cwd = cwd })
  vim.api.nvim_set_current_win(win)
  vim.cmd 'startinsert'
end

return M

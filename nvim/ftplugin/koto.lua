-- ftplugin/koto.lua
local buf = vim.api.nvim_get_current_buf()

-- Optional: Which-Key v3 group (safe no-op if wk missing/old)
local function add_wk_group(target_buf)
  local ok, wk = pcall(require, 'which-key')
  if not ok or type(wk.add) ~= 'function' then
    return
  end
  wk.add {
    { '<leader>ck', group = '[C]ode [K]oto', mode = { 'n', 'x' }, buffer = target_buf },
  }
end
add_wk_group(buf)

-- Buffer-local map helper
local function map(lhs, rhs, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, noremap = true, desc = desc })
end

-- Helpers used by the maps
local function ensure_koto_file()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == '' or not file:match '%.koto$' then
    vim.notify('Not a .koto buffer', vim.log.levels.WARN)
    return nil
  end
  return file
end

-- Prefer Overseer if available; fallback to terminal split otherwise
local function run_overseer(cmd, args, cwd)
  local ok, overseer = pcall(require, 'overseer')
  if not ok then
    return false
  end
  local task = overseer.new_task { cmd = cmd, args = args or {}, cwd = cwd or vim.fn.getcwd(), components = { 'default' } }
  task:start()
  pcall(overseer.open, { enter = false, direction = 'bottom' })
  return true
end

local function term_run(cmdline)
  vim.cmd('botright 12split | terminal ' .. cmdline)
  vim.cmd 'startinsert'
end

-- <leader>ckr — Run current file
map('<leader>ckr', function()
  local file = ensure_koto_file()
  if not file then
    return
  end
  if not run_overseer('koto', { file }) then
    term_run(string.format('koto "%s"', file))
  end
end, '[C]ode [K]oto [R]un')

-- <leader>ckR — Run current file with args (prompt)
map('<leader>ckR', function()
  local file = ensure_koto_file()
  if not file then
    return
  end
  vim.ui.input({ prompt = 'koto args: ' }, function(input)
    local args = {}
    if input and #input > 0 then
      for a in string.gmatch(input, '%S+') do
        table.insert(args, a)
      end
    end
    local full = { file }
    if vim.list_extend then
      vim.list_extend(full, args)
    else
      for _, a in ipairs(args) do
        table.insert(full, a)
      end
    end
    if not run_overseer('koto', full) then
      local cmdline = string.format('koto "%s"%s', file, (#args > 0 and ' ' .. table.concat(args, ' ') or ''))
      term_run(cmdline)
    end
  end)
end, '[C]ode [K]oto [R]un (args)')

-- <leader>ckt — Koto REPL (terminal/task)
map('<leader>ckt', function()
  if not run_overseer 'koto' then
    term_run 'koto'
  end
end, '[C]ode [K]oto [T]erm REPL')

-- LSP helpers (buffer-local)
map('<leader>ckf', function()
  if vim.lsp.buf.format then
    vim.lsp.buf.format { async = false }
  end
end, '[C]ode [K]oto [F]ormat')
map('<leader>ckh', vim.lsp.buf.hover, '[C]ode [K]oto [H]over')
map('<leader>ckg', vim.lsp.buf.definition, '[C]ode [K]oto [G]oto def')
map('<leader>ckn', vim.lsp.buf.rename, '[C]ode [K]oto Re[n]ame')
map('<leader>cka', vim.lsp.buf.code_action, '[C]ode [K]oto Code [A]ction', { 'n', 'x' })

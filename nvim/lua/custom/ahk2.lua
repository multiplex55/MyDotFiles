local M = {}

local uv = vim.uv or vim.loop

local function get(name, default)
  return vim.g[name] or vim.env[name:upper()] or default
end

local function expand(path)
  if not path or path == '' then
    return nil
  end
  return vim.fn.expand(path)
end

local function file_exists(path)
  path = expand(path)
  return path and uv.fs_stat(path) ~= nil or false
end

-- Easy-to-edit defaults for different computers.
-- You can also override these with:
--   vim.g.ahk2_node
--   vim.g.ahk2_server
--   vim.g.ahk2_exe
-- or env vars:
--   AHK2_NODE / AHK2_SERVER / AHK2_EXE
M.paths = {
  node = get('ahk2_node', [[C:\tools\node-portable\node.exe]]),
  server = get('ahk2_server', [[C:\Tools\vscode-autohotkey2-lsp\server\dist\server.js]]),
  ahk_exe = get('ahk2_exe', [[C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe]]),
}

local function resolve_node()
  local candidates = {
    M.paths.node,
    'node',
  }

  for _, candidate in ipairs(candidates) do
    local expanded = expand(candidate)
    if expanded and file_exists(expanded) then
      return expanded
    end
    if candidate and vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

local function resolve_server()
  local candidates = {
    M.paths.server,
    vim.fn.expand '~/vscode-autohotkey2-lsp/server/dist/server.js',
    [[C:\Tools\vscode-autohotkey2-lsp\server\dist\server.js]],
  }

  for _, path in ipairs(candidates) do
    path = expand(path)
    if file_exists(path) then
      return path
    end
  end

  return nil
end

local function resolve_ahk_exe()
  local candidates = {
    M.paths.ahk_exe,
    [[C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe]],
    [[C:\Program Files\AutoHotkey\v2\AutoHotkey.exe]],
  }

  for _, path in ipairs(candidates) do
    path = expand(path)
    if file_exists(path) then
      return path
    end
  end

  return nil
end

function M.build_config()
  local node = resolve_node()
  if not node then
    return nil, 'AHK LSP: could not find Node.js. Set vim.g.ahk2_node or AHK2_NODE.'
  end

  local server = resolve_server()
  if not server then
    return nil, 'AHK LSP: could not find server.js. Set vim.g.ahk2_server or AHK2_SERVER.'
  end

  local ahk_exe = resolve_ahk_exe()
  if not ahk_exe then
    return nil, 'AHK LSP: could not find AutoHotkey v2 exe. Set vim.g.ahk2_exe or AHK2_EXE.'
  end

  M.paths.node = node
  M.paths.server = server
  M.paths.ahk_exe = ahk_exe

  return {
    cmd = { node, server, '--stdio' },
    cmd_cwd = vim.fs.dirname(server),
    filetypes = { 'autohotkey', 'ahk', 'ah2' },
    single_file_support = true,
    root_dir = function(bufnr, on_dir)
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name == '' then
        return
      end

      local root = vim.fs.root(name, { '.git' })
      on_dir(root or vim.fs.dirname(name))
    end,
    init_options = {
      locale = 'en-us',
      InterpreterPath = ahk_exe,
    },
  }
end

return M

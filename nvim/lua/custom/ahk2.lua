local M = {}

-- Allow overrides from vim.g or environment variables if you want
local function get(k, default)
  return vim.g[k] or vim.env[string.upper(k)] or default
end

M.paths = {
  node = get('ahk2_node', [[C:\tools\node-portable\node.exe]]),
  server = get('ahk2_server', vim.fn.expand [[C:\Tools\vscode-autohotkey2-lsp\server\dist\server.js]]),
  ahk_exe = get('ahk2_exe', [["C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"]]),
}

local function exists(p)
  return p and vim.loop.fs_stat(p) ~= nil
end

function M.setup(opts)
  local ok_lsp, lspconfig = pcall(require, 'lspconfig')
  if not ok_lsp then
    return
  end
  local configs = require 'lspconfig.configs'
  local util = require 'lspconfig.util'

  local p = vim.tbl_deep_extend('force', M.paths, opts or {})

  if not exists(p.node) then
    vim.notify('AHK LSP: node not found at ' .. p.node, vim.log.levels.ERROR)
    return
  end
  if not exists(p.server) then
    vim.notify('AHK LSP: server not found at ' .. p.server, vim.log.levels.ERROR)
    return
  end

  if not configs.ahk2 then
    configs.ahk2 = {
      default_config = {
        cmd = { p.node, p.server, '--stdio' },
        cmd_cwd = vim.fn.fnamemodify(p.server, ':h'),
        filetypes = { 'autohotkey', 'ahk', 'ah2' },
        single_file_support = true,
        root_dir = function(fname)
          return util.path.dirname(util.path.sanitize(fname))
        end,
        init_options = {
          locale = 'en-us',
          InterpreterPath = p.ahk_exe,
        },
      },
    }
  end

  lspconfig.ahk2.setup {}
end

return M

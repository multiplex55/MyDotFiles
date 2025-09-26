-- after/ftplugin/autohotkey.lua
-- Runs whenever a buffer with filetype=autohotkey opens

local ok_lsp, lspconfig = pcall(require, 'lspconfig')
if not ok_lsp then
  return
end
local configs = require 'lspconfig.configs'
local util = require 'lspconfig.util'

-- >>> EDIT THESE PATHS <<<
local NODE = 'C:/tools/node-portable/node.exe'
local SERVER = vim.fn.expand 'C:\\Tools\\vscode-autohotkey2-lsp\\server\\dist\\server.js'
local AHK_EXE = 'E:/Github/AHK_Dev/AutoHotkey/v2/AutoHotkey64.exe'

-- Helpful: ensure Node/Server paths exist
local function _exists(p)
  return vim.loop.fs_stat(p) ~= nil
end
if not _exists(NODE) then
  vim.notify('AHK LSP: node.exe not found at ' .. NODE, vim.log.levels.ERROR)
  return
end
if not _exists(SERVER) then
  vim.notify('AHK LSP: server.js not found at ' .. SERVER, vim.log.levels.ERROR)
  return
end

-- Register once
if not configs.ahk2 then
  configs.ahk2 = {
    default_config = {
      cmd = { NODE, SERVER, '--stdio' },
      -- Run the server from its own directory (prevents odd relative-path issues)
      cmd_cwd = vim.fn.fnamemodify(SERVER, ':h'),
      filetypes = { 'autohotkey', 'ahk', 'ah2' },
      single_file_support = true,
      root_dir = function(fname)
        return util.path.dirname(util.path.sanitize(fname))
      end,
      init_options = {
        locale = 'en-us',
        InterpreterPath = AHK_EXE,
      },
    },
  }
end

-- Start/attach
lspconfig.ahk2.setup {}

-- Nice comments for ; lines
vim.bo.commentstring = '; %s'

-- Prove it attached
vim.api.nvim_create_autocmd('LspAttach', {
  buffer = 0,
  once = true,
  callback = function(args)
    local c = vim.lsp.get_client_by_id(args.data.client_id)
    vim.notify('AHK LSP attached: ' .. (c and c.name or '?'))
  end,
})

return {
  'neovim/nvim-lspconfig',
  ft = { 'ahk', 'autohotkey', 'ah2' },
  config = function()
    local lspconfig = require 'lspconfig'
    local configs = require 'lspconfig.configs'

    if not configs.ahk2 then
      configs.ahk2 = {
        default_config = {
          cmd = {
            'C:/tools/node-portable/node.exe',
            vim.fn.expand 'C:\\Tools\\vscode-autohotkey2-lsp\\server\\dist\\server.js',
            '--stdio',
          },
          filetypes = { 'ahk', 'autohotkey', 'ah2' },
          root_dir = function()
            return vim.fn.getcwd()
          end,
          init_options = {
            locale = 'en-us',
            InterpreterPath = 'E:/Github/AHK_Dev/AutoHotkey/v2/AutoHotkey64.exe',
          },
          single_file_support = true,
        },
      }
    end

    lspconfig.ahk2.setup {}
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'ahk', 'autohotkey', 'ah2' },
      callback = function()
        vim.bo.commentstring = '; %s'
      end,
    })
  end,
}

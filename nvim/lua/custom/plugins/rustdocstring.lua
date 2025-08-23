return {
  'nvim-treesitter/nvim-treesitter',
  ft = 'rust',
  config = function()
    local M = require 'rustdocstring' -- assuming the logic is in rustdocstring.lua

    vim.api.nvim_create_user_command('RustDocstring', function()
      M.insert_docstring()
    end, {})

    vim.api.nvim_create_user_command('RustDocstringAll', function()
      local ts_utils = require 'nvim-treesitter.ts_utils'
      local parsers = require 'nvim-treesitter.parsers'
      local docgen = require 'rustdocstring'

      local bufnr = vim.api.nvim_get_current_buf()
      local parser = parsers.get_parser(bufnr, 'rust')
      local tree = parser:parse()[1]
      local root = tree:root()

      local function_items = {}

      for node in root:iter_children() do
        if node:type() == 'function_item' then
          table.insert(function_items, node)
        end
      end

      table.sort(function_items, function(a, b)
        local a_row = a:range()
        local b_row = b:range()
        return a_row > b_row
      end)

      for _, node in ipairs(function_items) do
        local lines = docgen.insert_docstring_for_node(bufnr, node)
        if lines then
          local row = node:range()
          vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
        end
      end
    end, { desc = 'Generate Rust docstrings for all functions in file' })

    vim.api.nvim_create_user_command('RustDocstringAllKinds', function()
      local ts_utils = require 'nvim-treesitter.ts_utils'
      local parsers = require 'nvim-treesitter.parsers'
      local docgen = require 'rustdocstring'

      local bufnr = vim.api.nvim_get_current_buf()
      local parser = parsers.get_parser(bufnr, 'rust')
      local tree = parser:parse()[1]
      local root = tree:root()

      local supported_kinds = {
        function_item = docgen.generate_function_doc,
        struct_item = docgen.generate_struct_doc,
        enum_item = docgen.generate_enum_doc,
        impl_item = function()
          return {
            '/// Describe this impl block.',
            '///',
            '/// This block contains method implementations or trait impls.',
          }
        end,
      }

      local nodes = {}
      for node in root:iter_children() do
        local node_type = node:type()
        if supported_kinds[node_type] then
          table.insert(nodes, node)
        end
      end

      -- Process in reverse order to avoid shifting offsets
      table.sort(nodes, function(a, b)
        local a_row = a:range()
        local b_row = b:range()
        return a_row > b_row
      end)

      for _, node in ipairs(nodes) do
        local kind = node:type()
        local doc_func = supported_kinds[kind]
        local lines = doc_func(bufnr, node)
        if lines and #lines > 0 then
          local row = node:range()
          vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
        end
      end
    end, { desc = 'Generate docstrings for all functions, structs, enums, and impls' })
  end,
}

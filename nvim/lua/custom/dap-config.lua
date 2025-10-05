local dap = require 'dap'

local rust_dap_initialized = false

local function setup_rust_dap()
  if rust_dap_initialized then
    return
  end

  local ok, cfg = pcall(require, 'rustaceanvim.config')
  if not ok then
    return
  end

  rust_dap_initialized = true

  -- Use environment variable to get install path
  local install_path = vim.fn.expand '$MASON' .. '\\packages\\codelldb'
  local extension_path = install_path .. '\\extension\\'
  local codelldb_path = extension_path .. 'adapter\\codelldb.exe'
  local liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'

  vim.g.rustaceanvim = vim.tbl_deep_extend('force', vim.g.rustaceanvim or {}, {
    dap = {
      adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path, function(callback, adapter)
        callback(adapter)

        local session = require('dap').session()
        if session then
          -- 🛠 Inject initial LLDB settings
          local function lldb_eval(cmd)
            session:request('evaluate', {
              expression = cmd,
              context = 'repl',
            }, function(err, _)
              if err then
                vim.notify('[LLDB Injection Error] ' .. err.message, vim.log.levels.ERROR)
              end
            end)
          end

          lldb_eval 'settings set target.language rust'
          lldb_eval 'settings set target.inline-breakpoint-strategy always'
          lldb_eval 'settings set target.x86-disassembly-flavor intel'

          vim.notify('[LLDB Setup] Rust mode and options injected ✅', vim.log.levels.INFO)
        end
      end),
    },
  })
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyLoad',
  callback = function(event)
    if event.data == 'rustaceanvim' then
      setup_rust_dap()
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'toml', 'ron' },
  callback = function()
    local ok, lazy = pcall(require, 'lazy')
    if ok then
      lazy.load { plugins = { 'rustaceanvim' } }
    end
    setup_rust_dap()
  end,
})

if package.loaded['rustaceanvim'] or package.loaded['rustaceanvim.config'] then
  setup_rust_dap()
end

dap.configurations.rust = {
  {
    name = 'Launch Rust (smart build)',
    type = 'codelldb', --rust
    request = 'launch',
    program = function()
      local uv = vim.uv or vim.loop
      local cwd = vim.fn.getcwd()
      local exe_name = vim.fn.fnamemodify(cwd, ':t')
      local exe = vim.fs.joinpath(cwd, 'target', 'debug', exe_name)

      local function mtime_seconds(stat)
        if not stat or not stat.mtime then
          return nil
        end
        local mtime = stat.mtime
        return (mtime.sec or 0) + (mtime.nsec or 0) / 1e9
      end

      local exe_stat = uv.fs_stat(exe)
      local needs_build = exe_stat == nil

      local manifest_paths = {
        vim.fs.joinpath(cwd, 'Cargo.toml'),
        vim.fs.joinpath(cwd, 'Cargo.lock'),
      }

      local latest_manifest_mtime = 0
      for _, path in ipairs(manifest_paths) do
        local stat = uv.fs_stat(path)
        local mt = mtime_seconds(stat)
        if mt and mt > latest_manifest_mtime then
          latest_manifest_mtime = mt
        end
      end

      if not needs_build and latest_manifest_mtime > 0 then
        local exe_mtime = mtime_seconds(exe_stat) or 0
        if exe_mtime < latest_manifest_mtime then
          needs_build = true
        end
      end

      if needs_build then
        local result = vim.system({ 'cargo', 'build' }, { cwd = cwd, text = true }):wait()
        if result.code ~= 0 then
          vim.notify(
            ('[Rust Debug] cargo build failed (code %d):\n%s'):format(result.code, result.stderr or ''),
            vim.log.levels.ERROR
          )
          return nil
        end
      end

      return exe
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

-- Helper: try to auto-pick a single exe under zig-out/bin, else prompt
local function zig_pick_program()
  local bin = vim.fn.getcwd() .. '\\zig-out\\bin\\'
  local exes = vim.fn.glob(bin .. '*.exe', false, true)
  if #exes == 1 then
    return exes[1]
  end
  return vim.fn.input('Path to exe: ', bin, 'file')
end

dap.configurations.zig = {
  {
    name = 'Debug: zig-out/bin/<app>.exe',
    type = 'codelldb',
    request = 'launch',
    program = zig_pick_program,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  {
    name = 'Debug: current file (build-exe then launch)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      -- Build a temporary exe for the current file, then debug it
      local src = vim.fn.expand '%:p'
      local out = vim.fn.fnamemodify(src, ':r') .. '.exe'
      -- Build (Debug, with DWARF info)
      vim.fn.jobstart({ 'zig', 'build-exe', '-O', 'Debug', '-g', src, '-femit-bin=' .. out }, {
        cwd = vim.fn.getcwd(),
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code)
          if code ~= 0 then
            vim.schedule(function()
              vim.notify('zig build-exe failed; check :messages', vim.log.levels.ERROR)
            end)
          end
        end,
      })
      return out
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

local dapui = require 'dapui'
dapui.setup()

-- Auto open/close dap-ui
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

-- 🛠 Rust LLDB Pretty-Printer Injection (Fixed)
dap.listeners.after.event_initialized['rust_pretty_printers'] = function(session)
  local function lldb_eval(cmd)
    session:request('evaluate', {
      expression = cmd,
      context = 'repl',
    }, function(err, _)
      if err then
        vim.notify('[LLDB PrettyPrint] Injection error: ' .. err.message, vim.log.levels.ERROR)
      end
    end)
  end

  -- Strings, Vectors
  lldb_eval 'type summary add --summary-string "[len=${var.len}] \\"${var.data%S}\\"" "alloc::vec::Vec<u8>"'
  lldb_eval 'type summary add --summary-string "\\"${var.data}\\"" "alloc::string::String"'

  -- Pointers

  lldb_eval 'type summary add --summary-string "ptr: ${var%S}" "u8 *"'
  lldb_eval 'type summary add --summary-string "ptr: ${var%S}" "i8 *"'

  -- Common containers
  lldb_eval 'type summary add --summary-string "${var.value}" "core::option::Option<*>"'
  lldb_eval 'type summary add --summary-string "${var.value}" "core::result::Result<*>"'
  lldb_eval 'type summary add --summary-string "${var.value}" "std::boxed::Box<*>"'
  lldb_eval 'type summary add --summary-string "${var.data}" "std::rc::Rc<*>"'
  lldb_eval 'type summary add --summary-string "${var.data}" "std::sync::Arc<*>"'
  lldb_eval 'type summary add --summary-string "${var.value}" "core::cell::RefCell<*>"'
  lldb_eval 'type summary add --summary-string "size=${var.table.size}" "std::collections::HashMap<*,*>"'

  vim.notify('[LLDB PrettyPrint] Rust summaries injected ✅', vim.log.levels.INFO)
end

-- DAP-VirtualText
require('nvim-dap-virtual-text').setup {
  enabled = true,
  commented = true,
}

-- Telescope integration
require('telescope').load_extension 'dap'

-- Custom Icons for Debugging
vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '👉', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '⚠️', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = '', linehl = '', numhl = '' })

-- Keybindings
local map = vim.keymap.set

map('n', '<leader>cdd', function()
  dap.continue()
end, { desc = '[C]ode [D]ebug Start/Continue' })
map('n', '<leader>cdt', function()
  dap.terminate()
end, { desc = '[C]ode [D]ebug Terminate' })
map('n', '<leader>cdb', function()
  dap.toggle_breakpoint()
end, { desc = '[C]ode [D]ebug Toggle Breakpoint' })
map('n', '<leader>cdB', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = '[C]ode [D]ebug Set Breakpoint Condition' })
map('n', '<leader>cdo', function()
  dap.step_over()
end, { desc = '[C]ode [D]ebug Step Over' })
map('n', '<leader>cdi', function()
  dap.step_into()
end, { desc = '[C]ode [D]ebug Step Into' })
map('n', '<leader>cdu', function()
  dap.step_out()
end, { desc = '[C]ode [D]ebug Step Out' })
map('n', '<leader>cdr', function()
  dap.repl.open()
end, { desc = '[C]ode [D]ebug REPL Open' })
map('n', '<leader>cda', function()
  dap.attach()
end, { desc = '[C]ode [D]ebug Attach to Process' })
map('n', '<leader>cde', function()
  require('dap.ui.widgets').hover()
end, { desc = '[C]ode [D]ebug [E]valuate [E]xpression' })

-- Telescope DAP pickers
map('n', '<leader>cdf', '<cmd>Telescope dap frames<cr>', { desc = '[C]ode [D]ebug [F]rames' })
map('n', '<leader>cds', '<cmd>Telescope dap scopes<cr>', { desc = '[C]ode [D]ebug [S]copes' })
map('n', '<leader>cdp', '<cmd>Telescope dap list_breakpoints<cr>', { desc = '[C]ode [D]ebug [P]oints (breakpoints)' })

-- === 🧠 Advanced Debugging Utilities ===

-- Manual Memory Read (Read arbitrary memory while paused)
map('n', '<leader>cdmm', function()
  local dap = require 'dap'
  local addr = vim.fn.input 'Memory address (hex): 0x'
  local size = tonumber(vim.fn.input 'Bytes to read: ')

  dap.session():request('readMemory', {
    memoryReference = '0x' .. addr,
    count = size,
  }, function(err, response)
    if err then
      vim.notify('Memory read failed: ' .. err.message, vim.log.levels.ERROR)
    else
      vim.pretty_print(response)
    end
  end)
end, { desc = '[C]ode [D]ebug [M]emory [M]anual read' })

-- Set Breakpoint at Specific Memory Address
map('n', '<leader>cdmb', function()
  local addr = vim.fn.input 'Breakpoint memory address (hex): 0x'
  require('dap').set_breakpoint('0x' .. addr)
end, { desc = '[C]ode [D]ebug [M]emory [B]reakpoint' })

-- Evaluate Expression on the Fly (popup)
map('n', '<leader>cdep', function()
  local expr = vim.fn.input 'Evaluate Expression: '
  require('dapui').eval(expr)
end, { desc = '[C]ode [D]ebug [E]valuate expression ([P]opup)' })

-- Toggle Exception Breakpoints (for panic / errors)
map('n', '<leader>cdxe', function()
  require('dap').set_exception_breakpoints { 'rust_panic' }
  vim.notify('Exception Breakpoints Set (Rust Panic)', vim.log.levels.INFO)
end, { desc = '[C]ode [D]ebug E[x]ception [E]nable (Rust Panic)' })

-- (Optional) Time-traveling: Start record/replay session (rr)
-- ONLY works if using rr+codelldb and Linux
-- map('n', '<leader>ctr', function()
--   require('dap').run({
--     type = 'codelldb',
--     request = 'launch',
--     program = function()
--       local cwd = vim.fn.getcwd()
--       vim.fn.system 'cargo build'
--       return cwd .. '/target/debug/' .. vim.fn.fnamemodify(cwd, ':t')
--     end,
--     args = {},
--     cwd = '${workspaceFolder}',
--     record = true, -- <-- rr recording
--   })
-- end, { desc = '[C]ode [T]ime-[R]ecord (rr)' })

-- === Advanced Debugging: Return Value Tracker + Memory Viewer ===

-- Floating Window Utility (simple)
local function create_floating_window(title, content)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.3)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = title or '',
    title_pos = 'center',
  })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  return buf, win
end

-- 📈 Function Return Value Tracker
map('n', '<leader>cdrv', function()
  local dap = require 'dap'

  dap.session():request('scopes', { frameId = dap.session().current_frame.id }, function(err, response)
    if err then
      vim.notify('Failed to retrieve scopes: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    for _, scope in ipairs(response.scopes) do
      if scope.name == 'Locals' then
        dap.session():request('variables', { variablesReference = scope.variablesReference }, function(err2, vars)
          if err2 then
            vim.notify('Failed to retrieve variables: ' .. err2.message, vim.log.levels.ERROR)
            return
          end

          for _, var in ipairs(vars.variables) do
            if var.name == 'return' then
              create_floating_window('Return Value', { var.value })
              return
            end
          end

          vim.notify('No return value found in locals.', vim.log.levels.WARN)
        end)
        return
      end
    end

    vim.notify('No Locals scope found.', vim.log.levels.WARN)
  end)
end, { desc = '[C]ode [D]ebug [R]eturn [V]alue tracker' })

-- 🧹 Floating Window Memory Viewer
map('n', '<leader>cdmmv', function()
  local dap = require 'dap'
  local addr = vim.fn.input 'Memory address (hex): 0x'
  local size = tonumber(vim.fn.input 'Bytes to read: ')

  dap.session():request('readMemory', {
    memoryReference = '0x' .. addr,
    count = size,
  }, function(err, response)
    if err then
      vim.notify('Memory read failed: ' .. err.message, vim.log.levels.ERROR)
    else
      local lines = {}

      for i = 1, #response.memory, 16 do
        local slice = {}
        for j = i, math.min(i + 15, #response.memory) do
          table.insert(slice, string.format('%02X', response.memory:byte(j)))
        end
        table.insert(lines, table.concat(slice, ' '))
      end

      create_floating_window('Memory Viewer', lines)
    end
  end)
end, { desc = '[C]ode [D]ebug [M]emory [M]emory [V]iew floating window' })

map('n', '<leader>cdva', function()
  local dapui = require 'dapui'
  local dap = require 'dap'

  -- Prompt for variable name
  local varname = vim.fn.input 'Variable name: '

  dap.session():request('scopes', { frameId = dap.session().current_frame.id }, function(err, response)
    if err then
      vim.notify('Failed to retrieve scopes: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    for _, scope in ipairs(response.scopes) do
      dap.session():request('variables', { variablesReference = scope.variablesReference }, function(err2, vars)
        if err2 then
          vim.notify('Failed to retrieve variables: ' .. err2.message, vim.log.levels.ERROR)
          return
        end

        for _, var in ipairs(vars.variables) do
          if var.name == varname then
            if var.memoryReference then
              vim.notify('Memory Reference: 0x' .. string.format('%X', tonumber(var.memoryReference)))
            else
              vim.notify('Variable does not have a memory reference (simple value type)', vim.log.levels.WARN)
            end
            return
          end
        end

        vim.notify('Variable not found in current scope.', vim.log.levels.WARN)
      end)
    end
  end)
end, { desc = '[C]ode [D]ebug [V]ariable [A]ddress lookup' })

-- === 🔭 DAP Telescope Variable Memory Picker ===
map('n', '<leader>cdvp', function()
  local dap = require 'dap'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local conf = require('telescope.config').values

  dap.session():request('scopes', { frameId = dap.session().current_frame.id }, function(err, response)
    if err then
      vim.notify('Failed to retrieve scopes: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    local variables = {}

    local function collect_variables(scope_idx)
      if scope_idx > #response.scopes then
        if vim.tbl_isempty(variables) then
          vim.notify('No variables found in scopes.', vim.log.levels.WARN)
          return
        end

        pickers
          .new({}, {
            prompt_title = 'DAP Variables (Memory References)',
            finder = finders.new_table {
              results = variables,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry.name,
                  ordinal = entry.name,
                }
              end,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                  local var = selection.value
                  if var.memoryReference then
                    vim.notify(string.format('Variable: %s\nMemory Reference: 0x%X', var.name, tonumber(var.memoryReference)), vim.log.levels.INFO)
                  else
                    vim.notify('Selected variable has no memory reference (simple value type)', vim.log.levels.WARN)
                  end
                end
              end)
              return true
            end,
          })
          :find()
        return
      end

      local scope = response.scopes[scope_idx]
      dap.session():request('variables', { variablesReference = scope.variablesReference }, function(err2, vars)
        if not err2 and vars and vars.variables then
          for _, var in ipairs(vars.variables) do
            table.insert(variables, var)
          end
        end
        collect_variables(scope_idx + 1)
      end)
    end

    collect_variables(1)
  end)
end, { desc = '[C]ode [D]ebug [V]ariable [P]icker (Telescope)' })

-- === 📦 Smart Recursive Debug Variable Explorer ===
map('n', '<leader>cdve', function()
  local dap = require 'dap'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local conf = require('telescope.config').values

  local session = dap.session()
  if not session then
    vim.notify('No active debug session', vim.log.levels.WARN)
    return
  end

  local function decode_bytes(str)
    if not str then
      return nil
    end
    local success, decoded = pcall(vim.fn.strtrans, str)
    if success and decoded and decoded:match '%g' then
      return decoded
    end
    return nil
  end

  local function fetch_variables(variablesReference, depth)
    depth = depth or 1
    if depth > 3 then
      return {}
    end -- Limit depth to avoid infinite recursion

    local result = {}
    local done = false

    session:request('variables', { variablesReference = variablesReference }, function(err, response)
      if err then
        vim.notify('Failed fetching variables: ' .. err.message, vim.log.levels.ERROR)
        done = true
        return
      end

      for _, var in ipairs(response.variables or {}) do
        local entry = {
          name = var.name,
          value = var.value,
          type = var.type,
          path = var.name,
          varRef = var.variablesReference,
        }

        -- If expandable, recurse
        if var.variablesReference and var.variablesReference > 0 then
          entry.children = fetch_variables(var.variablesReference, depth + 1)
        else
          -- Try decode values
          local decoded = decode_bytes(var.value)
          if decoded then
            entry.value = decoded
          end
        end

        table.insert(result, entry)
      end

      done = true
    end)

    -- Wait for async request
    vim.wait(1000, function()
      return done
    end)

    return result
  end

  local function flatten_variables(variables, prefix)
    prefix = prefix or ''
    local results = {}

    for _, var in ipairs(variables) do
      local name = prefix .. var.name
      local value = var.value or ''
      local typeinfo = var.type or ''
      table.insert(results, {
        display = name .. ' = ' .. value .. ' [' .. typeinfo .. ']',
        var = var,
      })

      -- Flatten children recursively
      if var.children then
        local child_prefix = name .. '.'
        local child_entries = flatten_variables(var.children, child_prefix)
        vim.list_extend(results, child_entries)
      end
    end

    return results
  end

  session:request('scopes', { frameId = session.current_frame.id }, function(err, response)
    if err then
      vim.notify('Failed to get scopes: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    local scopes = response.scopes or {}
    if vim.tbl_isempty(scopes) then
      vim.notify('No scopes available', vim.log.levels.WARN)
      return
    end

    pickers
      .new({}, {
        prompt_title = 'Select Scope to Explore',
        finder = finders.new_table {
          results = scopes,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name,
              ordinal = entry.name,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end

            local vars = fetch_variables(selection.value.variablesReference)
            local flattened = flatten_variables(vars)

            pickers
              .new({}, {
                prompt_title = 'Variables [' .. selection.value.name .. ']',
                finder = finders.new_table {
                  results = flattened,
                  entry_maker = function(entry)
                    return {
                      value = entry.var,
                      display = entry.display,
                      ordinal = entry.display,
                    }
                  end,
                },
                sorter = conf.generic_sorter {},
                attach_mappings = function(prompt_bufnr2, map2)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr2)
                    local var = action_state.get_selected_entry().value
                    vim.notify(string.format('📋 %s = %s\n📦 Type: %s', var.name, var.value, var.type), vim.log.levels.INFO)
                  end)
                  return true
                end,
              })
              :find()
          end)
          return true
        end,
      })
      :find()
  end)
end, { desc = '[C]ode [D]ebug [V]ariable [E]xplore (Recursive Smart)' })

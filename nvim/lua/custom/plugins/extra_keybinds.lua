local M = {}

local did_setup = false

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  local function load_which_key()
    local ok, wk = pcall(require, 'which-key')
    if ok then
      return wk
    end

    local lazy_ok, lazy = pcall(require, 'lazy')
    if not lazy_ok then
      return nil
    end

    lazy.load { plugins = { 'which-key.nvim' } }
    local loaded, which_key = pcall(require, 'which-key')
    if loaded then
      return which_key
    end

    return nil
  end

  local function register_buffer_groups(buf, spec)
    local wk = load_which_key()
    if not wk then
      return
    end
    local with_buffer = {}
    for _, entry in ipairs(spec) do
      local copy = vim.tbl_extend('force', {}, entry)
      copy.buffer = buf
      table.insert(with_buffer, copy)
    end
    wk.add(with_buffer)
  end

  local function load_neocomposer(module_name)
    local lazy_ok, lazy = pcall(require, 'lazy')
    if not lazy_ok then
      return nil
    end

    lazy.load { plugins = { 'NeoComposer.nvim' } }

    local ok, module = pcall(require, module_name)
    if ok then
      return module
    end

    return nil
  end

  local function is_tabscope_available()
    local ok_config, Config = pcall(require, 'lazy.core.config')
    if not ok_config or not Config.plugins then
      return false
    end

    return Config.plugins['tabscope.nvim'] ~= nil
  end

  local function with_tabscope(fn)
    local lazy_ok, lazy = pcall(require, 'lazy')
    if not lazy_ok then
      return
    end

    if not is_tabscope_available() then
      return
    end

    lazy.load { plugins = { 'tabscope.nvim' } }

    local ok, tabscope = pcall(require, 'tabscope')
    if not ok then
      return
    end

    return fn(tabscope)
  end

  local function load_plugin(name)
    local lazy_ok, lazy = pcall(require, 'lazy')
    if not lazy_ok then
      return false
    end

    local ok_config, Config = pcall(require, 'lazy.core.config')
    if ok_config and Config.plugins and Config.plugins[name] == nil then
      return false
    end

    lazy.load { plugins = { name } }
    return true
  end

  local function lazy_require(module, plugin)
    if plugin then
      load_plugin(plugin)
    else
      load_plugin(module)
    end

    local ok, mod = pcall(require, module)
    if not ok then
      return nil
    end

    return mod
  end

  local function with_neotest(action)
    if not load_plugin('nvim-neotest/neotest') then
      return
    end

    local neotest = lazy_require('neotest', 'nvim-neotest/neotest')
    if not neotest then
      return
    end

    return action(neotest)
  end


  -- Trouble & quickfix bindings
  local function toggle_trouble(mode)
    require('lazy').load { plugins = { 'trouble.nvim' } }
    require('trouble').toggle(mode)
  end

  vim.keymap.set('n', '<leader>xx', function()
    toggle_trouble 'buffer_diagnostics'
  end, { desc = '[x] Trouble buffer diagnostics' })

  vim.keymap.set('n', '<leader>xw', function()
    toggle_trouble 'diagnostics'
  end, { desc = '[x] Trouble workspace diagnostics' })

  vim.keymap.set('n', '<leader>xr', function()
    toggle_trouble 'lsp_references'
  end, { desc = '[x] Trouble LSP references' })

  vim.keymap.set('n', '<leader>xt', function()
    toggle_trouble 'todo'
  end, { desc = '[x] Trouble TODOs' })

  vim.keymap.set('n', '<leader>xl', function()
    toggle_trouble 'loclist'
  end, { desc = '[x] Trouble location list' })

  vim.keymap.set('n', '<leader>xq', function()
    toggle_trouble 'quickfix'
  end, { desc = '[x] Trouble quickfix list' })

  -- NeoComposer macro management bindings
  -- These keymaps lazy-load NeoComposer before interacting with its UI or macro helpers.
  vim.keymap.set('n', '<leader>qm', function()
    local ui = load_neocomposer 'NeoComposer.ui'
    if ui and ui.toggle_macro_menu then
      ui.toggle_macro_menu()
    end
  end, { desc = '[Q]ueued macros menu' })

  vim.keymap.set('n', '<leader>qe', function()
    if load_neocomposer 'NeoComposer.ui' then
      vim.cmd.EditMacros()
    end
  end, { desc = '[Q]ueued macros edit buffer' })

  vim.keymap.set('n', '<leader>qd', function()
    if load_neocomposer 'NeoComposer.macro' then
      vim.cmd.ToggleDelay()
    end
  end, { desc = '[Q]ueued macros toggle delay' })

  vim.keymap.set('n', '<leader>qs', function()
    local macro = load_neocomposer 'NeoComposer.macro'
    if macro and macro.halt_macro then
      macro.halt_macro()
    end
  end, { desc = '[Q]ueued macros halt playback' })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'nim',
    callback = function(ev)
      local buf = ev.buf
      register_buffer_groups(buf, {
        { '<leader>cn', group = '[C]ode [N]im', mode = 'n' },
      })

      vim.keymap.set('n', '<leader>cnpr', function()
        local dir_path = vim.fn.expand '%:p:h'
        local filename_no_ext = vim.fn.expand '%:t:r'
        local full_path_with_ext = vim.fn.expand '%:p'

        local cmd = string.format(':tabnew | term nim cpp -d:release -r --out:"%s\\bin\\%s" "%s"', dir_path, filename_no_ext, full_path_with_ext)
        vim.cmd(cmd)
      end, { buffer = buf, desc = '[C]ode [N]im c[P]p [R]un release' })
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'rust', 'toml' },
    callback = function(ev)
      local buf = ev.buf
      register_buffer_groups(buf, {
        { '<leader>cc', group = '[C]ode [C]argo', mode = 'n' },
        { '<leader>cr', group = '[C]ode [R]ust', mode = 'n' },
      })

      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
      end

      map('<leader>cc', '<Nop>', '[C]ode [C]argo')
      map('<leader>ccc', '<cmd>tabnew | term cargo clean<cr>', '[C]ode [C]argo [C]lean')
      map('<leader>ccd', '<cmd>tabnew | term cargo doc --open<cr>', '[C]ode [C]argo [D]oc open')
      if not (vim.bo[buf].filetype == 'toml' and vim.api.nvim_buf_get_name(buf):match 'Cargo%.toml$') then
        map('<leader>ccu', '<cmd>tabnew | term cargo update<cr>', '[C]ode [C]argo [U]pdate deps')
      end
      map('<leader>ccf', '<cmd>tabnew | term cargo fmt<cr>', '[C]ode [C]argo [F]ormat code')

      map('<leader>cr', '<Nop>', '[C]ode [R]ust')
      map('<leader>crr', '<cmd>tabnew | term cargo run<cr>', '[C]ode [R]ust [R]un')
      map('<leader>crR', '<cmd>tabnew | term cargo run --release<cr>', '[C]ode [R]ust Run --[R]elease')
      map('<leader>crb', '<cmd>tabnew | term cargo build<cr>', '[C]ode [R]ust [B]uild')
      map('<leader>crB', '<cmd>tabnew | term cargo build --release<cr>', '[C]ode [R]ust Build --[R]elease')
      map('<leader>crT', '<cmd>tabnew | term cargo test<cr>', '[C]ode [R]ust [T]est suite')
      map('<leader>crt', '<cmd>tabnew | term cargo nextest run --no-capture --test-threads=1<cr>', '[C]ode [R]ust [T]est')
      map('<leader>crc', '<cmd>tabnew | term cargo check<cr>', '[C]ode [R]ust [C]heck')
      map('<leader>crl', '<cmd>tabnew | term cargo clippy<cr>', '[C]ode [R]ust C[L]ippy lint')
      map('<leader>crd', function()
        vim.cmd.RustDocstring()
      end, '[C]ode [R]ust [D]ocstring current item')
      map('<leader>crD', function()
        vim.cmd.RustDocstringAllKinds()
      end, '[C]ode [R]ust [D]ocstring all kinds')

      map('<leader>cru', function()
        vim.cmd.RustLsp { 'runnables' }
      end, '[C]ode [R]ust R[U]nnables')
      map('<leader>crg', function()
        vim.cmd.RustLsp { 'debuggables' }
      end, '[C]ode [R]ust debu[g]gables')
      map('<leader>crp', function()
        vim.cmd.RustLsp { 'parentModule' }
      end, '[C]ode [R]ust [P]arent module')
      map('<leader>crm', function()
        vim.cmd.RustLsp { 'expandMacro' }
      end, '[C]ode [R]ust expand [M]acro')
      map('<leader>cre', function()
        vim.cmd.RustLsp { 'explainError' }
      end, '[C]ode [R]ust [E]xplain error')
      map('<leader>crO', function()
        vim.cmd.RustLsp { 'openDocs' }
      end, '[C]ode [R]ust [O]pen docs')
      map('<leader>crs', function()
        vim.cmd.RustLsp { 'syntaxTree' }
      end, '[C]ode [R]ust [S]yntax tree')
      map('<leader>crG', function()
        if vim.fn.executable 'dot' ~= 1 then
          vim.notify('`dot` executable (Graphviz) is required for the crate graph', vim.log.levels.WARN)
          return
        end
        vim.cmd.RustLsp { 'viewCrateGraph', backend = 'graphviz', full = true }
      end, '[C]ode [R]ust Crate [G]raph (Graphviz)')
    end,
  })

  vim.keymap.set('n', '<leader>ct', '<Nop>', { desc = '[C]ode [T]est' })
  vim.keymap.set('n', '<leader>ctn', function()
    with_neotest(function(neotest)
      neotest.run.run()
    end)
  end, { desc = '[C]ode [T]est [N]earest' })
  vim.keymap.set('n', '<leader>ctf', function()
    with_neotest(function(neotest)
      neotest.run.run(vim.fn.expand '%')
    end)
  end, { desc = '[C]ode [T]est Current [F]ile' })
  vim.keymap.set('n', '<leader>ctu', function()
    with_neotest(function(neotest)
      neotest.run.run { suite = true }
    end)
  end, { desc = '[C]ode [T]est R[U]n suite' })
  vim.keymap.set('n', '<leader>ctw', function()
    with_neotest(function(neotest)
      neotest.watch.toggle(vim.fn.expand '%')
    end)
  end, { desc = '[C]ode [T]est [W]atch file toggle' })
  vim.keymap.set('n', '<leader>ctd', function()
    with_neotest(function(neotest)
      neotest.run.run { strategy = 'dap' }
    end)
  end, { desc = '[C]ode [T]est [D]ebug via DAP' })
  vim.keymap.set('n', '<leader>cts', function()
    with_neotest(function(neotest)
      local utils = require 'custom.utils'
      local function open()
        neotest.summary.open()
      end
      local function close()
        neotest.summary.close()
      end

      if utils.toggle_edgy_view {
        ft = 'neotest-summary',
        open = open,
        close = close,
      } then
        return
      end

      neotest.summary.toggle()
    end)
  end, { desc = '[C]ode [T]est [S]ummary toggle' })
  vim.keymap.set('n', '<leader>ctl', function()
    with_neotest(function(neotest)
      neotest.run.run_last()
    end)
  end, { desc = '[C]ode [T]est Run [L]ast' })
  vim.keymap.set('n', '<leader>ctD', function()
    with_neotest(function(neotest)
      neotest.run.run_last { strategy = 'dap' }
    end)
  end, { desc = '[C]ode [T]est Run last ([D]AP)' })
  vim.keymap.set('n', '<leader>ctS', function()
    with_neotest(function(neotest)
      neotest.run.stop()
    end)
  end, { desc = '[C]ode [T]est [S]top' })
  vim.keymap.set('n', '<leader>cta', function()
    with_neotest(function(neotest)
      neotest.run.attach()
    end)
  end, { desc = '[C]ode [T]est [A]ttach to nearest' })
  vim.keymap.set('n', '<leader>cto', function()
    with_neotest(function(neotest)
      neotest.output.open { enter = true }
    end)
  end, { desc = '[C]ode [T]est [O]utput float' })
  vim.keymap.set('n', '<leader>ctL', function()
    with_neotest(function(neotest)
      neotest.output.open { enter = false, last_run = true }
    end)
  end, { desc = '[C]ode [T]est Last output (no focus)' })
  vim.keymap.set('n', '<leader>ctp', function()
    with_neotest(function(neotest)
      neotest.output_panel.toggle()
    end)
  end, { desc = '[C]ode [T]est [P]anel toggle' })
  vim.keymap.set('n', '<leader>ctj', function()
    with_neotest(function(neotest)
      neotest.jump.next { status = 'failed' }
    end)
  end, { desc = '[C]ode [T]est [J]ump to next fail' })
  vim.keymap.set('n', '<leader>ctk', function()
    with_neotest(function(neotest)
      neotest.jump.prev { status = 'failed' }
    end)
  end, { desc = '[C]ode [T]est [K] Jump to previous fail' })
  -- Increase font size
  vim.keymap.set('n', '<C-=>', function()
    local font = vim.o.guifont
    local name, size = string.match(font, '([^:]+):h(%d+)')
    size = tonumber(size) + 1
    vim.o.guifont = name .. ':h' .. size
  end)
  -- Decrease font size
  vim.keymap.set('n', '<C-->', function()
    local font = vim.o.guifont
    local name, size = string.match(font, '([^:]+):h(%d+)')
    size = tonumber(size) - 1
    vim.o.guifont = name .. ':h' .. size
  end)
  -- Format Buffer
  vim.keymap.set('n', '<leader>fb', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[F]ormat buffer' })
  -- Window Management
  local function winshift()
    require('lazy').load { plugins = { 'winshift.nvim' } }
    return require 'winshift'
  end

  local function duplicate_current_tab()
    local log_messages = {}
    local function log(msg)
      table.insert(log_messages, msg)
    end

    log('duplicate_current_tab invoked (<leader>tD)')

    local current_win = vim.api.nvim_get_current_win()

    local layout_buffers = {}

    local function capture_layout(node)
      local kind = node[1]
      if kind == 'leaf' then
        local winid = node[2]
        local buf = vim.api.nvim_win_get_buf(winid)
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local view = vim.api.nvim_win_call(winid, function()
          return vim.fn.winsaveview()
        end)

        return {
          type = 'leaf',
          buf = buf,
          cursor = cursor,
          view = view,
          focused = winid == current_win,
        }
      end

      local children = {}
      for index, child in ipairs(node[2]) do
        children[index] = capture_layout(child)
      end

      return {
        type = kind,
        children = children,
      }
    end

    local function collect_buffers(snapshot)
      if snapshot.type == 'leaf' then
        if snapshot.buf and vim.api.nvim_buf_is_valid(snapshot.buf) then
          layout_buffers[snapshot.buf] = true
        end
        return
      end

      for _, child in ipairs(snapshot.children or {}) do
        collect_buffers(child)
      end
    end

    local tabscope_source_buffers = nil
    local tabscope_source_tab = vim.api.nvim_get_current_tabpage()

    if not is_tabscope_available() then
      log('TabScope not available; relying solely on layout snapshot data')
    end

    with_tabscope(function(ts)
      tabscope_source_tab = vim.api.nvim_get_current_tabpage()
      if ts.tab_buffers and ts.tab_buffers.get_current_tab_local_buffers then
        local ok, buffers = pcall(ts.tab_buffers.get_current_tab_local_buffers)
        if ok and type(buffers) == 'table' then
          tabscope_source_buffers = buffers
          log(('TabScope detected; %d tab-local buffers before duplication'):format(#buffers))
        else
          log('TabScope detected but current tab buffers could not be retrieved; falling back to layout snapshot')
        end
      else
        log('TabScope detected without tab buffer API; falling back to layout snapshot')
      end
    end)

    local function restore_layout(snapshot, win)
      if snapshot.type == 'leaf' then
        local is_terminal = false

        if vim.api.nvim_buf_is_valid(snapshot.buf) then
          local ok_buftype, buftype = pcall(vim.api.nvim_buf_get_option, snapshot.buf, 'buftype')
          if ok_buftype and buftype == 'terminal' then
            is_terminal = true
            local previous_win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_set_current_win(win)
              vim.cmd 'terminal'
            end
            if vim.api.nvim_win_is_valid(previous_win) then
              vim.api.nvim_set_current_win(previous_win)
            end
          else
            pcall(vim.api.nvim_win_set_buf, win, snapshot.buf)
          end
        end

        if not is_terminal then
          if snapshot.cursor then
            pcall(vim.api.nvim_win_set_cursor, win, snapshot.cursor)
          end

          if snapshot.view then
            vim.api.nvim_win_call(win, function()
              vim.fn.winrestview(snapshot.view)
            end)
          end
        end

        return {
          first = win,
          last = win,
          focus = snapshot.focused and win or nil,
        }
      end

      vim.api.nvim_set_current_win(win)

      local split_cmd = snapshot.type == 'row' and 'rightbelow vsplit' or 'belowright split'
      local child_wins = { win }
      local last_created = win
      for index = 2, #snapshot.children do
        vim.api.nvim_set_current_win(last_created)
        vim.cmd(split_cmd)
        last_created = vim.api.nvim_get_current_win()
        child_wins[index] = last_created
      end

      local focus_win
      local last_win = child_wins[#child_wins]
      for index, child in ipairs(snapshot.children) do
        local result = restore_layout(child, child_wins[index])
        if result.focus then
          focus_win = result.focus
        end
        last_win = result.last
      end

      return {
        first = child_wins[1],
        last = last_win,
        focus = focus_win,
      }
    end

    local layout_snapshot = capture_layout(vim.fn.winlayout())
    collect_buffers(layout_snapshot)

    if tabscope_source_buffers == nil then
      tabscope_source_buffers = {}
      for buf, _ in pairs(layout_buffers) do
        table.insert(tabscope_source_buffers, buf)
      end
      log(('TabScope buffer fallback captured %d buffers from layout snapshot'):format(#tabscope_source_buffers))
    end

    vim.cmd 'tabnew'

    local new_tab = vim.api.nvim_get_current_tabpage()
    log(('Created tab %d from source tab %d'):format(new_tab, tabscope_source_tab))

    local restored = restore_layout(layout_snapshot, vim.api.nvim_get_current_win())

    if restored.focus and vim.api.nvim_win_is_valid(restored.focus) then
      vim.api.nvim_set_current_win(restored.focus)
    end

    vim.cmd 'wincmd ='

    with_tabscope(function(ts)
      if not ts.tab_buffers or not ts.tab_buffers.get_current_tab_local_buffers then
        log('TabScope post-duplication sync skipped: tab buffer manager unavailable')
        return
      end

      if ts.tab_buffers._buffers_by_tab == nil then
        log('TabScope post-duplication sync skipped: internal buffer table missing')
        return
      end

      ts.tab_buffers._buffers_by_tab[new_tab] = ts.tab_buffers._buffers_by_tab[new_tab] or {}

      local added = 0
      for _, buf in ipairs(tabscope_source_buffers) do
        if vim.api.nvim_buf_is_valid(buf) then
          ts.tab_buffers._buffers_by_tab[new_tab][buf] = true
          added = added + 1
          if ts.tracked_buffers and ts.tracked_buffers.is_tracked and ts.tracked_buffers.is_tracked(buf) and vim.bo[buf].buflisted ~= true then
            ts.tracked_buffers.show(buf)
          end
        end
      end

      log(('TabScope synchronized %d buffers to tab %d'):format(added, new_tab))

      if ts.listed_buffers and ts.listed_buffers.update then
        ts.listed_buffers.update()
        log('TabScope listed buffer manager updated for duplicated tab')
      end
    end)

    if #log_messages > 0 then
      vim.schedule(function()
        local lines = {}
        for _, message in ipairs(log_messages) do
          table.insert(lines, '• ' .. message)
        end
        vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'Tab duplicate command path' })
      end)
    end
  end

  -- WinShift integration for advanced rearranging
  vim.keymap.set('n', '<leader>wm', function()
    winshift().cmd_winshift()
  end, { desc = '[w]indows WinShift [m]ove mode (q/Esc to exit)' })
  vim.keymap.set('n', '<leader>ws', function()
    if not load_plugin('smart-splits.nvim') then
      return
    end
    local ok, smart_splits = pcall(require, 'smart-splits')
    if not ok then
      return
    end
    smart_splits.start_resize_mode()
  end, { desc = '[w]indow [s]mart resize mode' })
  vim.keymap.set('n', '<leader>wS', function()
    if not load_plugin('smart-splits.nvim') then
      return
    end
    local ok, smart_splits = pcall(require, 'smart-splits')
    if not ok then
      return
    end
    smart_splits.swap_buf_right()
  end, { desc = '[w]indow [S]wap buffer right' })
  -- Split window
  vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = '[w]indows [V]ertical Split' })
  vim.keymap.set('n', '<leader>wh', '<cmd>split<cr>', { desc = '[w]indows [H]orizontal Split' })
  -- Window actions
  vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = '[w]indows Equalize Splits' })
  vim.keymap.set('n', '<leader>wq', '<cmd>q<cr>', { desc = '[w]indows Close Split' })
  vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = '[w]indows Swap Splits' })
  vim.keymap.set('n', '<leader>wr', '<C-w>r', { desc = '[w]indows Rotate Splits' })
  vim.keymap.set('n', '<leader>wO', '<C-w>o', { desc = '[w]indows Close [O]ther Splits' })
  -- Window picker
  vim.keymap.set('n', '<leader>wo', function()
    local picker = lazy_require('window-picker', 'window-picker')
    if not picker then
      return
    end
    local win = picker.pick_window { include_current_win = false }
    if win then
      vim.api.nvim_set_current_win(win)
    end
  end, { desc = '[w]indow pick [o]ther window' })
  vim.keymap.set('n', '<leader>wp', function()
    local picker = lazy_require('window-picker', 'window-picker')
    if not picker then
      return
    end
    local win = picker.pick_window()
    if win then
      vim.api.nvim_set_current_win(win)
    end
  end, { desc = '[w]indow [p]icker' })
  vim.keymap.set('n', '<leader>wP', function()
    winshift().cmd_winshift 'swap'
  end, { desc = '[w]indows WinShift [P]ick other window' })
  --barbar tab navigatio- Buffer navigation
  vim.keymap.set('n', '<Tab>', '<cmd>BufferNext<cr>', { desc = '[t]ab Next' })
  vim.keymap.set('n', '<S-Tab>', '<cmd>BufferPrevious<cr>', { desc = '[t]ab Previous' })
  -- Buffer reordering
  vim.keymap.set('n', '<leader>wbm', '<cmd>BufferMoveNext<cr>', { desc = '[W]indow [B]uffer Move right' })
  vim.keymap.set('n', '<leader>wbM', '<cmd>BufferMovePrevious<cr>', { desc = '[W]indow [B]uffer Move left' })
  -- Buffer pin/unpin
  vim.keymap.set('n', '<leader>wbp', '<cmd>BufferPin<cr>', { desc = '[W]indow [B]uffer [P]in' })
  -- Buffer closing
  vim.keymap.set('n', '<leader>wbq', '<cmd>BufferClose<cr>', { desc = '[W]indow [B]uffer [Q]uit' })
  vim.keymap.set('n', '<leader>wbo', '<cmd>BufferCloseAllButCurrent<cr>', { desc = '[W]indow [B]uffer Close [O]thers' })
  vim.keymap.set('n', '<leader>wbl', '<cmd>BufferCloseBuffersLeft<cr>', { desc = '[W]indow [B]uffer Close Left' })
  vim.keymap.set('n', '<leader>wbr', '<cmd>BufferCloseBuffersRight<cr>', { desc = '[W]indow [B]uffer Close Right' })
  -- Buffer picking
  vim.keymap.set('n', '<leader>wbt', '<cmd>BufferPick<cr>', { desc = '[W]indow [B]uffer Pick (letter select)' })
  -- Buffer ordering (sorting)
  vim.keymap.set('n', '<leader>wbsd', '<cmd>BufferOrderByDirectory<cr>', { desc = '[W]indow [B]uffer [S]ort by [D]irectory' })
  vim.keymap.set('n', '<leader>wbsl', '<cmd>BufferOrderByLanguage<cr>', { desc = '[W]indow [B]uffer [S]ort by [L]anguage' })
  if is_tabscope_available() then
    vim.keymap.set('n', '<leader>wbR', function()
      with_tabscope(function(tabscope)
        tabscope.remove_tab_buffer(vim.api.nvim_get_current_buf())
      end)
    end, { desc = '[W]indow [B]uffer remove from tab-local list (TabScope)' })

    vim.keymap.set('n', '<leader>wbT', function()
      with_tabscope(function()
        if vim.fn.exists(':TabScopeDebug') == 1 then
          vim.cmd.TabScopeDebug()
        end
      end)
    end, { desc = '[W]indow [B]uffer TabScope debug info (TabScope)' })
  end
  -- Create a new tab
  vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<cr>', { desc = '[t]ab [N]ew' })
  -- Close a tab
  vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = '[t]ab [c]lose' })
  -- Soft delete (BufferDelete plugin optional, or close)
  vim.keymap.set('n', '<leader>wbd', '<cmd>bdelete<cr>', { desc = '[W]indow [B]uffer [D]elete' })
  -- Force delete (for when buffers hang)
  vim.keymap.set('n', '<leader>wbD', '<cmd>bdelete!<cr>', { desc = '[W]indow [B]uffer Delete Force' })
  -- Duplicate tab layout while preserving buffers in each window.
  -- The implementation syncs with TabScope so the duplicated tab keeps the same
  -- tab-local buffer set when the plugin is active.
  vim.keymap.set('n', '<leader>tD', duplicate_current_tab, { desc = '[T]ab [D]uplicate layout' })
  --Sessions Saving
  -- Manual session controls
  vim.keymap.set('n', '<leader>ssm', ':SessionSave<space>', { desc = '[s]ession [s]ave [M]anual Save' })
  vim.keymap.set('n', '<leader>ssr', ':AutoSession restore<space>', { desc = '[s]ession AutoSession [R]estore' })
  vim.keymap.set('n', '<leader>ssd', ':SessionDelete<space>', { desc = '[s]ession [s]ave [D]elete' })
  --Theme Switching
  vim.keymap.set('n', '<leader>Ut', function()
    require('custom.utils').switch_colorscheme()
  end, { desc = '[U]I [t]heme Switcher' })
  --TABS

  local function get_softtabstop()
    local tabstop = vim.bo.softtabstop
    if tabstop == 0 then
      tabstop = vim.bo.shiftwidth
    end
    if tabstop == 0 then
      tabstop = vim.bo.tabstop
    end
    return tabstop
  end

  local function handle_tab()
    local ok_cmp, cmp = pcall(require, 'cmp')
    if ok_cmp and cmp.visible() then
      cmp.select_next_item()
      return ''
    end

    local ok_ls, ls = pcall(require, 'luasnip')
    if ok_ls and ls.expand_or_jumpable() then
      ls.expand_or_jump()
      return ''
    end

    return string.rep(' ', get_softtabstop())
  end

  local function handle_s_tab()
    local ok_cmp, cmp = pcall(require, 'cmp')
    if ok_cmp and cmp.visible() then
      cmp.select_prev_item()
      return ''
    end

    local ok_ls, ls = pcall(require, 'luasnip')
    if ok_ls and ls.jumpable(-1) then
      ls.jump(-1)
      return ''
    end

    local col = vim.fn.col '.'
    if col <= 1 then
      return ''
    end

    local line = vim.fn.getline '.'
    local before_cursor = line:sub(1, col - 1)
    local trailing_whitespace = before_cursor:match '(%s+)$'
    if not trailing_whitespace or #trailing_whitespace == 0 then
      return ''
    end

    local spaces_to_remove = math.min(#trailing_whitespace, get_softtabstop())
    return string.rep('<BS>', spaces_to_remove)
  end

  -- Super Tab behaviour in insert/select mode
  vim.keymap.set({ 'i', 's' }, '<Tab>', handle_tab, { expr = true, desc = 'Completion-aware Tab' })
  vim.keymap.set({ 'i', 's' }, '<S-Tab>', handle_s_tab, { expr = true, desc = 'Completion-aware reverse Tab' })
  -- LuaSnip jump forward
  vim.keymap.set({ 'i', 's' }, '<C-j>', function()
    local ls = require 'luasnip'
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { desc = 'LuaSnip jump forward' })
  -- LuaSnip jump backward
  vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    local ls = require 'luasnip'
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { desc = 'LuaSnip jump backward' })
  vim.keymap.set('n', '<leader>dd', function()
    Snacks.dashboard()
  end, { desc = '[D]ashboard [D]isplay snacks' })
  -- GIT and git diff
  vim.keymap.set('n', '<leader>Gn', function()
    require('lazy').load { plugins = { 'neogit' } }
    require('neogit').open()
  end, { desc = '[G]IT [n]eogit' })
  vim.keymap.set('n', '<leader>Gd', function()
    require('lazy').load { plugins = { 'diffview.nvim' } }
    require('diffview').open()
  end, { desc = '[G]IT [d]iffview' })
  vim.keymap.set('n', '<leader>GD', function()
    require('lazy').load { plugins = { 'mini.diff' } }
    require('mini.diff').open()
  end, { desc = '[G]IT [D]iff Overlay' })
  local function hop_map(lhs, action, desc, modes)
    vim.keymap.set(modes or { 'n', 'x', 'o' }, lhs, function()
      local hop = lazy_require('hop', 'hop.nvim')
      if not hop then
        return
      end
      action(hop)
    end, { desc = desc })
  end

  -- HOP - EasyMotion-style navigation
  hop_map('<leader>hh', function(hop)
    hop.hint_char2()
  end, '[h]op 2-[h]aracters')

  hop_map('<leader>hw', function(hop)
    hop.hint_words()
  end, '[h]op [w]ords')

  hop_map('<leader>hl', function(hop)
    hop.hint_lines_skip_whitespace()
  end, '[h]op [l]ines')

  hop_map('<leader>hc', function(hop)
    hop.hint_char1()
  end, '[h]op [c]har 1')

  hop_map('<leader>hC', function(hop)
    hop.hint_char2()
  end, '[h]op [C]har 2')

  hop_map('<leader>hW', function(hop)
    hop.hint_words { multi_windows = true }
  end, '[h]op [w]ords (all windows)', 'n')

  hop_map('<leader>hL', function(hop)
    hop.hint_lines { multi_windows = true }
  end, '[h]op [L]ines (all windows)', 'n')

  hop_map('<leader>hp', function(hop)
    hop.hint_patterns()
  end, '[h]op to [p]attern', 'n')

  hop_map('<leader>hW', function(hop)
    hop.hint_words()
  end, '[h]op [W]ords (visual)', 'v')

  vim.keymap.set('n', '<leader>hy', function()
    local hop = lazy_require('hop', 'hop.nvim')
    if not hop then
      return
    end
    hop.hint_words {
      callback = function(node)
        vim.api.nvim_win_set_cursor(0, { node.line + 1, node.column })
        vim.cmd 'normal! yw'
      end,
    }
  end, { desc = '[h]op [y]ank word' })
  -- Debugging
  vim.keymap.set('n', '<F5>', function()
    require('dap').continue()
  end, { desc = 'Start/Continue Debugging' })
  vim.keymap.set('n', '<F10>', function()
    require('dap').step_over()
  end, { desc = 'Step Over' })
  vim.keymap.set('n', '<F11>', function()
    require('dap').step_into()
  end, { desc = 'Step Into' })
  vim.keymap.set('n', '<F12>', function()
    require('dap').step_out()
  end, { desc = 'Step Out' })
  vim.keymap.set('n', '<leader>cdb', function()
    require('dap').toggle_breakpoint()
  end, { desc = '[C]ode [D]ebug Toggle [B]reakpoint' })
  vim.keymap.set('n', '<leader>cdr', function()
    require('dap').repl.open()
  end, { desc = '[C]ode [D]ebug [R]EPL' })
  -- vim lspsaga hover documentation
  -- Hover documentation
  vim.keymap.set('n', 'K', function()
    vim.cmd 'Lspsaga hover_doc'
  end, { desc = 'Show Hover Doc' })
  -- Overseer keybinds under <leader>o
  local function run_overseer_command(command)
    if not load_plugin('overseer.nvim') then
      return
    end
    local ok, err = pcall(vim.cmd, command)
    if not ok then
      vim.notify(('Overseer command failed: %s'):format(err), vim.log.levels.ERROR)
    end
  end

  vim.keymap.set('n', '<leader>op', function()
    run_overseer_command 'OverseerTaskAction'
  end, { desc = '[O]verseer task [p]icker' })
  vim.keymap.set('n', '<leader>or', function()
    run_overseer_command 'OverseerRun'
  end, { desc = '[O]verseer [r]un template' })
  vim.keymap.set('n', '<leader>oR', function()
    run_overseer_command 'OverseerQuickAction restart'
  end, { desc = '[O]verseer [R]estart last task' })
  vim.keymap.set('n', '<leader>ot', function()
    run_overseer_command 'OverseerToggle'
  end, { desc = '[O]verseer [t]oggle list' })
  vim.keymap.set('n', '<leader>oa', function()
    run_overseer_command 'OverseerQuickAction'
  end, { desc = '[O]verseer [a]ction (quick menu)' })
  vim.keymap.set('n', '<leader>oc', function()
    run_overseer_command 'OverseerClearCache'
  end, { desc = '[O]verseer [c]lear cache' })
  vim.keymap.set('n', '<leader>os', function()
    run_overseer_command 'OverseerSaveBundle'
  end, { desc = '[O]verseer [s]ave task bundle' })
  vim.keymap.set('n', '<leader>ol', function()
    run_overseer_command 'OverseerLoadBundle'
  end, { desc = '[O]verseer [l]oad task bundle' })
  vim.keymap.set('n', '<leader>od', function()
    run_overseer_command 'OverseerDeleteBundle'
  end, { desc = '[O]verseer [d]elete task bundle' })
  vim.keymap.set('n', '<leader>oq', function()
    local overseer = lazy_require('overseer', 'overseer.nvim')
    if not overseer then
      return
    end
    overseer.open { enter = true, direction = 'bottom' }
  end, { desc = '[O]verseer [q]uickfix focus list' })
  vim.keymap.set('n', '<leader>ob', function()
    run_overseer_command 'OverseerBuild'
  end, { desc = '[O]verseer [b]uild tasks' })
  --Telescope file browser
  vim.keymap.set('n', '<space>sb', ':Telescope file_browser path=%":p:h select_buffer=true<CR>', { desc = '[S]earch file [B]rowser' })
  -- Nvim Spectre

  local function spectre()
    require('lazy').load { plugins = { 'nvim-spectre' } }
    return require 'spectre'
  end

  vim.keymap.set('n', '<leader>srs', function()
    spectre().toggle()
  end, { desc = '[s]earch [r]eplace [s]pectre' })
  vim.keymap.set('n', '<leader>srw', function()
    spectre().open_visual { select_word = true }
  end, { desc = '[s]earch [r]eplace Spectre visual under [w]ord' })
  vim.keymap.set('v', '<leader>srv', function()
    spectre().open_visual()
  end, { desc = '[s]earch [r]eplace Spectre [v]isual' })
  vim.keymap.set('n', '<leader>src', function()
    spectre().open_file_search()
  end, { desc = '[s]earch [r]eplace Spectre [c]urrent File' })

  -- Helper to run a command in Overseer if present, else a terminal split
  local function run_build_cmd(cmd, title)
    local exe = cmd[1]
    local args = vim.list_slice(cmd, 2)
    local cwd = vim.loop.cwd()

    local ok, overseer = pcall(require, 'overseer')
    if ok then
      local task = overseer.new_task {
        name = title or table.concat(cmd, ' '),
        cmd = exe,
        args = args,
        cwd = cwd,
        components = {
          { 'on_output_quickfix', open = false },
          'default',
        },
      }
      task:start()
      overseer.open { enter = false, direction = 'bottom' }
    else
      -- Fallback terminal on systems without Overseer
      vim.cmd(('botright split | resize 12 | terminal %s %s'):format(exe, table.concat(args, ' ')))
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'zig',
    callback = function(ev)
      local buf = ev.buf
      register_buffer_groups(buf, {
        { '<leader>cz', group = '[C]ode [Z]ig', mode = 'n' },
      })

      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
      end

      map('<leader>cz', '<Nop>', '[C]ode [Z]ig')
      map('<leader>czb', function()
        run_build_cmd({ 'zig', 'build' }, 'Zig: build')
      end, '[C]ode [Z]ig [B]uild')

      map('<leader>czr', function()
        run_build_cmd({ 'zig', 'build', 'run' }, 'Zig: run')
      end, '[C]ode [Z]ig [R]un')

      map('<leader>czt', function()
        vim.cmd 'write'
        run_build_cmd({ 'zig', 'test', vim.fn.expand '%:p' }, 'Zig: test file')
      end, '[C]ode [Z]ig [T]est file')

      map('<leader>czR', function()
        vim.cmd 'write'
        run_build_cmd({ 'zig', 'run', vim.fn.expand '%:p' }, 'Zig: run current file')
      end, '[C]ode [Z]ig Run cu[R]rent file')

      map('<leader>czf', function()
        require('conform').format { lsp_format = 'fallback' }
      end, '[C]ode [Z]ig [F]ormat')

      map('<leader>czd', function()
        require('dap').continue()
      end, '[C]ode [Z]ig [D]ebug (continue)')

      map('<leader>czi', function()
        local ok = pcall(vim.lsp.inlay_hint, buf, nil)
        if not ok then
          local enabled = vim.b.zig_inlay_hints_enabled or false
          vim.b.zig_inlay_hints_enabled = not enabled
          vim.lsp.inlay_hint(buf, vim.b.zig_inlay_hints_enabled)
        end
      end, '[C]ode [Z]ig [I]nlay hints toggle')
    end,
  })

  -- =========================
  -- [Code AHK] keymaps
  -- =========================

  -- Resolve AHK paths from your single source module if present, with sane fallbacks
  local function ahk_paths()
    local p = {}
    local ok, mod = pcall(require, 'custom.ahk2')
    if ok and mod.paths then
      p.ahk_exe = mod.paths.ahk_exe
    end
    p.ahk_exe = p.ahk_exe or (vim.g.ahk2_exe or [[C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe]])
    p.compiler = vim.g.ahk2_compiler or [[C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe]]
    return p
  end

  local function ahk_install_dir(p)
    p = p or ahk_paths()
    local exe = p.ahk_exe
    if not exe or exe == '' then
      return nil
    end
    return exe:match '^(.*)[/\\][^/\\]-$'
  end

  local function window_spy_path(p)
    local dir = ahk_install_dir(p)
    if not dir or dir == '' then
      return nil
    end
    local candidates = {
      dir .. '\\WindowSpy.ahk',
      dir .. '\\UX\\WindowSpy.ahk',
    }
    for _, path in ipairs(candidates) do
      if vim.loop.fs_stat(path) then
        return path
      end
    end
    return nil
  end

  local function ahk_help_chm(p)
    local dir = ahk_install_dir(p)
    if not dir or dir == '' then
      return nil
    end
    local path = dir .. '\\AutoHotkey.chm'
    if vim.loop.fs_stat(path) then
      return path
    end
    return nil
  end

  -- Small helpers
  local function curfile()
    return vim.fn.expand '%:p'
  end
  local function curdir()
    return vim.fn.expand '%:p:h'
  end
  local function curbasename()
    return vim.fn.expand '%:t:r'
  end

  local function parse_ahk_args(input)
    if not input or input == '' then
      return {}
    end
    local args, current = {}, {}
    local in_single, in_double = false, false
    local i = 1
    while i <= #input do
      local c = input:sub(i, i)
      if c == '"' and not in_single then
        in_double = not in_double
      elseif c == "'" and not in_double then
        in_single = not in_single
      elseif c == '\\' and not in_single then
        i = i + 1
        if i > #input then
          table.insert(current, '\\')
          break
        end
        table.insert(current, input:sub(i, i))
      elseif c:match '%s' and not in_single and not in_double then
        if #current > 0 then
          table.insert(args, table.concat(current))
          current = {}
        end
      else
        table.insert(current, c)
      end
      i = i + 1
    end
    if in_single or in_double then
      return nil, 'Unbalanced quotes in arguments'
    end
    if #current > 0 then
      table.insert(args, table.concat(current))
    end
    return args
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'autohotkey', 'ahk', 'ahk2' },
    callback = function(ev)
      local buf = ev.buf
      register_buffer_groups(buf, {
        { '<leader>ch', group = '[C]ode a[h]k', mode = 'n' },
      })

      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
      end

      map('<leader>ch', '<Nop>', '[C]ode a[h]k')

      map('<leader>chr', function()
        vim.cmd.write()
        local p = ahk_paths()
        run_build_cmd({ p.ahk_exe, curfile() }, 'AHK: run current')
      end, '[C]ode a[h]k [R]un current')

      map('<leader>chR', function()
        vim.cmd.write()
        local p = ahk_paths()
        if not p.ahk_exe or p.ahk_exe == '' then
          vim.notify('AutoHotkey executable not configured', vim.log.levels.WARN)
          return
        end
        if vim.fn.executable(p.ahk_exe) ~= 1 and not vim.loop.fs_stat(p.ahk_exe) then
          vim.notify('AutoHotkey executable not found: ' .. p.ahk_exe, vim.log.levels.WARN)
          return
        end
        local script = curfile()
        if script == '' then
          vim.notify('No file associated with this buffer', vim.log.levels.WARN)
          return
        end
        vim.ui.input({ prompt = 'Script arguments: ' }, function(input)
          if input == nil then
            return
          end
          local extra_args, err = parse_ahk_args(input)
          if err then
            vim.notify(err, vim.log.levels.WARN)
            return
          end
          local cmd = { p.ahk_exe, script }
          if extra_args and #extra_args > 0 then
            vim.list_extend(cmd, extra_args)
          end
          run_build_cmd(cmd, 'AHK: run with args')
        end)
      end, '[C]ode a[h]k Run with a[R]gs')

      map('<leader>ch?', function()
        local symbol = vim.fn.expand '<cword>'
        if symbol == nil or symbol == '' then
          vim.notify('No symbol under cursor to look up', vim.log.levels.WARN)
          return
        end
        local url = ('https://www.autohotkey.com/docs/v2/lib/%s.htm'):format(symbol)
        run_build_cmd({ 'cmd.exe', '/C', 'start', '""', url }, 'AHK: docs lookup')
      end, '[C]ode a[h]k [?] Docs for symbol')

      map('<leader>che', function()
        vim.cmd.write()
        local p = ahk_paths()
        run_build_cmd({ p.ahk_exe, '/ErrorStdOut', curfile() }, 'AHK: run (stderr)')
      end, '[C]ode a[h]k Run with [E]rrors (/ErrorStdOut)')

      map('<leader>chA', function()
        vim.cmd.write()
        local p = ahk_paths()
        local ps = ([[Start-Process -Verb RunAs -FilePath "%s" -ArgumentList "%s"]]):format(p.ahk_exe, curfile())
        run_build_cmd({ 'powershell', '-NoProfile', '-Command', ps }, 'AHK: run as admin')
      end, '[C]ode a[h]k Run as [A]dmin')

      map('<leader>chw', function()
        vim.cmd.write()
        local p = ahk_paths()
        local spy = window_spy_path(p)
        if not spy or spy == '' then
          vim.notify('Unable to locate WindowSpy.ahk from AutoHotkey installation', vim.log.levels.ERROR)
          return
        end
        run_build_cmd({ p.ahk_exe, spy }, 'AHK: Window Spy')
      end, '[C]ode a[h]k [W]indow Spy')

      map('<leader>chH', function()
        local p = ahk_paths()
        local help_path = ahk_help_chm(p)
        if not help_path or help_path == '' then
          vim.notify('Unable to locate AutoHotkey.chm from AutoHotkey installation', vim.log.levels.ERROR)
          return
        end
        run_build_cmd({ 'cmd.exe', '/C', 'start', '""', help_path }, 'AHK: help (CHM)')
      end, '[C]ode a[h]k [H]elp (CHM)')

      map('<leader>chc', function()
        vim.cmd.write()
        local p = ahk_paths()
        local infile = curfile()
        local outdir = curdir() .. '\\bin'
        local outfile = outdir .. '\\' .. curbasename() .. '.exe'
        local icon = curdir() .. '\\' .. curbasename() .. '.ico'

        if vim.fn.isdirectory(outdir) == 0 then
          vim.fn.mkdir(outdir, 'p')
        end

        local args = { '/in', infile, '/out', outfile }
        if vim.loop.fs_stat(icon) then
          table.insert(args, '/icon')
          table.insert(args, icon)
        end

        local cmd = vim.list_extend({ p.compiler }, args)
        run_build_cmd(cmd, 'AHK: compile to exe')
      end, '[C]ode a[h]k [C]ompile to exe')

      map('<leader>chk', function()
        run_build_cmd({ 'taskkill', '/F', '/IM', 'AutoHotkey64.exe' }, 'AHK: kill all v2 processes')
      end, '[C]ode a[h]k [K]ill all AutoHotkey v2')

      map('<leader>cho', function()
        run_build_cmd({ 'explorer.exe', '/select,' .. curfile() }, 'AHK: open in Explorer')
      end, '[C]ode a[h]k [O]pen in Explorer')
    end,
  })

  -- =========================
  -- Utility
  -- =========================

  -- <leader>E → Reveal current file in Explorer (selected)
  vim.keymap.set('n', '<leader>E', function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == '' then
      vim.notify('No file associated with this buffer', vim.log.levels.WARN)
      return
    end

    -- Normalize to backslashes for Explorer
    file = file:gsub('/', '\\')

    -- Use cmd's `start` so Explorer honors /select and returns immediately
    local arg = '/select,"' .. file .. '"'
    vim.fn.jobstart({ 'cmd.exe', '/C', 'start', '', 'explorer.exe', arg }, { detach = true })
  end, { desc = '[Explorer] Reveal current file' })

  -- <leader>p  → Copy current buffer's full path to clipboard
  vim.keymap.set('n', '<leader>p', function()
    local file = vim.fn.expand '%:p'
    if file == '' then
      vim.notify('No file associated with this buffer', vim.log.levels.WARN)
      return
    end
    vim.fn.setreg('+', file) -- system clipboard
    vim.fn.setreg('"', file) -- default register (nice for immediate paste)
    vim.notify('Copied path: ' .. file)
  end, { desc = '[Path] Copy full path' })

end

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    M.setup()
  end,
})

return setmetatable({}, { __index = M })


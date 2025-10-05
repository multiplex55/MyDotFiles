local M = {}

local did_setup = false

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  local rhai_utils = require 'custom.lang.rhai'

  local function register_buffer_groups(buf, spec)
    local ok, wk = pcall(require, 'which-key')
    if not ok then
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

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'nim',
    callback = function(ev)
      local buf = ev.buf
      register_buffer_groups(buf, {
        { '<leader>n', group = '[N]im', mode = 'n' },
      })

      vim.keymap.set('n', '<leader>npr', function()
        local dir_path = vim.fn.expand '%:p:h'
        local filename_no_ext = vim.fn.expand '%:t:r'
        local full_path_with_ext = vim.fn.expand '%:p'

        local cmd = string.format(':tabnew | term nim cpp -d:release -r --out:"%s\\bin\\%s" "%s"', dir_path, filename_no_ext, full_path_with_ext)
        vim.cmd(cmd)
      end, { buffer = buf, desc = '[n]im c[p]p [r]un release' })
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

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'rhai',
    callback = function(ev)
      local buf = ev.buf

      vim.keymap.set('n', '<leader>cRf', function()
        rhai_utils.format_buffer(buf)
      end, { buffer = buf, desc = '[C]ode [R]hai [F]ormat buffer' })

      vim.keymap.set('n', '<leader>cRF', function()
        if not rhai_utils.rhai_executable() then
          return
        end
        local args = { 'fmt' }
        local root = rhai_utils.get_root(vim.api.nvim_buf_get_name(buf))
        if not rhai_utils.run_overseer('rhai', args, root) then
          rhai_utils.term_run('rhai', args, root)
        end
      end, { buffer = buf, desc = '[C]ode [R]hai [F]ormat workspace' })

      vim.keymap.set('n', '<leader>cRc', function()
        if not rhai_utils.rhai_executable() then
          return
        end
        local args = { 'fmt', '--check' }
        local root = rhai_utils.get_root(vim.api.nvim_buf_get_name(buf))
        if not rhai_utils.run_overseer('rhai', args, root) then
          rhai_utils.term_run('rhai', args, root)
        end
      end, { buffer = buf, desc = '[C]ode [R]hai [C]heck formatting' })

      vim.keymap.set('n', '<leader>cRr', function()
        if not rhai_utils.rhai_executable() then
          return
        end
        local file = rhai_utils.ensure_rhai_file(buf)
        if not file then
          return
        end
        vim.cmd.write()
        local args = { 'run', file }
        local root = rhai_utils.get_root(file)
        if not rhai_utils.run_overseer('rhai', args, root) then
          rhai_utils.term_run('rhai', args, root)
        end
      end, { buffer = buf, desc = '[C]ode [R]hai [R]un file' })

      vim.keymap.set('n', '<leader>cRR', function()
        if not rhai_utils.rhai_executable() then
          return
        end
        local file = rhai_utils.ensure_rhai_file(buf)
        if not file then
          return
        end
        vim.cmd.write()
        local root = rhai_utils.get_root(file)
        vim.ui.input({ prompt = 'Extra rhai args: ' }, function(input)
          if input == nil then
            return
          end
          local args = { 'run', file }
          if input ~= '' then
            local extra = vim.split(input, '%s+', { trimempty = true })
            if #extra > 0 then
              vim.list_extend(args, extra)
            end
          end
          if not rhai_utils.run_overseer('rhai', args, root) then
            rhai_utils.term_run('rhai', args, root)
          end
        end)
      end, { buffer = buf, desc = '[C]ode [R]hai Run with ext[R]a args' })

      vim.keymap.set('n', '<leader>cRt', function()
        if not rhai_utils.rhai_executable() then
          return
        end
        local file = vim.api.nvim_buf_get_name(buf)
        local root = rhai_utils.get_root(file)
        if not rhai_utils.run_overseer('rhai', nil, root) then
          rhai_utils.term_run('rhai', nil, root)
        end
      end, { buffer = buf, desc = '[C]ode [R]hai [T]erminal REPL' })

      vim.keymap.set('n', '<leader>cRh', vim.lsp.buf.hover, { buffer = buf, desc = '[C]ode [R]hai [H]over' })
      vim.keymap.set('n', '<leader>cRg', vim.lsp.buf.definition, { buffer = buf, desc = '[C]ode [R]hai [G]oto def' })
      vim.keymap.set('n', '<leader>cRn', vim.lsp.buf.rename, { buffer = buf, desc = '[C]ode [R]hai Re[n]ame' })
      vim.keymap.set({ 'n', 'x' }, '<leader>cRa', vim.lsp.buf.code_action, {
        buffer = buf,
        desc = '[C]ode [R]hai Code [A]ction',
      })
    end,
  })
  vim.keymap.set('n', '<leader>ct', '<Nop>', { desc = '[C]ode [T]est' })
  vim.keymap.set('n', '<leader>ctn', function()
    require('neotest').run.run()
  end, { desc = '[C]ode [T]est [N]earest' })
  vim.keymap.set('n', '<leader>ctf', function()
    require('neotest').run.run(vim.fn.expand '%')
  end, { desc = '[C]ode [T]est Current [F]ile' })
  vim.keymap.set('n', '<leader>ctu', function()
    require('neotest').run.run { suite = true }
  end, { desc = '[C]ode [T]est R[U]n suite' })
  vim.keymap.set('n', '<leader>ctw', function()
    require('neotest').watch.toggle(vim.fn.expand '%')
  end, { desc = '[C]ode [T]est [W]atch file toggle' })
  vim.keymap.set('n', '<leader>ctd', function()
    require('neotest').run.run { strategy = 'dap' }
  end, { desc = '[C]ode [T]est [D]ebug via DAP' })
  vim.keymap.set('n', '<leader>cts', function()
    require('neotest').summary.toggle()
  end, { desc = '[C]ode [T]est [S]ummary toggle' })
  vim.keymap.set('n', '<leader>ctl', function()
    require('neotest').run.run_last()
  end, { desc = '[C]ode [T]est Run [L]ast' })
  vim.keymap.set('n', '<leader>ctD', function()
    require('neotest').run.run_last { strategy = 'dap' }
  end, { desc = '[C]ode [T]est Run last ([D]AP)' })
  vim.keymap.set('n', '<leader>ctS', function()
    require('neotest').run.stop()
  end, { desc = '[C]ode [T]est [S]top' })
  vim.keymap.set('n', '<leader>cta', function()
    require('neotest').run.attach()
  end, { desc = '[C]ode [T]est [A]ttach to nearest' })
  vim.keymap.set('n', '<leader>cto', function()
    require('neotest').output.open { enter = true }
  end, { desc = '[C]ode [T]est [O]utput float' })
  vim.keymap.set('n', '<leader>ctL', function()
    require('neotest').output.open { enter = false, last_run = true }
  end, { desc = '[C]ode [T]est Last output (no focus)' })
  vim.keymap.set('n', '<leader>ctp', function()
    require('neotest').output_panel.toggle()
  end, { desc = '[C]ode [T]est [P]anel toggle' })
  vim.keymap.set('n', '<leader>ctj', function()
    require('neotest').jump.next { status = 'failed' }
  end, { desc = '[C]ode [T]est [J]ump to next fail' })
  vim.keymap.set('n', '<leader>ctk', function()
    require('neotest').jump.prev { status = 'failed' }
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
  local function smart_splits()
    require('lazy').load { plugins = { 'smart-splits.nvim' } }
    return require 'smart-splits'
  end

  local function winshift()
    require('lazy').load { plugins = { 'winshift.nvim' } }
    return require 'winshift'
  end

  -- WinShift integration for advanced rearranging
  vim.keymap.set('n', '<leader>wm', function()
    winshift().cmd_winshift()
  end, { desc = '[w]indows WinShift [m]ove mode (q/Esc to exit)' })
  -- Split window
  vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = '[w]indows [V]ertical Split' })
  vim.keymap.set('n', '<leader>wb', '<cmd>split<cr>', { desc = '[w]indows Horizontal Split' })
  -- Window actions
  vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = '[w]indows Equalize Splits' })
  vim.keymap.set('n', '<leader>wq', '<cmd>q<cr>', { desc = '[w]indows Close Split' })
  vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = '[w]indows Swap Splits' })
  vim.keymap.set('n', '<leader>wr', '<C-w>r', { desc = '[w]indows Rotate Splits' })
  vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = '[w]indows Close Other Splits' })
  --window picker
  vim.keymap.set('n', '<leader>wp', function()
    local picked = require('window-picker').pick_window()
    if picked then
      vim.api.nvim_set_current_win(picked)
    end
  end, { desc = '[w]indow [p]icker' })
  vim.keymap.set('n', '<leader>wP', function()
    winshift().cmd_winshift 'swap'
  end, { desc = '[w]indows WinShift [P]ick other window' })
  --barbar tab navigatio- Buffer navigation
  vim.keymap.set('n', '<Tab>', '<cmd>BufferNext<cr>', { desc = '[t]ab Next' })
  vim.keymap.set('n', '<S-Tab>', '<cmd>BufferPrevious<cr>', { desc = '[t]ab Previous' })
  -- Buffer reordering
  vim.keymap.set('n', '<leader>tm', '<cmd>BufferMoveNext<cr>', { desc = '[t]ab Move right' })
  vim.keymap.set('n', '<leader>tM', '<cmd>BufferMovePrevious<cr>', { desc = '[t]ab Move left' })
  -- Buffer pin/unpin
  vim.keymap.set('n', '<leader>tp', '<cmd>BufferPin<cr>', { desc = '[t]ab [P]in' })
  -- Buffer closing
  vim.keymap.set('n', '<leader>tq', '<cmd>BufferClose<cr>', { desc = '[t]ab [Q]uit' })
  vim.keymap.set('n', '<leader>to', '<cmd>BufferCloseAllButCurrent<cr>', { desc = '[t]ab Close [O]thers' })
  vim.keymap.set('n', '<leader>tl', '<cmd>BufferCloseBuffersLeft<cr>', { desc = '[t]ab Close Left' })
  vim.keymap.set('n', '<leader>tr', '<cmd>BufferCloseBuffersRight<cr>', { desc = '[t]ab Close Right' })
  -- Buffer picking
  vim.keymap.set('n', '<leader>tt', '<cmd>BufferPick<cr>', { desc = '[t]ab Pick (letter select)' })
  -- Buffer ordering (sorting)
  vim.keymap.set('n', '<leader>tsd', '<cmd>BufferOrderByDirectory<cr>', { desc = '[t]ab Sort by [D]irectory' })
  vim.keymap.set('n', '<leader>tsl', '<cmd>BufferOrderByLanguage<cr>', { desc = '[t]ab Sort by [L]anguage' })
  -- Create a new tab
  vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<cr>', { desc = '[t]ab [N]ew' })
  -- Close a tab
  vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = '[t]ab [c]lose' })
  -- Soft delete (BufferDelete plugin optional, or close)
  vim.keymap.set('n', '<leader>td', '<cmd>bdelete<cr>', { desc = '[t]ab [D]elete Buffer' })
  -- Force delete (for when buffers hang)
  vim.keymap.set('n', '<leader>tD', '<cmd>bdelete!<cr>', { desc = '[t]ab [D]elete Force' })
  --Sessions Saving
  -- Manual session controls
  vim.keymap.set('n', '<leader>ssm', ':SessionSave<space>', { desc = '[s]ession [s]ave [M]anual Save' })
  vim.keymap.set('n', '<leader>ssr', ':SessionRestore<space>', { desc = '[s]ession [s]ave [R]estore' })
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
    require('neogit').open()
  end, { desc = '[G]IT [n]eogit' })
  vim.keymap.set('n', '<leader>Gd', function()
    require('diffview').open()
  end, { desc = '[G]IT [d]iffview' })
  vim.keymap.set('n', '<leader>GD', function()
    require('mini.diff').open()
  end, { desc = '[G]IT [D]iff Overlay' })
  -- HOP - EasyMotion-style navigation
  vim.keymap.set('n', '<leader>hw', function()
    require('hop').hint_words()
  end, { desc = '[h]op [w]ords' })
  vim.keymap.set('n', '<leader>hl', function()
    require('hop').hint_lines()
  end, { desc = '[h]op [l]ines' })
  vim.keymap.set('n', '<leader>hc', function()
    require('hop').hint_char1()
  end, { desc = '[h]op [c]har 1' })
  vim.keymap.set('n', '<leader>hC', function()
    require('hop').hint_char2()
  end, { desc = '[h]op [C]har 2' })
  -- Hop to word across all windows
  vim.keymap.set('n', '<leader>hW', function()
    require('hop').hint_words { multi_windows = true }
  end, { desc = '[h]op [w]ords (all windows)' })
  -- Hop to line across all windows
  vim.keymap.set('n', '<leader>hL', function()
    require('hop').hint_lines { multi_windows = true }
  end, { desc = '[h]op [L]ines (all windows)' })
  -- Hop to pattern (search-like)
  vim.keymap.set('n', '<leader>hp', function()
    require('hop').hint_patterns()
  end, { desc = '[h]op to [p]attern' })
  -- Visual mode: Hop to word
  vim.keymap.set('v', '<leader>hW', function()
    require('hop').hint_words()
  end, { desc = '[h]op [W]ords (visual)' })
  -- Yank after hopping to word (insert-mode like behavior)
  vim.keymap.set('n', '<leader>hy', function()
    local hop = require 'hop'
    hop.hint_words {
      callback = function(node)
        vim.api.nvim_win_set_cursor(0, { node.line + 1, node.column })
        vim.cmd 'normal! yw'
      end,
    }
  end, { desc = '[h]op [Y]ank word' })
  vim.keymap.set('n', '<leader>hh', function()
    require('hop').hint_anywhere()
  end, { desc = '[h]op Anyw[h]ere (visual)' })
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
  vim.keymap.set('n', '<leader>oo', '<cmd>OverseerToggle<cr>', { desc = '[O]verseer [O]pen Task List' })
  vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<cr>', { desc = '[O]verseer [R]un Task' })
  vim.keymap.set('n', '<leader>ot', '<cmd>OverseerTaskAction<cr>', { desc = '[O]verseer Task Ac[t]ion' })
  vim.keymap.set('n', '<leader>oa', '<cmd>OverseerQuickAction<cr>', { desc = '[O]verseer [A]ction (Quick)' })
  vim.keymap.set('n', '<leader>oc', '<cmd>OverseerClearCache<cr>', { desc = '[O]verseer [C]lear Cache' })
  vim.keymap.set('n', '<leader>os', '<cmd>OverseerSaveBundle<cr>', { desc = '[O]verseer [S]ave Task Bundle' })
  vim.keymap.set('n', '<leader>ol', '<cmd>OverseerLoadBundle<cr>', { desc = '[O]verseer [L]oad Task Bundle' })
  vim.keymap.set('n', '<leader>od', '<cmd>OverseerDeleteBundle<cr>', { desc = '[O]verseer [D]elete Task Bundle' })
  vim.keymap.set('n', '<leader>oq', function()
    require('lazy').load { plugins = { 'overseer.nvim' } }
    require('overseer').open { enter = true, direction = 'bottom' }
  end, { desc = '[O]verseer [Q]uickfix focus list' })
  vim.keymap.set('n', '<leader>ob', '<cmd>OverseerBuild<cr>', { desc = '[O]verseer [B]uild Tasks' })
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


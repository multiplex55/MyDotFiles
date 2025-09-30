return (function()
  -- NIM
  vim.keymap.set('n', '<leader>npr', function()
    local dir_path = vim.fn.expand '%:p:h'
    local filename_no_ext = vim.fn.expand '%:t:r'
    local full_path_with_ext = vim.fn.expand '%:p'

    local cmd = string.format(':tabnew | term nim cpp -d:release -r --out:"%s\\bin\\%s" "%s"', dir_path, filename_no_ext, full_path_with_ext)
    vim.cmd(cmd)
  end, {
    desc = '[n]im c[p]p [r]un release',
  })
  -- Rust-focused cargo utilities under <leader>cc
  vim.keymap.set('n', '<leader>cc', '<Nop>', { desc = '[C]ode [C]argo' })
  vim.keymap.set('n', '<leader>ccc', '<cmd>tabnew | term cargo clean<cr>', { desc = '[C]ode [C]argo [C]lean' })
  vim.keymap.set('n', '<leader>ccd', '<cmd>tabnew | term cargo doc --open<cr>', { desc = '[C]ode [C]argo [D]oc open' })
  vim.keymap.set('n', '<leader>ccu', '<cmd>tabnew | term cargo update<cr>', { desc = '[C]ode [C]argo [U]pdate deps' })
  vim.keymap.set('n', '<leader>ccf', '<cmd>tabnew | term cargo fmt<cr>', { desc = '[C]ode [C]argo [F]ormat code' })
  -- Rust execution, testing, and linting under <leader>cr
  vim.keymap.set('n', '<leader>cr', '<Nop>', { desc = '[C]ode [R]ust' })
  vim.keymap.set('n', '<leader>crr', '<cmd>tabnew | term cargo run<cr>', { desc = '[C]ode [R]ust [R]un' })
  vim.keymap.set('n', '<leader>crR', '<cmd>tabnew | term cargo run --release<cr>', { desc = '[C]ode [R]ust Run --[R]elease' })
  vim.keymap.set('n', '<leader>crb', '<cmd>tabnew | term cargo build<cr>', { desc = '[C]ode [R]ust [B]uild' })
  vim.keymap.set('n', '<leader>crB', '<cmd>tabnew | term cargo build --release<cr>', { desc = '[C]ode [R]ust Build --[R]elease' })
  vim.keymap.set('n', '<leader>crT', '<cmd>tabnew | term cargo test<cr>', { desc = '[C]ode [R]ust [T]est suite' })
  vim.keymap.set('n', '<leader>crt', '<cmd>tabnew | term cargo nextest run --no-capture --test-threads=1<cr>', { desc = '[C]ode [R]ust [T]est' })
  vim.keymap.set('n', '<leader>crc', '<cmd>tabnew | term cargo check<cr>', { desc = '[C]ode [R]ust [C]heck' })
  vim.keymap.set('n', '<leader>crl', '<cmd>tabnew | term cargo clippy<cr>', { desc = '[C]ode [R]ust C[L]ippy lint' })
  vim.keymap.set('n', '<leader>crd', function()
    vim.cmd.RustDocstring()
  end, { desc = '[C]ode [R]ust [D]ocstring current item' })
  vim.keymap.set('n', '<leader>crD', function()
    vim.cmd.RustDocstringAllKinds()
  end, { desc = '[C]ode [R]ust [D]ocstring all kinds' })
  vim.keymap.set('n', '<leader>ct', '<Nop>', { desc = '[C]ode [T]est' })
  vim.keymap.set('n', '<leader>ctn', function()
    require('neotest').run.run()
  end, { desc = '[C]ode [T]est [N]earest' })
  vim.keymap.set('n', '<leader>ctf', function()
    require('neotest').run.run(vim.fn.expand '%')
  end, { desc = '[C]ode [T]est Current [F]ile' })
  vim.keymap.set('n', '<leader>cts', function()
    require('neotest').summary.toggle()
  end, { desc = '[C]ode [T]est [S]ummary toggle' })
  vim.keymap.set('n', '<leader>cru', function()
    vim.cmd.RustLsp { 'runnables' }
  end, { desc = '[C]ode [R]ust R[U]nnables' })
  vim.keymap.set('n', '<leader>crg', function()
    vim.cmd.RustLsp { 'debuggables' }
  end, { desc = '[C]ode [R]ust debu[g]gables' })
  vim.keymap.set('n', '<leader>crp', function()
    vim.cmd.RustLsp { 'parentModule' }
  end, { desc = '[C]ode [R]ust [P]arent module' })
  vim.keymap.set('n', '<leader>crm', function()
    vim.cmd.RustLsp { 'expandMacro' }
  end, { desc = '[C]ode [R]ust expand [M]acro' })
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
  -- Move between windows
  vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = '[w]indows Left' })
  vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = '[w]indows Down' })
  vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = '[w]indows Up' })
  vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = '[w]indows Right' })
  -- Resize splits
  vim.keymap.set('n', '<leader>w<Left>', '<C-w><', { desc = '[w]indows Resize ←' })
  vim.keymap.set('n', '<leader>w<Right>', '<C-w>>', { desc = '[w]indows Resize →' })
  vim.keymap.set('n', '<leader>w<Up>', '<C-w>+', { desc = '[w]indows Resize ↑' })
  vim.keymap.set('n', '<leader>w<Down>', '<C-w>-', { desc = '[w]indows Resize ↓' })
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
  vim.keymap.set('n', '<leader>oq', '<cmd>OverseerQuickAction<cr>', { desc = '[O]verseer [Q]uick Action' })
  vim.keymap.set('n', '<leader>ob', '<cmd>OverseerBuild<cr>', { desc = '[O]verseer [B]uild Tasks' })
  --Telescope file browser
  vim.keymap.set('n', '<space>sb', ':Telescope file_browser path=%":p:h select_buffer=true<CR>', { desc = '[S]earch file [B]rowser' })
  -- Nvim Spectre

  vim.keymap.set('n', '<leader>srs', function()
    require('spectre').toggle()
  end, { desc = '[s]earch [r]eplace [s]pectre' })
  vim.keymap.set('n', '<leader>srw', function()
    require('spectre').open_visual { select_word = true }
  end, { desc = '[s]earch [r]eplace Spectre visual under [w]ord' })
  vim.keymap.set('v', '<leader>srv', function()
    require('spectre').open_visual()
  end, { desc = '[s]earch [r]eplace Spectre [v]isual' })
  vim.keymap.set('n', '<leader>src', function()
    require('spectre').open_file_search()
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

  -- [Code Zig] keymaps
  vim.keymap.set('n', '<leader>cz', '<Nop>', { desc = '[C]ode [Z]ig' })
  vim.keymap.set('n', '<leader>czb', function()
    run_build_cmd({ 'zig', 'build' }, 'Zig: build')
  end, { desc = '[C]ode [Z]ig [B]uild' })

  vim.keymap.set('n', '<leader>czr', function()
    run_build_cmd({ 'zig', 'build', 'run' }, 'Zig: run')
  end, { desc = '[C]ode [Z]ig [R]un' })

  vim.keymap.set('n', '<leader>czt', function()
    vim.cmd 'write'
    run_build_cmd({ 'zig', 'test', vim.fn.expand '%:p' }, 'Zig: test file')
  end, { desc = '[C]ode [Z]ig [T]est file' })

  vim.keymap.set('n', '<leader>czR', function()
    vim.cmd 'write'
    run_build_cmd({ 'zig', 'run', vim.fn.expand '%:p' }, 'Zig: run current file')
  end, { desc = '[C]ode [Z]ig Run cu[R]rent file' })

  vim.keymap.set('n', '<leader>czf', function()
    require('conform').format { lsp_format = 'fallback' }
  end, { desc = '[C]ode [Z]ig [F]ormat' })

  vim.keymap.set('n', '<leader>czd', function()
    require('dap').continue()
  end, { desc = '[C]ode [Z]ig [D]ebug (continue)' })

  vim.keymap.set('n', '<leader>czi', function()
    local buf = vim.api.nvim_get_current_buf()
    local ok = pcall(vim.lsp.inlay_hint, buf, nil)
    if not ok then
      local enabled = vim.b.zig_inlay_hints_enabled or false
      vim.b.zig_inlay_hints_enabled = not enabled
      vim.lsp.inlay_hint(buf, vim.b.zig_inlay_hints_enabled)
    end
  end, { desc = '[C]ode [Z]ig [I]nlay hints toggle' })

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

  -- [car] Run current script (normal)
  vim.keymap.set('n', '<leader>chr', function()
    vim.cmd.write()
    local p = ahk_paths()
    run_build_cmd({ p.ahk_exe, curfile() }, 'AHK: run current')
  end, { desc = '[C]ode a[h]k [R]un current' })

  -- [cae] Run current script with /ErrorStdOut (diagnostics in terminal/Overseer)
  vim.keymap.set('n', '<leader>che', function()
    vim.cmd.write()
    local p = ahk_paths()
    run_build_cmd({ p.ahk_exe, '/ErrorStdOut', curfile() }, 'AHK: run (stderr)')
  end, { desc = '[C]ode a[h]k Run with [E]rrors (/ErrorStdOut)' })

  -- [caa] Run current script as Admin (UAC prompt)
  vim.keymap.set('n', '<leader>chA', function()
    vim.cmd.write()
    local p = ahk_paths()
    -- Use PowerShell so we can request elevation cleanly
    local ps = ([[Start-Process -Verb RunAs -FilePath "%s" -ArgumentList "%s"]]):format(p.ahk_exe, curfile())
    run_build_cmd({ 'powershell', '-NoProfile', '-Command', ps }, 'AHK: run as admin')
  end, { desc = '[C]ode a[h]k Run as [A]dmin' })

  -- [cac] Compile current script to exe (bin/<name>.exe). Uses icon <name>.ico if present.
  vim.keymap.set('n', '<leader>chc', function()
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
    -- If you want to force a particular base exe, add:
    -- table.insert(args, '/base'); table.insert(args, [[C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe]])

    local cmd = vim.list_extend({ p.compiler }, args)
    run_build_cmd(cmd, 'AHK: compile to exe')
  end, { desc = '[C]ode a[h]k [C]ompile to exe' })

  -- [cak] Kill all running AutoHotkey v2 processes (careful—global!)
  vim.keymap.set('n', '<leader>chk', function()
    run_build_cmd({ 'taskkill', '/F', '/IM', 'AutoHotkey64.exe' }, 'AHK: kill all v2 processes')
  end, { desc = '[C]ode a[h]k [K]ill all AutoHotkey v2' })

  -- [cao] Open current script in Explorer (selected)
  vim.keymap.set('n', '<leader>cho', function()
    run_build_cmd({ 'explorer.exe', '/select,' .. curfile() }, 'AHK: open in Explorer')
  end, { desc = '[C]ode a[h]k [O]pen in Explorer' })

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

  return {}
end)()

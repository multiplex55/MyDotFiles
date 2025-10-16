-- Select how aggressively rust-analyzer should collect project information.
-- Change the default below or set `vim.g.rust_analyzer_profile` (e.g. in `init.lua`).
-- Only one profile should be active at a time.
local rust_analyzer_profile = vim.g.rust_analyzer_profile or 'normal'

-- Profiles balance rust-analyzer features against start-up time and memory usage.
-- Each entry is merged directly into `vim.g.rustaceanvim.server.settings`.
local profiles = {
  normal = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true, -- Load full crate graph; higher RAM usage but better code insight.
        loadOutDirsFromCheck = true, -- Index build scripts for proc-macro completions; slower startup.
      },
      procMacro = { enable = true }, -- Expands macros inline at the cost of additional background work.
      check = { command = 'clippy' }, -- Runs clippy for richer diagnostics, trading extra CPU time.
      diagnostics = { enable = true }, -- Enable full diagnostics feedback.
      cachePriming = { enable = true }, -- Pre-populate caches so later navigation is fast but initial load is heavier.
      completion = { callable = { snippets = 'fill_arguments' } }, -- Provide argument snippets; slightly more memory.
      inlayHints = { enable = true }, -- Render type hints; minimal cost but more UI noise.
      files = { exclude = { 'dist', 'generated' } }, -- Skip generated folders to save indexing time.
    },
  },
  minimal = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = false, -- Index only the current feature set to save memory.
        loadOutDirsFromCheck = false, -- Skip build script output collection for faster startup.
      },
      procMacro = { enable = false }, -- Avoid macro expansion to reduce CPU usage.
      check = { command = 'check', workspace = false }, -- Restrict checks to current package for quicker feedback.
      diagnostics = { enable = true }, -- Keep diagnostics on while using lighter analysis elsewhere.
      cachePriming = { enable = false }, -- Skip cache warm-up to minimise initial work.
      completion = { callable = { snippets = 'none' } }, -- Reduce completion metadata for lower memory pressure.
      inlayHints = { enable = true }, -- Still show hints; cost is minor compared to other toggles.
      files = { exclude = { 'dist', 'generated' } }, -- Same exclusions with negligible overhead.
    },
  },
  no_checks = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = false, -- Minimal feature set to conserve resources.
        loadOutDirsFromCheck = false, -- No build script outputs to keep memory low.
      },
      procMacro = { enable = false }, -- Avoid extra background processes entirely.
      check = { enable = false }, -- Disable background `check` runs for maximal responsiveness.
      diagnostics = { enable = false }, -- Rely on external tools; saves compute otherwise spent on analysis.
      cachePriming = { enable = false }, -- Do not warm caches; lowest upfront cost.
      completion = { callable = { snippets = 'none' } }, -- Basic completion only to keep payloads small.
      inlayHints = { enable = false }, -- Skip hints to reduce render/update work.
      files = { exclude = { 'dist', 'generated' } }, -- Continue ignoring generated output for less indexing churn.
    },
  },
}

local function configure_rustaceanvim()
  -- To switch profiles, change `rust_analyzer_profile` above or set `vim.g.rust_analyzer_profile`
  -- before loading plugins (only one profile should be selected at a time).
  local selected_profile = profiles[rust_analyzer_profile]
  assert(selected_profile, string.format('Unknown rust-analyzer profile: %s', rust_analyzer_profile))

  -- Use environment variable to get install path
  local install_path = vim.fn.expand '$MASON' .. '\\packages\\codelldb'
  local extension_path = install_path .. '\\extension\\'
  local codelldb_path = extension_path .. 'adapter\\codelldb.exe'
  local liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
  local cfg = require 'rustaceanvim.config'

  vim.g.rustaceanvim = vim.tbl_deep_extend('force', vim.g.rustaceanvim or {}, {
    dap = {
      adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
    },
    server = {
      settings = selected_profile,
    },
  })
end

return {
  { -- RUST
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    ft = { 'rust', 'toml', 'ron' },
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
    config = configure_rustaceanvim,
  },
}

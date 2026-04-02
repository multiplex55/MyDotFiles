-- lua/custom/plugins/vim-go.lua
-- vim-go command cheat sheet:
-- - :GoRun — run the current file/package entrypoint.
-- - :GoTest / :GoTestFunc / :GoTestFile — run tests for package, function, or file scope.
-- - :GoBuild / :GoInstall — compile current package or compile-and-install it.
-- - :GoFmt / :GoImports — format code and normalize imports.
-- - :GoDef / :GoDoc / :GoImplements / :GoReferrers — jump to defs/docs and inspect relationships.
-- - :GoRename — rename symbol references through supported backend.
-- - :GoDebugStart / :GoDebugTest / :GoDebugContinue — start and control debugger session flow.
-- - :GoMetaLinter — run configured lint checks for current package.
return {
  {
    'fatih/vim-go',

    -- Load when opening Go-related files.
    ft = {
      'go',
      'gomod',
      'gotexttmpl',
      'gohtmltmpl',
    },

    -- Installs / updates vim-go helper binaries after install/update.
    build = ':GoUpdateBinaries',

    init = function()
      ------------------------------------------------------------------------
      -- NOTE
      ------------------------------------------------------------------------
      -- This version is written as a "control panel" file:
      -- - lots of vim-go settings are surfaced in one place
      -- - comments explain what each group does
      -- - it is reasonably safe alongside native Neovim LSP/cmp
      --
      -- If you want vim-go itself to own completion/diagnostics too, flip the
      -- related toggles below.

      ------------------------------------------------------------------------
      -- Core / completion
      ------------------------------------------------------------------------
      vim.g.go_version_warning = 1

      -- vim-go omnifunc completion.
      -- Set to 1 if you want vim-go to provide completion.
      -- Leave at 0 if you already use native LSP + nvim-cmp/blink/coc/etc.
      vim.g.go_code_completion_enabled = 0

      -- Case-insensitive completion behavior for omnifunc results.
      vim.g.go_code_completion_icase = 0

      ------------------------------------------------------------------------
      -- Tests / browser / cursor-driven helpers
      ------------------------------------------------------------------------
      -- Show failed test names before their output.
      vim.g.go_test_show_name = 1

      -- Timeout used by :GoTest when no explicit args are passed.
      vim.g.go_test_timeout = '10s'

      -- Custom browser command for :GoPlay / :GoDocBrowser / :GoLSPDebugBrowser.
      -- Leave blank to let vim-go auto-detect.
      vim.g.go_play_browser_command = ''

      -- Open browser automatically after :GoPlay.
      vim.g.go_play_open_browser = 1

      -- Auto show :GoInfo for symbol under cursor.
      -- Usually off when you already have hover/signature help from LSP.
      vim.g.go_auto_type_info = 0

      -- Auto highlight same identifiers under cursor.
      vim.g.go_auto_sameids = 0

      -- Delay for auto type-info / sameids.
      vim.g.go_updatetime = 800

      -- If 1, mappings jump to first error automatically.
      -- If 0, mappings behave more like the bang form (!).
      vim.g.go_jump_to_error = 1

      ------------------------------------------------------------------------
      -- Formatting / imports
      ------------------------------------------------------------------------
      -- Format on save.
      vim.g.go_fmt_autosave = 1

      -- Formatter backend:
      -- "gopls" | "gofmt" | "goimports"
      vim.g.go_fmt_command = 'gopls'

      -- Extra formatter options.
      -- Example for goimports local prefix grouping:
      -- vim.g.go_fmt_options = {
      --   goimports = "-local github.com/your-org",
      -- }
      vim.g.go_fmt_options = {}

      -- Show location list when formatting fails.
      vim.g.go_fmt_fail_silently = 0

      -- Older experimental formatting path. Usually leave off.
      vim.g.go_fmt_experimental = 0

      -- Auto run :GoImports on save.
      vim.g.go_imports_autosave = 1

      -- Import-management backend:
      -- "gopls" | "goimports"
      -- Note: with "gopls", imports are adjusted but the buffer is not fully
      -- formatted by the imports step itself.
      vim.g.go_imports_mode = 'gopls'

      -- Auto format go.mod on save.
      vim.g.go_mod_fmt_autosave = 1

      -- Auto format Go asm buffers on save.
      vim.g.go_asmfmt_autosave = 0

      ------------------------------------------------------------------------
      -- Docs / definition / fillstruct / rename
      ------------------------------------------------------------------------
      -- Make K use :GoDoc for Go buffers.
      vim.g.go_doc_keywordprg_enabled = 1

      -- Max height of the GoDoc split.
      vim.g.go_doc_max_height = 20

      -- Show docs in balloon support (usually off in Neovim).
      vim.g.go_doc_balloon = 0

      -- Docs site used by :GoDocBrowser.
      vim.g.go_doc_url = 'https://pkg.go.dev'

      -- Use popup window for :GoDoc / K instead of preview window.
      vim.g.go_doc_popup_window = 0

      -- Definition backend:
      -- "gopls" | "godef"
      vim.g.go_def_mode = 'gopls'

      -- Fill struct backend:
      -- "fillstruct" | "gopls"
      vim.g.go_fillstruct_mode = 'fillstruct'

      -- Enable vim-go default mappings for:
      --   Ctrl-], gd, gD, Ctrl-t, etc.
      vim.g.go_def_mapping_enabled = 1

      -- Reuse existing buffer on split/tab definition jumps.
      vim.g.go_def_reuse_buffer = 0

      -- Rename backend:
      -- "gopls" | "gopls rename" | "gorename"
      vim.g.go_rename_command = 'gopls'

      ------------------------------------------------------------------------
      -- Binary management / tool lookup
      ------------------------------------------------------------------------
      -- Custom bin path for vim-go tools. Blank = use GOBIN / GOPATH/bin rules.
      vim.g.go_bin_path = ''

      -- Prefer go_bin_path over PATH when launching helper tools.
      vim.g.go_search_bin_path_first = 1

      -- Allow :GoInstallBinaries / :GoUpdateBinaries to update deps.
      vim.g.go_get_update = 1

      -- Space-separated build tags passed to supported tools.
      vim.g.go_build_tags = ''

      ------------------------------------------------------------------------
      -- Snippets / text objects
      ------------------------------------------------------------------------
      -- "automatic" | "ultisnips" | "neosnippet" | "minisnip"
      vim.g.go_snippet_engine = 'automatic'

      -- Enable vim-go text objects / motions:
      -- af, if, ac, ic, [[, ]]
      vim.g.go_textobj_enabled = 1

      -- Include function doc comments in `af` and motions.
      vim.g.go_textobj_include_function_doc = 1

      -- Include variable in anonymous function assignment text objects.
      vim.g.go_textobj_include_variable = 1

      ------------------------------------------------------------------------
      -- Diagnostics / linting / result lists
      ------------------------------------------------------------------------
      -- vim-go diagnostics level from gopls:
      -- 0 = off
      -- 1 = errors only
      -- 2 = errors + warnings
      --
      -- Good coexistence choice with native Neovim diagnostics: 0
      vim.g.go_diagnostics_level = 0

      -- Deprecated older toggle:
      -- vim.g.go_diagnostics_enabled = 0

      -- Auto-run metalinter on save.
      vim.g.go_metalinter_autosave = 0

      -- Linters used for autosave linting.
      -- For golangci-lint, setting any entries implies --default=none behavior.
      vim.g.go_metalinter_autosave_enabled = {
        'govet',
        'revive',
      }

      -- Linters used by :GoMetaLinter.
      vim.g.go_metalinter_enabled = {
        'govet',
        'revive',
        'errcheck',
      }

      -- Linter backend:
      -- "golangci-lint" | "gopls" | "staticcheck"
      vim.g.go_metalinter_command = 'golangci-lint'

      -- Deadline mainly applies to golangci-lint.
      vim.g.go_metalinter_deadline = '5s'

      -- Quickfix / location-list window height.
      -- 0 = auto-size
      vim.g.go_list_height = 0

      -- Default list type for command output:
      -- "" | "quickfix" | "locationlist"
      vim.g.go_list_type = ''

      -- Per-command list routing overrides.
      vim.g.go_list_type_commands = {
        GoBuild = 'quickfix',
        GoTest = 'quickfix',
        GoMetaLinter = 'locationlist',
        GoMetaLinterAutoSave = 'locationlist',
      }

      -- Auto-close the list window when no errors remain.
      vim.g.go_list_autoclose = 1

      ------------------------------------------------------------------------
      -- Terminal-backed command behavior
      ------------------------------------------------------------------------
      -- How to open terminal for :GoRun / :GoTest / etc.
      -- Examples: "split", "vsplit", "tabnew"
      vim.g.go_term_mode = 'vsplit'

      -- Reuse the terminal window.
      vim.g.go_term_reuse = 0

      -- Optional split sizing:
      -- vim.g.go_term_height = 30
      -- vim.g.go_term_width = 90

      -- Run certain commands in a terminal buffer instead of background jobs.
      vim.g.go_term_enabled = 0

      -- Close terminal when command exits and fails.
      vim.g.go_term_close_on_exit = 1

      -- How :GoAlternate opens the counterpart file.
      -- Common values: "edit", "split", "vsplit", "tabedit"
      vim.g.go_alternate_mode = 'edit'

      ------------------------------------------------------------------------
      -- gopls integration
      ------------------------------------------------------------------------
      -- Allow vim-go to use gopls features.
      vim.g.go_gopls_enabled = 1

      -- Command-line args passed to gopls.
      vim.g.go_gopls_options = { '-remote=auto' }

      -- Advanced gopls settings.
      -- Uncomment only when you need to force a value instead of using gopls
      -- defaults. For "use gopls default", vim-go docs use v:null; in Lua,
      -- leave them unset unless you specifically need an override.

      -- vim.g.go_gopls_analyses = { unusedparams = true, shadow = true }
      -- vim.g.go_gopls_complete_unimported = true
      -- vim.g.go_gopls_deep_completion = true
      -- vim.g.go_gopls_matcher = "fuzzy" -- or "caseSensitive"
      -- vim.g.go_gopls_staticcheck = true
      -- vim.g.go_gopls_use_placeholders = true
      -- vim.g.go_gopls_temp_modfile = true

      -- Local import grouping prefix. Can also be a table keyed by abs path.
      -- vim.g.go_gopls_local = "github.com/your-org"

      -- Ask gopls to format using gofumpt rules.
      -- vim.g.go_gopls_gofumpt = true

      -- Escape hatch for newer gopls workspace settings not directly exposed
      -- by vim-go yet.
      -- vim.g.go_gopls_settings = {
      --   semanticTokens = true,
      -- }

      ------------------------------------------------------------------------
      -- New-file templates / declaration picker / status text
      ------------------------------------------------------------------------
      -- Auto-populate new Go files from template/package.
      vim.g.go_template_autocreate = 1

      -- Template file used for new regular Go files.
      vim.g.go_template_file = 'hello_world.go'

      -- Template file used for new *_test.go files.
      vim.g.go_template_test_file = 'hello_world_test.go'

      -- If 1, prefer just the package declaration over template content.
      vim.g.go_template_use_pkg = 0

      -- Which declarations :GoDecls should show.
      vim.g.go_decls_includes = 'func,type'

      -- Declaration picker backend:
      -- "" | "fzf" | "ctrlp.vim"
      vim.g.go_decls_mode = ''

      -- Echo command status in command line.
      vim.g.go_echo_command_info = 1

      -- Echo info after completion.
      vim.g.go_echo_go_info = 1

      -- How long async statusline info is retained (ms).
      vim.g.go_statusline_duration = 60000

      ------------------------------------------------------------------------
      -- Struct tag helpers
      ------------------------------------------------------------------------
      -- Transform mode for :GoAddTags / gomodifytags:
      -- "snakecase" | "camelcase" | "lispcase" | "pascalcase" | "keep"
      vim.g.go_addtags_transform = 'snakecase'

      -- Skip unexported fields when adding tags.
      vim.g.go_addtags_skip_unexported = 0

      ------------------------------------------------------------------------
      -- Debugging / logging
      ------------------------------------------------------------------------
      -- Debug channels:
      -- "shell-commands", "debugger-state", "debugger-commands", "lsp"
      vim.g.go_debug = {}

      -- Debug window layout.
      vim.g.go_debug_windows = {
        vars = 'leftabove 30vnew',
        stack = 'leftabove 20new',
        goroutines = 'botright 10new',
        out = 'botright 5new',
      }

      -- Preserve existing layout when entering debug mode.
      vim.g.go_debug_preserve_layout = 0

      -- Remote->local source path substitutions for delve.
      -- Example:
      -- vim.g.go_debug_substitute_paths = {
      --   { "/compiled/from", "/local/source/path" },
      -- }
      vim.g.go_debug_substitute_paths = {}

      -- Override debugger mappings if desired.
      -- Keys are vim-go mapping names like "(go-debug-continue)".
      vim.g.go_debug_mappings = {}

      ------------------------------------------------------------------------
      -- Syntax highlighting / folding
      ------------------------------------------------------------------------
      -- Folding regions when using foldmethod=syntax.
      vim.g.go_fold_enable = {
        'block',
        'import',
        'varconst',
        'package_comment',
      }

      -- Most highlight extras are intentionally off by default.
      -- Turn on only the ones you actually like / that your machine handles well.
      vim.g.go_highlight_array_whitespace_error = 0
      vim.g.go_highlight_chan_whitespace_error = 0
      vim.g.go_highlight_extra_types = 0
      vim.g.go_highlight_space_tab_error = 0
      vim.g.go_highlight_trailing_whitespace_error = 0
      vim.g.go_highlight_operators = 0
      vim.g.go_highlight_functions = 0
      vim.g.go_highlight_function_parameters = 0
      vim.g.go_highlight_function_calls = 0
      vim.g.go_highlight_types = 0
      vim.g.go_highlight_fields = 0
      vim.g.go_highlight_build_constraints = 0
      vim.g.go_highlight_generate_tags = 0
      vim.g.go_highlight_string_spellcheck = 1
      vim.g.go_highlight_format_strings = 1
      vim.g.go_highlight_variable_declarations = 0
      vim.g.go_highlight_variable_assignments = 0
      vim.g.go_highlight_diagnostic_errors = 1
      vim.g.go_highlight_diagnostic_warnings = 1
    end,
  },
}

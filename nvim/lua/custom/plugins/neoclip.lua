return {
  {
    'AckslD/nvim-neoclip.lua',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kkharji/sqlite.lua',
    },
    opts = {
      history = 2000, -- Maximum number of yank entries to keep in memory.
      enable_persistent_history = true, -- Save history to disk on exit and load it lazily when needed.
      length_limit = 1048576, -- Discard yanks longer than this many bytes to avoid bloating the history.
      continuous_sync = true, -- Keep the on-disk history synced after every change for multi-session workflows.
      db_path = vim.fn.stdpath 'data' .. '/databases/neoclip.sqlite3', -- Custom location of the sqlite database used for persistence.
      filter = function(_)
        -- Accept every yank entry; customize here if certain filetypes should be excluded.
        return true
      end,
      preview = true, -- Show a floating preview of the entry with syntax highlighting when available.
      default_register = '"', -- Use the unnamed register when pasting (matches hitting `p`).
      default_register_macros = 'q', -- Default macro register to replay when not explicitly chosen.
      enable_macro_history = true, -- Track recorded macros alongside regular yanks.
      content_spec_column = false, -- Keep the preview window instead of replacing it with metadata columns.
      disable_keycodes_parsing = false, -- Render macros using readable keycodes rather than raw byte sequences.
      dedent_picker_display = true, -- Trim common leading whitespace for cleaner picker entries.
      initial_mode = 'normal', -- Start Telescope picker in normal mode for familiar navigation.
      on_select = {
        move_to_front = true, -- Reorder entries so the selected yank becomes the most recent.
        close_telescope = false, -- Keep Telescope open after selecting so further actions can be taken.
      },
      on_paste = {
        set_reg = true, -- Update the configured register when pasting directly from the picker.
        move_to_front = true, -- Move pasted entries to the top to reflect their recent use.
        close_telescope = true, -- Close Telescope after pasting since the action is complete.
      },
      on_replay = {
        set_reg = true, -- Load the macro into the configured register before replaying.
        move_to_front = true, -- Move replayed macros to the top so they are easy to rerun.
        close_telescope = true, -- Close Telescope when a macro is replayed to avoid accidental repeats.
      },
      on_custom_action = {
        close_telescope = true, -- Close Telescope after custom actions to match paste/replay behavior.
      },
      keys = {
        telescope = {
          i = {
            select = '<cr>', -- Insert-mode confirm selection.
            paste = '<c-p>', -- Insert-mode paste mapping.
            paste_behind = '<c-k>', -- Insert-mode paste behind cursor.
            replay = '<c-q>', -- Insert-mode macro replay.
            delete = '<c-d>', -- Insert-mode remove entry.
            edit = '<c-e>', -- Insert-mode open entry in a scratch buffer for editing.
            custom = {}, -- Insert-mode slot for additional custom actions.
          },
          n = {
            select = '<cr>', -- Normal-mode confirm selection.
            paste = 'p', -- Normal-mode paste using the configured default register.
            paste_behind = 'P', -- Normal-mode paste behind the cursor.
            replay = 'q', -- Normal-mode replay recorded macro.
            delete = 'd', -- Normal-mode delete entry from history.
            edit = 'e', -- Normal-mode edit entry contents.
            custom = {}, -- Normal-mode slot for additional custom actions.
          },
        },
        fzf = {
          select = 'default', -- Default selection binding in fzf-lua pickers.
          paste = 'ctrl-p', -- Paste mapping when using fzf-lua integration.
          paste_behind = 'ctrl-k', -- Paste-behind mapping for fzf-lua integration.
          custom = {}, -- Placeholder for fzf-lua custom actions.
        },
      },
    },
    config = function(_, opts)
      -- SQLite support (configured in init.lua) is required for persistence, especially on Windows setups.
      require('neoclip').setup(opts)
      pcall(require('telescope').load_extension, 'neoclip')
    end,
  },
}

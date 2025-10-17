# Manual Regression: Tab Duplication with TabScope

This checklist verifies that `<leader>tD` duplicates the entire window layout and keeps the same buffers when TabScope is managing tab-local state.

1. Start Neovim with this configuration and open at least two buffers (for example, `init.lua` and `README.md`).
2. Arrange the current tab into multiple windows (e.g., horizontal and vertical splits) so each window shows a different buffer.
3. Run `<leader>tD`.
4. Confirm that Neovim creates a new tab and every window in the new tab displays the same buffer as its counterpart in the original tab, preserving cursor positions where possible.
5. If TabScope is enabled, run `:TabScopeDebug` and confirm that the new tab lists the same buffers as the original tab.
6. Close the duplicated tab when finished.

> Tip: The command emits a notification summarizing the duplication path, which can help diagnose TabScope state issues if something diverges.

# Maintenance Notes

- **Config-lock consistency invariant:** whenever `nvim-treesitter` branch strategy is changed in `lua/custom/plugins/nvim-treesitter.lua`, update `lazy-lock.json` in the same change so the lock entry branch and commit match the installed revision.

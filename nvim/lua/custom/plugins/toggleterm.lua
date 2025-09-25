return {{
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = function()
        local options = {}

        if vim.fn.has 'win32' == 1 then
            local shell = vim.g.custom_pwsh_terminal_cmd

            if not shell or shell == '' then
                local powershell_exe = vim.fn.exepath 'pwsh.exe'
                if powershell_exe ~= '' then
                    shell = string.format([[%q]], powershell_exe)
                end
            end

            if shell and shell ~= '' then
                options.shell = shell
            end
        end

        return options
    end,
}}

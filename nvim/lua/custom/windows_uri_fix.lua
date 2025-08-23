-- lua/custom/windows_uri_fix.lua (tiny version)
if (vim.uv or vim.loop).os_uname().sysname == 'Windows_NT' then
  local old_uri_from_fname = vim.uri_from_fname
  vim.uri_from_fname = function(path)
    path = path:gsub('^([a-z]):', function(d)
      return d:upper() .. ':'
    end)
    return old_uri_from_fname(path)
  end
  vim.api.nvim_create_autocmd({ 'BufReadPre', 'FileReadPre' }, {
    callback = function(ev)
      local p = ev.match or vim.api.nvim_buf_get_name(ev.buf)
      if type(p) ~= 'string' or p == '' then
        return
      end
      local up = p:gsub('^([a-z]):', function(d)
        return d:upper() .. ':'
      end)
      if up ~= p and vim.loop.fs_stat(up) then
        vim.cmd('silent! keepalt keepjumps noautocmd file ' .. vim.fn.fnameescape(up))
      end
    end,
  })
end

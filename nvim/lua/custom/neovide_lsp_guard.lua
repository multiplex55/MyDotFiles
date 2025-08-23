-- In Neovide, some UI/plugins may call LSP before the buffer is attached.
-- Queue those textDocument/* calls until LspAttach to avoid ocamllsp's banner.
if not vim.g.neovide then
  return
end

local orig = vim.lsp.buf_request

local function has_attached_client(bufnr)
  for _, c in pairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if vim.lsp.buf_is_attached(bufnr, c.id) then
      return true
    end
  end
  return false
end

vim.lsp.buf_request = function(bufnr, method, params, handler)
  -- Normalize URI drive to uppercase (cheap + safe)
  local function norm(t)
    if type(t) ~= 'table' then
      return t
    end
    for k, v in pairs(t) do
      if k == 'uri' and type(v) == 'string' then
        t[k] = v:gsub('^file:///([a-z])%%3A', function(d)
          return 'file:///' .. d:upper() .. '%%3A'
        end)
      else
        norm(v)
      end
    end
    return t
  end

  params = norm(params)

  -- If this is a textDocument/* call but no client is attached yet, queue it.
  if type(method) == 'string' and method:find '^textDocument/' and not has_attached_client(bufnr) then
    vim.api.nvim_create_autocmd('LspAttach', {
      once = true,
      callback = function(a)
        if a.buf == bufnr then
          -- resend once the buffer actually attached
          orig(bufnr, method, params, handler)
        end
      end,
    })
    return
  end

  return orig(bufnr, method, params, handler)
end

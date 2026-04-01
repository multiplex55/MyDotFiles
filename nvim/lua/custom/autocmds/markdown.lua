local markdown_runtime = require 'custom.utils.markdown_runtime'

local M = {}

local MARKDOWN_FILETYPES = {
  markdown = true,
  rmd = true,
  ['markdown.mdx'] = true,
}

local function is_markdown_buf(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  return MARKDOWN_FILETYPES[vim.bo[bufnr].filetype] == true
end

local function is_treesitter_failure(err)
  local message = tostring(err or ''):lower()
  if message == '' then
    return false
  end

  if message:find('range') and message:find('nil') then
    return true
  end

  if message:find('directive') then
    return true
  end

  return message:find('treesitter') and message:find('query') and message:find('error')
end

local function notify_once(bufnr, reason)
  if vim.b[bufnr].markdown_recovery_notified then
    return
  end

  vim.b[bufnr].markdown_recovery_notified = true
  vim.notify(
    'Markdown UI fallback enabled for this buffer ('
      .. reason
      .. '). Treesitter highlighting and render-markdown were disabled. '
      .. 'Use :MarkdownRecover after running :TSUpdate / plugin updates, then restart Neovim after parser sync if needed.',
    vim.log.levels.WARN,
    { title = 'Markdown crash recovery' }
  )
end

local function disable_render_markdown(bufnr)
  vim.b[bufnr].render_markdown_enabled = false
  vim.api.nvim_buf_call(bufnr, function()
    pcall(vim.cmd, 'silent! RenderMarkdown disable')
  end)
end

local function fallback_to_basic_markdown(bufnr, reason)
  vim.b[bufnr].markdown_recovery_failed = true

  pcall(vim.treesitter.stop, bufnr)
  disable_render_markdown(bufnr)

  vim.bo[bufnr].syntax = 'markdown'

  notify_once(bufnr, reason)
end

local function safe_start_markdown_ui(bufnr)
  if not is_markdown_buf(bufnr) then
    return false
  end

  if vim.b[bufnr].markdown_recovery_failed and not vim.b[bufnr].markdown_recover_requested then
    return false
  end

  if not markdown_runtime.can_enable_render_markdown(bufnr) and not vim.b[bufnr].markdown_recover_requested then
    return false
  end

  local ok_ts, ts_err = pcall(vim.treesitter.start, bufnr)
  if not ok_ts and is_treesitter_failure(ts_err) then
    fallback_to_basic_markdown(bufnr, 'treesitter failure signature')
    return false
  end

  local ok_render, render_err = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd 'silent RenderMarkdown enable'
    end)
  end)

  if not ok_render and is_treesitter_failure(render_err) then
    fallback_to_basic_markdown(bufnr, 'render-markdown treesitter directive failure')
    return false
  end

  vim.b[bufnr].markdown_recovery_failed = false
  vim.b[bufnr].markdown_recover_requested = false

  return true
end

function M.recover(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.b[bufnr].markdown_recover_requested = true

  local ok = safe_start_markdown_ui(bufnr)
  if ok then
    vim.notify('Markdown UI recovery succeeded for current buffer.', vim.log.levels.INFO, { title = 'MarkdownRecover' })
    return
  end

  if not vim.b[bufnr].markdown_recovery_failed then
    vim.notify('MarkdownRecover did not enable markdown UI for this buffer (runtime safety gate).', vim.log.levels.WARN, {
      title = 'MarkdownRecover',
    })
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('custom_markdown_crash_recovery', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'markdown', 'rmd', 'markdown.mdx' },
    callback = function(event)
      vim.schedule(function()
        safe_start_markdown_ui(event.buf)
      end)
    end,
  })

  pcall(vim.api.nvim_del_user_command, 'MarkdownRecover')
  vim.api.nvim_create_user_command('MarkdownRecover', function()
    M.recover(vim.api.nvim_get_current_buf())
  end, {
    desc = 'Retry Treesitter + render-markdown after markdown crash fallback',
  })
end

return M

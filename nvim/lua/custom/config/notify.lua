local M = {}

local defaults = {
  timeout = 3000,
  stages = 'fade_in_slide_out', -- also: 'fade', 'slide', 'static', 'fade_in_slide_out'
  render = 'default', -- also: 'minimal', 'simple', 'compact', 'wrapped-compact'
  background_colour = '#000000',
  top_down = true,
  fps = 60,
  minimum_width = 20,
  minimum_height = 1,
  max_width = 120,
  max_height = 20,
}

local function normalize_global_opts(value)
  if type(value) == 'table' then
    return value
  end

  return {}
end

function M.defaults()
  return vim.deepcopy(defaults)
end

function M.resolve(overrides)
  local global_overrides = normalize_global_opts(vim.g.custom_notify_opts)
  local local_overrides = type(overrides) == 'table' and overrides or {}

  return vim.tbl_deep_extend('force', M.defaults(), global_overrides, local_overrides)
end

return M

-- luacheck: no self
local Completions = require("99.extensions.completions")

--- @class BlinkSource
local BlinkSource = {}
BlinkSource.__index = BlinkSource

function BlinkSource.new()
  return setmetatable({}, { __index = BlinkSource })
end

function BlinkSource:get_keyword_pattern()
  return Completions.get_keyword_pattern()
end

function BlinkSource:enabled()
  return vim.bo.filetype == "99prompt"
end

function BlinkSource:get_trigger_characters()
  return Completions.get_trigger_characters()
end

--- @param ctx table blink.cmp context
--- @param callback fun(result: table): nil
function BlinkSource:get_completions(ctx, callback)
  local before = ctx.line:sub(1, ctx.cursor[2])
  local trigger = Completions.detect_trigger(before)

  if not trigger then
    ---@diagnostic disable-next-line: missing-parameter
    return callback()
  end

  local items = Completions.get_completions(trigger)

  callback({
    items = items,
    is_incomplete_backward = true,
    is_incomplete_forward = false,
  })
end

--- @type BlinkSource | nil
local source = nil

--- @param _ _99.State
local function init(_)
  if source then
    return
  end
  source = BlinkSource.new()
end

--- @param _ _99.State
local function init_for_buffer(_)
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].filetype = "99prompt"
end

--- @param _ _99.State
local function refresh_state(_) end

--- @param _ table | nil
--- @return BlinkSource
local function new(_)
  if source then
    return source
  end
  source = BlinkSource.new()
  return source
end

--- @type _99.Extensions.Source
local source_wrapper = {
  dependency = "blink.cmp",
  init = init,
  init_for_buffer = init_for_buffer,
  refresh_state = refresh_state,
  new = new,
}
return source_wrapper

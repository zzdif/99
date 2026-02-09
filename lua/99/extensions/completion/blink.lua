-- luacheck: no self
local Agents = require("99.extensions.agents")
local Files = require("99.extensions.files")
local Completions = require("99.extensions.completions")

--- @class BlinkSource
local BlinkSource = {}
BlinkSource.__index = BlinkSource

function BlinkSource.new()
  local self = setmetatable({}, { __index = BlinkSource })
  return self
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

  -- Find which trigger is active
  local trigger = nil
  for _, char in ipairs(Completions.get_trigger_characters()) do
    local pattern = char:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1") .. "%S*$"
    if before:match(pattern) then
      trigger = char
      break
    end
  end

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

--- @param _99 _99.State
local function register_providers(_99)
  Completions.register(Agents.completion_provider(_99))
  Completions.register(Files.completion_provider())
end

--- @param _99 _99.State
local function init(_99)
  -- Collect rule directories to exclude from file search
  local rule_dirs = {}
  if _99.completion then
    if _99.completion.custom_rules then
      for _, dir in ipairs(_99.completion.custom_rules) do
        table.insert(rule_dirs, dir)
      end
    end
  end

  if _99.completion and _99.completion.files then
    Files.setup(_99.completion.files, rule_dirs)
  else
    Files.setup({ enabled = true }, rule_dirs)
  end

  register_providers(_99)

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

--- @param _99 _99.State
local function refresh_state(_99)
  if not source then
    return
  end
  register_providers(_99)
end

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

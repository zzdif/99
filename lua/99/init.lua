local Logger = require("99.logger.logger")
local editor = require("99.editor")
local geo = require("99.geo")
local Point = geo.Point

--- @class LoggerOptions
--- @field level number?
--- @field path string?

--- @class _99Options
--- @field logger LoggerOptions?

local _99_settings = {
    fill_in_function = "fill in the function.  dont change the function signature. do not edit anything outside of this function.  prioritize using internal functions for work that has already been done.  do not edit anything but this function."
}

local function get_file_information(buffer)
    local full_path = vim.fn.expand("%:p")
    return full_path
end

--- @class _99
local _99 = { }

function _99.fill_in_function()
	local ts = editor.treesitter
	local cursor = Point:from_cursor()
	local scopes = ts.function_scopes(cursor)

	if scopes == nil or #scopes.range == 0 then
		Logger:warn("fill_in_function: unable to find any containing function")
		error("you cannot call fill_in_function not in a function")
	end

	local range = scopes.range[#scopes.range]
	local open_code_query = {
		range:to_text(),
	}
end

--- @param opts _99Options?
function _99.init(opts)
	opts = opts or {}
	local logger = opts.logger
	if logger then
		if logger.level then
			Logger:set_level(logger.level)
		end
		if logger.path then
			Logger:file_sink(logger.path)
		end
	end
end

_99.fill_in_function()

return _99

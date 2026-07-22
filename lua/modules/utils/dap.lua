local M = {}

function M.input_args()
	local argument_string = vim.fn.input("Program arg(s) (enter nothing to leave it null): ")
	return vim.fn.split(argument_string, " ", true)
end

function M.input_exec_path()
	return vim.fn.input('Path to executable (default to "a.out"): ', vim.fn.expand("%:p:h") .. "/a.out", "file")
end

function M.input_file_path()
	return vim.fn.input("Path to debuggee (default to the current file): ", vim.fn.expand("%:p"), "file")
end

function M.get_env()
	local variables = {}
	for k, v in pairs(vim.uv.os_environ()) do
		table.insert(variables, string.format("%s=%s", k, v))
	end
	return variables
end

---Validate a remote-attach endpoint's shape at config time — a clear error
---beats an opaque connection failure. Hosts are free-form (hostname/IPv4/
---IPv6), so only the shape is checked; ports must be integers 1-65535
---(tonumber-coerced). `opts.default_port` fills an absent port; nil means the
---port is required. An absent host defaults to "127.0.0.1".
---@param config table @The table carrying .host/.port (caller resolves any connect indirection).
---@param opts { label: string, default_port?: integer } @default_port omitted = port required.
---@return string host, integer port
function M.attach_endpoint(config, opts)
	-- Actionable config-time errors beat an opaque "attempt to index" deeper in
	-- (this helper's whole purpose): guard the two shapes it dereferences.
	assert(type(config) == "table", "attach_endpoint: config must be a table")
	assert(type(opts) == "table" and type(opts.label) == "string", "attach_endpoint: opts.label (string) is required")
	-- config.port and opts.default_port share the 1-65535 integer contract, so
	-- validate them the same way — an invalid default (0, 70000, "abc") must not
	-- slip through to the return.
	local function coerce_port(v)
		local n = tonumber(v)
		if not n or n ~= math.floor(n) or n < 1 or n > 65535 then
			return nil
		end
		return n
	end
	local port
	if config.port ~= nil then
		port = coerce_port(config.port)
		if not port then
			error(
				string.format("%s: invalid `port` %s (want an integer 1-65535)", opts.label, vim.inspect(config.port)),
				0
			)
		end
	elseif opts.default_port ~= nil then
		port = coerce_port(opts.default_port)
		if not port then
			error(
				string.format(
					"%s: invalid `default_port` %s (want an integer 1-65535)",
					opts.label,
					vim.inspect(opts.default_port)
				),
				0
			)
		end
	else
		error(string.format("%s: `port` is required", opts.label), 0)
	end
	local host = "127.0.0.1"
	if config.host ~= nil then
		if type(config.host) ~= "string" or config.host == "" then
			error(
				string.format("%s: invalid `host` %s (want a non-empty string)", opts.label, vim.inspect(config.host)),
				0
			)
		end
		host = config.host
	end
	return host, port
end

local export = setmetatable({}, {
	-- Lazy nullary double-thunk: `program = utils.input_file_path()` hands
	-- nvim-dap a zero-arg closure. Any key reached through this __index
	-- DISCARDS call arguments — functions that take arguments must be
	-- CONCRETE keys on the export (raw hits bypass __index).
	__index = function(_, key)
		return function()
			return function()
				return M[key]()
			end
		end
	end,
})
export.attach_endpoint = M.attach_endpoint
return export

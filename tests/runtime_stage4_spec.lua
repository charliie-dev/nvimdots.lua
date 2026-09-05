local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = table.concat({
	root .. "/lua/?.lua",
	root .. "/lua/?/init.lua",
	root .. "/lua/modules/configs/?.lua",
	package.path,
}, ";")
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/site/lazy/conform.nvim")

local conform = require("conform")
local runner = require("conform.runner")
local settings = require("core.settings")
local configure = require("completion.conform")
local original_cwd = vim.fn.getcwd()
local fixture = (vim.env.TMPDIR or vim.fs.dirname(vim.fn.tempname()))
	.. "/runtime_stage4-"
	.. vim.fn.getpid()
	.. " projects with spaces"
local plain = fixture .. "/plain project"
local styled = fixture .. "/styled project"
local nested = styled .. "/nested directory"
local underscore = fixture .. "/underscore project"
local buffers = {}
local commands = {}
local failures = {}
local tests_run = 0
local input = { "int main() {", "if(true) {", "return 0;", "}", "}" }
local fallback = "-style={ BasedOnStyle: LLVM, IndentWidth: 4 }"
local original_build_cmd = runner.build_cmd
runner.build_cmd = function(...)
	local cmd = original_build_cmd(...)
	commands[#commands + 1] = cmd
	print("ARGV " .. vim.json.encode(cmd))
	return cmd
end

local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	if ok then
		print("PASS " .. name)
	else
		failures[#failures + 1] = name .. ": " .. err
		print("FAIL " .. name .. ": " .. err)
	end
end

local function override(name, value)
	package.loaded[name] = nil
	package.preload[name] = value ~= nil and function()
		return value
	end or nil
end

local function setup(cwd, formatter_override, conform_override)
	vim.api.nvim_set_current_dir(cwd or plain)
	override("user.configs.formatters.clang_format", formatter_override)
	override("user.configs.conform", conform_override)
	package.loaded["completion.formatters.clang_format"] = nil
	conform.formatters = {}
	settings.format_on_save = true
	settings.format_notify = false
	settings.format_modifications_only = false
	settings.format_disabled_dirs = { plain .. "/disabled" }
	settings.formatter_block_list = {}
	configure()
end

local function buffer(path)
	local buf = vim.api.nvim_create_buf(true, false)
	buffers[#buffers + 1] = buf
	vim.api.nvim_buf_set_name(buf, path)
	vim.bo[buf].filetype = "cpp"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
	return buf
end

local function expected(width)
	return {
		"int main() {",
		string.rep(" ", width) .. "if (true) {",
		string.rep(" ", 2 * width) .. "return 0;",
		string.rep(" ", width) .. "}",
		"}",
	}
end

local function assert_lines(buf, lines)
	local actual = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	assert(vim.deep_equal(actual, lines), "unexpected formatting: " .. vim.inspect(actual))
end

local function format(buf, width, style, range)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
	local previous = #commands
	local callback_called, format_error
	assert(
		conform.format({ bufnr = buf, range = range }, function(err)
			callback_called, format_error = true, err
		end),
		"no formatter attempted"
	)
	assert(callback_called and not format_error, vim.inspect(format_error))
	assert_lines(buf, expected(width))
	assert(#commands == previous + 1, "expected a real clang-format invocation")
	local cmd = commands[#commands]
	assert(cmd[2] == style, vim.inspect(cmd))
	local filename_index = vim.fn.index(cmd, "-assume-filename") + 1
	assert(filename_index > 0, "missing assume-filename argument")
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		name = vim.fs.joinpath(vim.fn.getcwd(), "unnamed_temp.cpp")
	end
	assert(cmd[filename_index + 1] == name, "lost filename context")
	return cmd
end

for _, dir in ipairs({ plain .. "/.git", plain .. "/disabled", styled .. "/.git", nested, underscore }) do
	vim.fn.mkdir(dir, "p")
end
vim.fn.writefile({ "BasedOnStyle: LLVM", "IndentWidth: 2" }, styled .. "/.clang-format")
vim.fn.writefile({ "BasedOnStyle: InheritParentConfig", "IndentWidth: 6" }, nested .. "/.clang-format")
vim.fn.writefile({ "BasedOnStyle: LLVM", "IndentWidth: 3" }, underscore .. "/_clang-format")

local plain_buf = buffer(plain .. "/main file.cpp")
local styled_buf = buffer(styled .. "/main file.cpp")
local nested_buf = buffer(nested .. "/main file.cpp")
local underscore_buf = buffer(underscore .. "/main file.cpp")
setup(plain)

test("fallback remains LLVM with four spaces", function()
	format(plain_buf, 4, fallback)
end)

test("project switch in one process uses the target file, not startup cwd", function()
	format(styled_buf, 2, "-style=file")
	format(plain_buf, 4, fallback)
	format(styled_buf, 2, "-style=file")
end)

test("nested config overrides the project config from an unrelated cwd", function()
	format(nested_buf, 6, "-style=file")
end)

test("underscore config uses clang-format native lookup", function()
	format(underscore_buf, 3, "-style=file")
end)

test("changing cwd does not change a named buffer's style", function()
	vim.api.nvim_set_current_dir(styled)
	format(plain_buf, 4, fallback)
	format(nested_buf, 6, "-style=file")
end)

test("setup in a styled project does not leak LLVM two-space fallback", function()
	setup(styled)
	format(plain_buf, 4, fallback)
end)

test("range formatting keeps filename and byte-range arguments", function()
	local cmd = format(nested_buf, 6, "-style=file", { start = { 1, 0 }, ["end"] = { 5, 1 } })
	assert(vim.list_contains(cmd, "--offset") and vim.list_contains(cmd, "--length"), vim.inspect(cmd))
end)

test("adding and removing a project config is visible on the next invocation", function()
	local path = plain .. "/.clang-format"
	vim.fn.writefile({ "BasedOnStyle: LLVM", "IndentWidth: 5" }, path)
	local ok, err = pcall(format, plain_buf, 5, "-style=file")
	vim.fn.delete(path)
	assert(ok, err)
	format(plain_buf, 4, fallback)
end)

test("config lookup crosses git roots and leaves parent inheritance to clang-format", function()
	local child = styled .. "/child git project"
	vim.fn.mkdir(child .. "/.git", "p")
	format(buffer(child .. "/main.cpp"), 2, "-style=file")
end)

test("nested InheritParentConfig preserves the parent's indentation", function()
	local child = underscore .. "/inherited style"
	vim.fn.mkdir(child, "p")
	vim.fn.writefile({ "BasedOnStyle: InheritParentConfig" }, child .. "/.clang-format")
	format(buffer(child .. "/main.cpp"), 3, "-style=file")
end)

test("user formatter argument table replaces defaults", function()
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 7}"
	setup(plain, { style })
	format(styled_buf, 7, style)
end)

test("user formatter callback receives the real context on every invocation", function()
	local seen = {}
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 8}"
	setup(plain, function(_, ctx)
		seen[#seen + 1] = ctx.filename
		return { style }
	end)
	format(styled_buf, 8, style)
	format(plain_buf, 8, style)
	assert(vim.deep_equal(seen, { vim.api.nvim_buf_get_name(styled_buf), vim.api.nvim_buf_get_name(plain_buf) }))
end)

test("user conform list additions retain last-style precedence", function()
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 9}"
	setup(plain, nil, { formatters = { ["clang-format"] = { prepend_args = { style } } } })
	format(styled_buf, 9, "-style=file")
end)

test("user conform argument-list mutator still receives a table", function()
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 7}"
	setup(plain, nil, {
		formatters = {
			["clang-format"] = {
				prepend_args = function(args)
					assert(type(args) == "table", "user mutator lost the default argument list")
					args[1] = style
					return args
				end,
			},
		},
	})
	format(styled_buf, 7, style)
end)

test("user conform mutator can remove the default argument list", function()
	setup(plain, nil, {
		formatters = {
			["clang-format"] = {
				prepend_args = function()
					return {}
				end,
			},
		},
	})
	format(plain_buf, 2, "-assume-filename")
end)

test("user conform appended arguments do not disable project lookup", function()
	setup(plain, nil, { formatters = { ["clang-format"] = { append_args = { "--sort-includes=false" } } } })
	local cmd = format(styled_buf, 2, "-style=file")
	assert(cmd[#cmd] == "--sort-includes=false", "user append_args was lost")
	format(plain_buf, 4, fallback)
end)

test("user conform full override can replace the formatter", function()
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 8}"
	setup(plain, nil, function(opts)
		opts.formatters["clang-format"] = { prepend_args = { style } }
		return opts
	end)
	format(styled_buf, 8, style)
end)

test("copying user conform options retains dynamic inherited style", function()
	setup(styled, nil, function(opts)
		local copy = vim.deepcopy(opts)
		copy.default_format_opts.timeout_ms = 1500
		return copy
	end)
	assert(conform.default_format_opts.timeout_ms == 1500, "copied timeout override was lost")
	format(styled_buf, 2, "-style=file")
	format(plain_buf, 4, fallback)
	format(nested_buf, 6, "-style=file")
end)

test("copying inherited prepend arguments retains style and non-style additions", function()
	setup(styled, nil, {
		formatters = {
			["clang-format"] = {
				prepend_args = function(args)
					return vim.list_extend(vim.deepcopy(args), { "--sort-includes=false" })
				end,
			},
		},
	})
	local cmd = format(styled_buf, 2, "-style=file")
	assert(cmd[3] == "--sort-includes=false", "copied argument addition was lost")
	format(plain_buf, 4, fallback)
	format(nested_buf, 6, "-style=file")
end)

test("copied inherited arguments can explicitly change the style", function()
	local style = "-style={BasedOnStyle: LLVM, IndentWidth: 7}"
	setup(styled, nil, {
		formatters = {
			["clang-format"] = {
				prepend_args = function(args)
					local copy = vim.deepcopy(args)
					copy[1] = style
					return copy
				end,
			},
		},
	})
	format(styled_buf, 7, style)
end)

test("explicit LLVM four-space replacement is not an inherited default", function()
	setup(styled, nil, function(opts)
		local copy = vim.deepcopy(opts)
		copy.formatters["clang-format"].prepend_args = { fallback }
		return copy
	end)
	format(styled_buf, 4, fallback)
	setup(styled, nil, {
		formatters = {
			["clang-format"] = {
				prepend_args = function()
					return { fallback }
				end,
			},
		},
	})
	format(styled_buf, 4, fallback)
	setup(styled, { fallback })
	format(styled_buf, 4, fallback)
end)

test("explicit LLVM four-space list addition keeps last-style precedence", function()
	setup(styled, nil, { formatters = { ["clang-format"] = { prepend_args = { fallback } } } })
	local cmd = format(styled_buf, 4, "-style=file")
	assert(cmd[3] == fallback, "explicit equal-looking style argument was replaced")
end)

test("save formats the disposable file with its project style", function()
	setup(plain)
	vim.api.nvim_buf_set_lines(styled_buf, 0, -1, false, input)
	vim.api.nvim_buf_call(styled_buf, function()
		vim.cmd.write()
	end)
	assert_lines(styled_buf, expected(2))
	assert(vim.deep_equal(vim.fn.readfile(vim.api.nvim_buf_get_name(styled_buf)), expected(2)))
end)

test("save gates still block global, buffer, filetype and directory formatting", function()
	setup(plain)
	local disabled_buf = buffer(plain .. "/disabled/main.cpp")
	local function save_unformatted(buf)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
		local count = #commands
		vim.api.nvim_buf_call(buf, function()
			vim.cmd.write()
		end)
		assert_lines(buf, input)
		assert(#commands == count, "disabled save invoked clang-format")
	end
	vim.g.disable_autoformat = true
	save_unformatted(styled_buf)
	vim.g.disable_autoformat = false
	vim.b[styled_buf].disable_autoformat = true
	save_unformatted(styled_buf)
	vim.b[styled_buf].disable_autoformat = false
	settings.formatter_block_list.cpp = true
	save_unformatted(styled_buf)
	settings.formatter_block_list.cpp = nil
	save_unformatted(disabled_buf)
	settings.format_on_save = false
	configure()
	save_unformatted(styled_buf)
end)

test("unnamed buffers use Conform's current filename context", function()
	setup(styled)
	local buf = buffer("")
	format(buf, 2, "-style=file")
	vim.api.nvim_set_current_dir(plain)
	format(buf, 4, fallback)
end)

test("manual Format range still works when automatic formatting is disabled", function()
	setup(plain)
	vim.g.disable_autoformat = true
	vim.api.nvim_buf_set_lines(nested_buf, 0, -1, false, input)
	vim.api.nvim_buf_call(nested_buf, function()
		vim.cmd("1,5Format")
	end)
	local completed = vim.wait(3000, function()
		return vim.deep_equal(vim.api.nvim_buf_get_lines(nested_buf, 0, -1, false), expected(6))
	end)
	vim.g.disable_autoformat = false
	assert(completed, "manual range formatting did not finish")
	assert(vim.list_contains(commands[#commands], "--offset"), "manual range was lost")
end)

test("LSP fallback applies edits only when clang-format is unavailable", function()
	setup(plain)
	assert(conform.default_format_opts.timeout_ms == settings.format_timeout, "format timeout changed")
	local requests = 0
	local stopped = false
	local client_id = assert(
		vim.lsp.start({
			name = "runtime_stage4_lsp",
			cmd = function(dispatchers)
				return {
					request = function(method, _, callback)
						local result
						if method == "initialize" then
							result = { capabilities = { documentFormattingProvider = true } }
						elseif method == "textDocument/formatting" then
							requests = requests + 1
							result = {
								{
									range = {
										start = { line = 0, character = 0 },
										["end"] = { line = 5, character = 0 },
									},
									newText = table.concat(expected(3), "\n") .. "\n",
								},
							}
						end
						callback(nil, result)
						return true, 1
					end,
					notify = function()
						return true
					end,
					is_closing = function()
						return stopped
					end,
					terminate = function()
						stopped = true
						dispatchers.on_exit(0, 0)
					end,
				}
			end,
		}, { bufnr = plain_buf }),
		"could not start fixture LSP"
	)
	local ok, err = xpcall(function()
		assert(
			vim.wait(1000, function()
				return #vim.lsp.get_clients({ bufnr = plain_buf, method = "textDocument/formatting" }) == 1
			end),
			"fixture LSP did not initialize"
		)
		format(plain_buf, 4, fallback)
		assert(requests == 0, "LSP ran despite an available formatter")
		conform.formatters["clang-format"].command = "runtime-stage4-no-such-formatter"
		vim.api.nvim_buf_set_lines(plain_buf, 0, -1, false, input)
		local format_error
		conform.format({ bufnr = plain_buf }, function(callback_error)
			format_error = callback_error
		end)
		assert(not format_error, vim.inspect(format_error))
		assert(requests == 1, "LSP fallback was not invoked")
		assert_lines(plain_buf, expected(3))
	end, debug.traceback)
	assert(vim.lsp.get_client_by_id(client_id), "fixture LSP disappeared"):stop(true)
	assert(ok, err)
end)

runner.build_cmd = original_build_cmd
vim.g.disable_autoformat = nil
vim.api.nvim_set_current_dir(original_cwd)
for _, buf in ipairs(buffers) do
	vim.api.nvim_buf_delete(buf, { force = true })
end
vim.fn.delete(fixture, "rf")
if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print(string.format("runtime_stage4_spec: %d tests passed", tests_run))

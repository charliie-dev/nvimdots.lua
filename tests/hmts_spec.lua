local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local fixture = root .. "/tests/fixtures/hmts.nix"
local failures, tests_run = {}, 0
local unloaded_at_setup = false
local unloaded_before_filetype = false

assert(package.loaded.core == nil, "hmts_spec must run before init.lua")
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = function()
		unloaded_at_setup = not require("lazy.core.config").plugins["hmts.nvim"]._.loaded
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nix",
	once = true,
	callback = function()
		unloaded_before_filetype = not require("lazy.core.config").plugins["hmts.nvim"]._.loaded
	end,
})

local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	if ok then
		print("PASS " .. name)
	else
		failures[#failures + 1] = name .. ": " .. err
		print("FAIL " .. name)
	end
end

local function position(text)
	for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		local col = line:find(text, 1, true)
		if col then
			return row - 1, col - 1
		end
	end
	error("fixture text not found: " .. text)
end

local function assert_language(parser, text, expected)
	local row, col = position(text)
	local actual = parser:language_for_range({ row, col, row, col + 1 }):lang()
	assert(actual == expected, text .. ": expected " .. expected .. ", got " .. actual)
end

local function run_tests()
	local plugin = require("lazy.core.config").plugins["hmts.nvim"]
	test("hmts main loads through the initial Nix FileType", function()
		assert(vim.fn.stdpath("config") == root, "wrong configuration checkout")
		assert(vim.api.nvim_buf_get_name(0) == fixture and vim.bo.filetype == "nix", "wrong initial file")
		assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), vim.fn.readfile(fixture)), "fixture changed")
		assert(unloaded_at_setup and unloaded_before_filetype, "hmts was loaded before its FileType trigger")
		assert(plugin._.loaded, "initial Nix FileType did not load hmts")
		assert(plugin.branch == "main", "hmts still tracks the obsolete combined-fixes branch")
		local lock = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazy-lock.json"), "\n"))
		assert(lock["hmts.nvim"].branch == "main", "hmts lockfile still tracks combined-fixes")
		local queries = vim.treesitter.query.get_files("nix", "injections")
		assert(vim.tbl_contains(queries, plugin.dir .. "/queries/nix/injections.scm"), "hmts queries missing")
	end)

	local parser = vim.treesitter.get_parser(0, "nix")
	parser:parse(true)
	test("Home Manager strings create real injected language trees", function()
		assert_language(parser, "local home_value", "lua")
		assert_language(parser, "local nested_value", "lua")
		assert_language(parser, "echo hmts_shell", "bash")
		assert_language(parser, "body {", "css")
		assert_language(parser, "Host hmts-test", "ssh_config")
		assert_language(parser, "local nixvim_value", "lua")
		assert_language(parser, "local annotated_value", "lua")
		for _, lang in ipairs({ "lua", "bash", "css", "ssh_config" }) do
			local child = assert(parser:children()[lang], "missing " .. lang .. " child")
			assert(#child:trees() > 0, lang .. " child was not parsed")
			for _, tree in ipairs(child:trees()) do
				assert(not tree:root():has_error(), lang .. " injection contains parse errors")
			end
		end
	end)

	test("unknown filenames and ordinary Nix remain outside injections", function()
		assert_language(parser, "dynamic_filename_content", "nix")
		assert_language(parser, "ordinary_string", "nix")
	end)

	test("injection language updates after editing the Home Manager filename", function()
		local file_row = position('home.file."probe.lua"')
		local content_row = position("local home_value")
		vim.api.nvim_buf_set_lines(0, file_row, file_row + 1, false, { "  home.file.\"probe.css\".text = ''" })
		vim.api.nvim_buf_set_lines(0, content_row, content_row + 1, false, { "    div { color: blue; }" })
		parser:parse(true)
		assert_language(parser, "div {", "css")
		assert_language(parser, "local nested_value", "lua")
		assert_language(parser, "ordinary_string", "nix")
	end)

	test("Nix startup and injection queries emit no errors", function()
		local messages = vim.api.nvim_exec2("messages", { output = true }).output
		for _, pattern in ipairs({ "Error detected", "Error in", "Failed to source", "Failed to run", "Failed to load" }) do
			assert(not messages:find(pattern, 1, true), messages)
		end
		for _, notification in ipairs(require("snacks.notifier").get_history()) do
			assert(
				notification.level ~= "error" and notification.level ~= vim.log.levels.ERROR,
				vim.inspect(notification)
			)
		end
	end)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			local ok, err = xpcall(run_tests, debug.traceback)
			if not ok then
				failures[#failures + 1] = err
			end
			if #failures > 0 then
				vim.api.nvim_err_writeln(table.concat(failures, "\n"))
				vim.cmd.cquit(1)
			end
			print(string.format("hmts_spec: %d tests passed", tests_run))
			vim.cmd("qa!")
		end, 300)
	end,
})

local augend = require("dial.augend")
require("dial.config").augends:register_group({
	-- default augends used when no group name is specified
	default = {
		augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
		augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
		augend.date.new({
			pattern = "%Y-%m-%d", -- date (2022-02-19, etc.)
			default_kind = "date",
			only_valid = true,
			word = false,
		}),
		augend.date.alias["%Y/%m/%d"],
		augend.constant.alias.bool,
		augend.constant.new({
			elements = { "&&", "||" },

			word = false,
			cyclic = true,
		}),
		augend.constant.new({
			elements = { "and", "or" },
			word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
			cyclic = true, -- "or" is incremented into "and".
		}),
	},
	visual = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.new({
			pattern = "%Y-%m-%d", -- date (2022-02-19, etc.)
			default_kind = "date",
			only_valid = true,
			word = false,
		}),
		augend.date.alias["%Y/%m/%d"],

		augend.constant.alias.alpha, -- Lowercase alphabet letter (word)
		augend.constant.alias.Alpha, -- Uppercase alphabet letter (word)
		augend.constant.alias.bool,
		augend.constant.new({
			elements = { "&&", "||" },

			word = false,
			cyclic = true,
		}),
		augend.constant.new({
			elements = { "and", "or" },
			word = true,
			cyclic = true,
		}),
	},
})

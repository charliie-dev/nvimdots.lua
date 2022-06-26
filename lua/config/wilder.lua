local status_ok, wilder = pcall(require, "wilder")
if not status_ok then
	return
end

-- Disable Python remote plugin, since only use romgrk/fzy-lua-native
wilder.set_option('use_python_remote_plugin', 0)

wilder.setup({
	modes = { ":", "/", "?" },
	enable_cmdline_enter = true,
})

wilder.set_option("pipeline", {
	wilder.branch(
		wilder.cmdline_pipeline({
      language = 'vim',
			fuzzy = 1,
      fuzzy_filter = wilder.lua_fzy_filter(),
		}),
    wilder.vim_search_pipeline()
	),
})

local highlighters = {
  wilder.lua_fzy_highlighter(),
  wilder.basic_highlighter(),
}

local popupmenu_renderer = wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme({
    border = 'rounded',
    highlights = {
      border = 'Normal', -- highlight to use for the border
      -- accent = wilder.make_hl('WilderAccent', 'Pmenu', {{a = 1}, {a = 1}, {foreground = '#f4468f'}}),
      accent = wilder.make_hl('WilderAccent', 'Pmenu', {{a = 1}, {a = 1}, {foreground = '#52ab43'}}),
    },
    empty_message = wilder.popupmenu_empty_message_with_spinner(),
    highlighter = highlighters,
    left = {
      '',
      wilder.popupmenu_devicons(),
      -- wilder.popupmenu_buffer_flags({
      --   flags = ' a + ',
      --   icons = {['+'] = '', a = '', h = ''},
      -- }),
    },
    right = {
      ' ',
      wilder.popupmenu_scrollbar(),
    },
  })
)

local wildmenu_renderer = wilder.wildmenu_renderer({
  highlighter = highlighters,
  separator = ' · ',
  left = {' ', wilder.wildmenu_spinner(), ' '},
  right = {' ', wilder.wildmenu_index()},
})

wilder.set_option('renderer', wilder.renderer_mux({
  [':'] = popupmenu_renderer,
  ['/'] = wildmenu_renderer,
  substitute = wildmenu_renderer,
  pumblend = 20,
}))

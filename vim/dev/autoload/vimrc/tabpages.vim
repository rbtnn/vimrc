
function! vimrc#tabpages#expr(is_tabsidebar) abort
	try
		let hl_lbl = a:is_tabsidebar ? '%#Label#' : ''
		let hl_sel = a:is_tabsidebar ? '%#TabSideBarSel#' : '%#TabLineSel#'
		let hl_def = a:is_tabsidebar ? '%#TabSideBar#' : '%#TabLine#'
		let hl_fil = a:is_tabsidebar ? '%#TabSideBarFill#' : '%#TabLineFill#'
		let hl_alt = a:is_tabsidebar ? '%#PreProc#' : ''
		let lines = []
		for tnr in range(1, tabpagenr('$'))
			if a:is_tabsidebar && (tnr != get(g:, 'actual_curtabpage', tabpagenr()))
				continue
			endif
			if a:is_tabsidebar
				let lines += ['', hl_lbl .. '--- ' .. tnr .. ' ---' .. hl_def]
			else
				let lines += [(tnr == tabpagenr() ? hl_sel : hl_def) .. '<Tab.' .. tnr .. '> ']
			endif
			for x in filter(getwininfo(), { i, x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid'])) })
				let ft = getbufvar(x['bufnr'], '&filetype')
				let bt = getbufvar(x['bufnr'], '&buftype')
				let is_curwin = (tnr == tabpagenr()) && (x['winnr'] == winnr())
				let is_altwin = (tnr == tabpagenr()) && (x['winnr'] == winnr('#'))
				let text =
					\ (is_curwin
					\   ? hl_sel .. '(%%)'
					\   : (is_altwin
					\       ? hl_alt .. '(#)'
					\       : (hl_def .. '(' .. x['winnr'] .. ')')))
					\ .. ' '
					\ .. (!empty(bt)
					\      ? printf('[%s]', bt == 'nofile' ? ft : bt)
					\      : (empty(bufname(x['bufnr']))
					\          ? '[No Name]'
					\          : fnamemodify(bufname(x['bufnr']), ':t')))
				let lines += [text]
			endfor
		endfor
		if !a:is_tabsidebar
			let lines += [hl_fil]
		endif
		return join(lines, a:is_tabsidebar ? "\n" : ' ')
	catch
		let g:tab_throwpoint = v:throwpoint
		let g:tab_exception = v:exception
		return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
	endtry
endfunction

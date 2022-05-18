
let g:loaded_tabsidebar = 1

if has('tabsidebar')
	function! TabSideBar() abort
		try
			let tnr = get(g:, 'actual_curtabpage', tabpagenr())
			let lines = ['', printf('%s- Tab %d -%s', '%#TabSideBarLabel#', tnr, '%#TabSideBar#')]
			for x in filter(getwininfo(), { i, x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid'])) })
				let ft = getbufvar(x['bufnr'], '&filetype')
				let bt = getbufvar(x['bufnr'], '&buftype')
				let current = (tnr == tabpagenr()) && (x['winnr'] == winnr())
				let high = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
				let fname = fnamemodify(bufname(x['bufnr']), ':t')
				if exists('*WebDevIconsGetFileTypeSymbol') && (&guifont =~# '^Cica')
					let fname = (current ? '%#TabSideBarIcon#' : '') .. WebDevIconsGetFileTypeSymbol(fname) .. high .. fname
				endif
				let lines += [
					\    high
					\ .. ' '
					\ .. (!empty(bt)
					\      ? printf('[%s]', bt == 'nofile' ? ft : bt)
					\      : (empty(bufname(x['bufnr']))
					\          ? '[No Name]'
					\          : fname))
					\ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
					\ ]
			endfor
			return join(lines, "\n")
		catch
			let g:tab_throwpoint = v:throwpoint
			let g:tab_exception = v:exception
			return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
		endtry
	endfunction
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!TabSideBar()
	set tabsidebarcolumns=20
	for s:name in ['TabSideBar', 'TabSideBarFill', 'TabSideBarSel']
		if !hlexists(s:name)
			execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
		endif
	endfor
endif


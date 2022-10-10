
if !has('vim9script')
	finish
endif

vim9script

g:loaded_tabsidebar = 1

if has('tabsidebar')
	def TabSideBar(): string
		try
			var tnr = get(g:, 'actual_curtabpage', tabpagenr())
			var lines = []

			if tnr == 1
				const qfinfo = getqflist({ 'nr': 0, 'size': 0, 'idx': 0 })
				if 0 < qfinfo['nr']
					lines += ['', printf('%s- QuickFix -%s', '%#TabSideBarLabel#', '%#TabSideBar#')]
					lines += [printf(' %d/%d', qfinfo['idx'], qfinfo['size'])]
				endif
				lines += ['', printf('%s- TabPage -%s', '%#TabSideBarLabel#', '%#TabSideBar#')]
			endif

			lines += ['', printf('%s(%d)', '%#TabSideBar#', tnr)]
			for x in filter(getwininfo(), (i, x) => tnr == x['tabnr'] && ('popup' != win_gettype(x['winid'])))
				var ft = getbufvar(x['bufnr'], '&filetype')
				var bt = getbufvar(x['bufnr'], '&buftype')
				var current = (tnr == tabpagenr()) && (x['winnr'] == winnr())
				var high = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
				var fname = fnamemodify(bufname(x['bufnr']), ':t')
				lines += [
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
			g:tab_throwpoint = v:throwpoint
			g:tab_exception = v:exception
			return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
		endtry
	enddef
	g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebarcolumns=20
	&tabsidebar = '%!' .. expand('<SID>') .. 'TabSideBar()'
	for name in ['TabSideBar', 'TabSideBarFill', 'TabSideBarSel']
		if !hlexists(name)
			execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', name)
		endif
	endfor
endif


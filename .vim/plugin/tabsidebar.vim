
let g:loaded_tabsidebar = 1

if !has('tabsidebar')
	finish
endif

function! Tabsidebar() abort
	try
		let lines = ['%#TabSideBarTitle#', repeat('=', &tabsidebarcolumns)]
			\ + [g:actual_curtabpage .. '. ' .. fnamemodify(getcwd(tabpagewinnr(g:actual_curtabpage), g:actual_curtabpage), ':~')]
			\ + [repeat('=', &tabsidebarcolumns)]
		for w in filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
			let hi = (win_getid() == w.winid) ? 'TabSideBarSel' : 'TabSideBar'
			try
				let x = vimrc#label#string(w.winid)
			catch
				let x = bufname(w.bufnr)
				if filereadable(x)
					let x = fnamemodify(x, ':t')
				endif
			endtry
			let lines += [printf('  %%#%s#%s', hi, x)]
		endfor
		return join(lines, "\n")
	catch
		return v:exception
	endtry
endfunction

function! TabsidebarSetting() abort
	let &tabsidebarcolumns = 20
	if &tabsidebarcolumns * 4 < &columns
		set showtabsidebar=2
		set tabsidebarwrap
		set notabsidebaralign
		set tabsidebar=%!Tabsidebar()
		wincmd =
	else
		let &tabsidebarcolumns = 0
		set showtabsidebar=0
	endif
endfunction

augroup tabsidebar
	autocmd!
	autocmd VimEnter,VimResized * :call TabsidebarSetting()
augroup END

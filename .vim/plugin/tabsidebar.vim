
let g:loaded_tabsidebar = 1

if !has('tabsidebar')
	finish
endif

function! Tabsidebar() abort
	try
		let lines = []
		for w in filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
			let hi = (win_getid() == w.winid) ? 'TabSideBarSel' : 'TabSideBar'
			let x = bufname(w.bufnr)
			if filereadable(x)
				let x = printf('%s%s%s', (getbufvar(w.bufnr, '&readonly') ? "[R]" : ""), (getbufvar(w.bufnr, '&modified') ? "[+]" : ""), fnamemodify(x, ':t'))
			elseif w.quickfix
				let x = '[Quickfix]'
			elseif w.loclist
				let x = '[Loclist]'
			elseif w.terminal
				let x = '[Terminal]'
			elseif !empty(getcmdwintype()) && (w.tabnr == tabpagenr()) && (w.winnr == winnr())
				let x = '[CmdLineWindow]'
			else
				let ft = getbufvar(w.bufnr, '&filetype')
				let x = printf('[%s]', empty(ft) ? "No Name" : ft)
			endif
			let tablabel = (1 == w.winnr) ? '%#TabSideBarTitle#(' .. g:actual_curtabpage .. ') ' : '    '
			let lines += [printf('%s%%#%s#%s', tablabel, hi, x)]
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


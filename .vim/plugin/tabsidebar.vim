
let g:loaded_tabsidebar = 1

if !has('tabsidebar')
    finish
endif

function! Tabsidebar() abort
    try
        let lines = ['%#TabSideBar#', repeat('=', &tabsidebarcolumns)]
        let lines += split(printf('%s', fnamemodify(getcwd(1, g:actual_curtabpage), ':.')), printf('.\{%d}\zs', &tabsidebarcolumns))
        let lines += [repeat('=', &tabsidebarcolumns)]
        for w in filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
            let hi = (win_getid() == w.winid) ? 'TabSideBarSel' : 'TabSideBar'
            try
                let x = vimrc#label#string(w.winid)
            catch
                let x = bufname(w.bufnr)
            endtry
            let lines += [printf('  %%#%s#%s', hi, x)]
        endfor
        let lines += ['%#TabSideBarUnderline#']
        return join(lines, "\n")
    catch
        return string(v:exception)
    endtry
endfunction

function! TabsidebarSetting() abort
    let &tabsidebarcolumns = 28
    if &tabsidebarcolumns * 4 < &columns
        set showtabsidebar=2
        set notabsidebarwrap
        set notabsidebaralign
        set tabsidebar=%!Tabsidebar()
    else
        let &tabsidebarcolumns = 0
        set showtabsidebar=0
    endif
endfunction

augroup tabsidebar
    autocmd!
    autocmd VimEnter,VimResized * :call TabsidebarSetting()
augroup END


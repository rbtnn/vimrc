
let g:loaded_tabsidebar = 1

if !has('tabsidebar')
    finish
endif

function! Tabsidebar() abort
    try
        let s = printf('[%d/%d]', g:actual_curtabpage, tabpagenr('$'))
        let lines = [printf('%%#TabSideBar#%s%s', repeat(' ', &tabsidebarcolumns - len(s)), s)]
        for w in filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
            let hi = (win_getid() == w.winid) ? 'TabSideBarSel' : 'TabSideBar'
            try
                let x = label#string(w.winid)
            catch
                let x = bufname(w.bufnr)
            endtry
            let lines += [printf(' %%#%s#%s', hi, x)]
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
        set showtabsidebar=0
    endif
endfunction

augroup tabsidebar
    autocmd!
    autocmd VimEnter,VimResized * :call TabsidebarSetting()
augroup END


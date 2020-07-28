
let g:loaded_tabsidebar = 1

if !has('tabsidebar') && !get(g:, 'tabsidebar_disabled', 0)
    finish
endif

silent! runtime autoload/nerdfont.vim

function! s:display_string(wininfo, iscurr) abort
    let name = bufname(a:wininfo.bufnr)
    let s = '[No Name]'
    if a:wininfo.terminal
        let s = printf('[Terminal](%s)', term_getstatus(a:wininfo.bufnr))
    elseif a:wininfo.quickfix
        let s = '[QuickFix]'
    elseif a:wininfo.loclist
        let s = '[LocList]'
    elseif a:iscurr && !empty(getcmdwintype())
        let s = '[CmdLineWindow]'
    elseif 'diff' == getbufvar(a:wininfo.bufnr, '&filetype')
        let s = '[Diff]'
    elseif !empty(name)
        let modi = getbufvar(a:wininfo.bufnr, '&modified')
        let read = getbufvar(a:wininfo.bufnr, '&readonly')
        if filereadable(name)
            let name = fnamemodify(name, ':t')
        endif
        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
    endif
    if exists('*nerdfont#find')
        let s = nerdfont#find(name) .. ' ' .. s
    endif
    return s
endfunction

function! Tabsidebar() abort
    try
        let wins = filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
        let s = printf('[%d/%d]', g:actual_curtabpage, tabpagenr('$'))
        let lines = [printf('%%#TabSideBar#%s%s', repeat(' ', &tabsidebarcolumns - len(s)), s)]
        for n in range(1, len(wins))
            let iscurr = (winnr() == wins[n - 1].winnr) && (g:actual_curtabpage == tabpagenr())
            let lines += [printf('%%#%s#%s', (iscurr ? 'TabSideBarSel' : 'TabSideBar'), s:display_string(wins[n - 1], iscurr))]
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


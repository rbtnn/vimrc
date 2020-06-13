
scriptencoding utf-8

if !has('tabsidebar')
    finish
endif

function! Tabsidebar() abort
    try
        let lines = []
        let lines += [printf('%%#TabSideBar#TabPage %d/%d', g:actual_curtabpage, tabpagenr('$'))]
        for x in getwininfo()
            if x.tabnr == g:actual_curtabpage
                let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                let name = bufname(x.bufnr)
                let s = '[No Name]'
                if x.terminal
                    let s = printf('[Terminal](%s)', term_getstatus(x.bufnr))
                elseif x.quickfix
                    let s = '[QuickFix]'
                elseif x.loclist
                    let s = '[LocList]'
                elseif iscurr && !empty(getcmdwintype())
                    let s = '[CmdLineWindow]'
                elseif 'diff' == getbufvar(x.bufnr, '&filetype')
                    let s = '[Diff]'
                elseif !empty(name)
                    let modi = getbufvar(x.bufnr, '&modified')
                    let read = getbufvar(x.bufnr, '&readonly')
                    if filereadable(name)
                        let name = fnamemodify(name, ':t')
                    endif
                    let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                endif
                let icon = iscurr ? '▶' : '  '
                let lines += [printf('%%#TabSideBar# %s %s', icon, s)]
            endif
        endfor
        return join(lines, "\n")
    catch
        return string(v:exception)
    endtry
endfunction

function! TabsidebarSetting() abort
    let &tabsidebarcolumns = 30
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


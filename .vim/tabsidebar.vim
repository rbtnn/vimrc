
if has('vimscript-4')
    scriptversion 4
else
    finish
endif
scriptencoding utf-8

if has('tabsidebar')
    function! Tabsidebar() abort
        try
            let lines = []
            let lines += [printf('%%#%s#TabPage %d',
                \ ((g:actual_curtabpage == tabpagenr()) ? 'TabSideBarTitleSel' : 'TabSideBarTitle'),
                \ g:actual_curtabpage)]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                    let name = bufname(x.bufnr)
                    let s = '(No Name)'
                    if x.terminal
                        let s = '(Terminal)'
                    elseif x.quickfix
                        let s = '(QuickFix)'
                    elseif x.loclist
                        let s = '(LocList)'
                    elseif iscurr && !empty(getcmdwintype())
                        let s = '(CmdLineWindow)'
                    elseif filereadable(name)
                        let modi = getbufvar(x.bufnr, '&modified')
                        let read = getbufvar(x.bufnr, '&readonly')
                        let name = fnamemodify(name, ':t')
                        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                    else
                        if empty(name)
                            let type = getbufvar(x.bufnr, '&filetype')
                            if 'diff' == type
                                let s = '(Diff)'
                            endif
                        else
                            let s = name
                        endif
                    endif
                    let lines += [printf('%%#%s# %s%s', (iscurr ? 'TabSideBarSel' : 'TabSideBar'), (iscurr ? '▶' : '  '), s)]
                endif
            endfor
            return join(lines, "\n")
        catch
            return string(v:exception)
        endtry
    endfunction
    augroup tabsidebar
        autocmd!
        autocmd VimEnter,VimResized *
            \ :let &tabsidebarcolumns = 16
            \ |if v:servername == 'MINIMAP'
            \ |  set showtabsidebar=0
            \ |elseif &tabsidebarcolumns * 4 < &columns
            \ |  set showtabsidebar=2
            \ |  set notabsidebaralign
            \ |  set notabsidebarwrap
            \ |  set tabsidebar=%!Tabsidebar()
            \ |else
            \ |  set showtabsidebar=0
            \ |endif
    augroup END
endif


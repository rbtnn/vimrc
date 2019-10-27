
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
            let lines += [printf('%%#%s#-TabPage %d-', 'TabSideBarTitle', g:actual_curtabpage)]
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
                    let lines += [printf(' %%#%s#%s%s', (iscurr ? 'TabSideBarSel' : 'TabSideBar'), (iscurr ? '▶' : '  '), s)]
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
                \ :if 10 < &columns / 8
                \ |  set showtabsidebar=2
                \ |  set notabsidebaralign
                \ |  set notabsidebarwrap
                \ |  set tabsidebar=%!Tabsidebar()
                \ |  let &tabsidebarcolumns = &columns / 8
                \ |else
                \ |  set showtabsidebar=0
                \ |endif
    augroup END
endif


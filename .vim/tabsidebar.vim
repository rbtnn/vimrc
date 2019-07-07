
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

if has('tabsidebar')
    function! Tabsidebar() abort
        try
            const t = (g:actual_curtabpage == tabpagenr()) ? 'TabSideBarSel' : 'TabSideBar'
            if 1 == g:actual_curtabpage
                let g:tabsidebar_count = get(g:, 'tabsidebar_count', 0) + 1
                let lines = [printf('+%d+', g:tabsidebar_count)]
            else
                let lines = []
            endif
            let lines += [printf('%%#%s#-TABPAGE %d-', t, g:actual_curtabpage)]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                    let s = '(No Name)'
                    if x.terminal
                        let s = '(Terminal)'
                    elseif x.quickfix
                        let s = '(QuickFix)'
                    elseif x.loclist
                        let s = '(LocList)'
                    elseif iscurr && !empty(getcmdwintype())
                        let s = '(CmdLineWindow)'
                    elseif filereadable(bufname(x.bufnr))
                        let modi = getbufvar(x.bufnr, '&modified')
                        let read = getbufvar(x.bufnr, '&readonly')
                        let name = fnamemodify(bufname(x.bufnr), ':t')
                        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                    else
                        let sline = getwinvar(x.winnr, '&statusline')
                        let ft = getbufvar(x.bufnr, '&filetype')
                        if !empty(sline)
                            let s = sline
                        elseif !empty(ft)
                            let s = printf('[%s]', ft)
                        endif
                    endif
                    let lines += [printf('  %s %s', (iscurr ? '*' : ' '), s)]
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
                \ |  set showtabsidebar=1
                \ |  set tabsidebaralign
                \ |  set notabsidebarwrap
                \ |  set tabsidebar=%!Tabsidebar()
                \ |  let &tabsidebarcolumns = &columns / 8
                \ |else
                \ |  set showtabsidebar=0
                \ |endif
    augroup END
endif


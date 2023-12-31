
if has('tabsidebar')
    function! s:nerdfontfind(fname, high_nerd, high_tab) abort
        try
            if get(g:, 'nerdfont_notfound', 0)
                return ''
            else
                return a:high_nerd .. nerdfont#find(a:fname) .. a:high_tab
            endif
        catch
            let g:nerdfont_notfound = 1
            return ''
        endtry
    endfunction

    function! TabSideBar() abort
        try
            let tnr = get(g:, 'actual_curtabpage', tabpagenr())
            let lines = []
            let lines += [tnr == tabpagenr() ? '%#TabSideBarCurTab#' : '%#TabSideBar#']
            for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
                let ft = getbufvar(x['bufnr'], '&filetype')
                let bt = getbufvar(x['bufnr'], '&buftype')
                let high_nerd = tnr == tabpagenr()
                    \ ? '%#TabSideBarCurrNerdFont#'
                    \ : '%#TabSideBarNerdFont#'
                let high_tab = tnr == tabpagenr()
                    \ ? (x['winnr'] == winnr()
                    \   ? '%#TabSideBarCurTabSel#'
                    \   : '%#TabSideBarCurTab#')
                    \ : '%#TabSideBar#'
                let fname = fnamemodify(bufname(x['bufnr']), ':t')
                let lines += [
                    \    high_tab
                    \ .. ' '
                    \ .. s:nerdfontfind(fname, high_nerd, high_tab)
                    \ .. ' '
                    \ .. (getbufvar(x['bufnr'], '&readonly') && empty(bt) ? '[R]' : '')
                    \ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
                    \ .. (!empty(bt)
                    \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
                    \      : (empty(bufname(x['bufnr']))
                    \          ? '[No Name]'
                    \          : fname))
                    \ ]
            endfor
            let lines += ['']
            return join(lines, "\n")
        catch
            return v:exception
        endtry
    endfunction
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=20
    set tabsidebar=%!TabSideBar()
    for s:name in [
        \ 'TabSideBar',
        \ 'TabSideBarCurTab',
        \ 'TabSideBarCurTabSel',
        \ 'TabSideBarCurrNerdFont',
        \ 'TabSideBarFill',
        \ 'TabSideBarNerdFont',
        \ ]
        if !hlexists(s:name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
        endif
    endfor
endif


if has('tabsidebar')
    function! s:TabSideBarLabel(text) abort
        let rest = &tabsidebarcolumns - len(a:text)
        if rest < 0
            let rest = 0
        endif
        return repeat(' ', rest / 2) .. a:text .. repeat(' ', rest / 2 + (rest % 2))
    endfunction

    function! TabSideBar() abort
        let tnr = get(g:, 'actual_curtabpage', tabpagenr())
        let lines = []
        let lines += [(tnr == tabpagenr() ? '%#TabSideBarCurTabLabel#' : '%#TabSideBarLabel#') .. '', s:TabSideBarLabel(printf(' TABPAGE %d ', tnr)), '']
        for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
            let ft = getbufvar(x['bufnr'], '&filetype')
            let bt = getbufvar(x['bufnr'], '&buftype')
            let high1 = tnr == tabpagenr()
                \ ? (x['winnr'] == winnr()
                \   ? '%#TabSideBarCurTabSel#'
                \   : '%#TabSideBarCurTab#')
                \ : '%#TabSideBar#'
            let fname = fnamemodify(bufname(x['bufnr']), ':t')
            let lines += [
                \    high1
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
    endfunction
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for s:name in ['TabSideBar', 'TabSideBarLabel', 'TabSideBarCurTab', 'TabSideBarCurTabSel', 'TabSideBarCurTabLabel', 'TabSideBarFill']
        if !hlexists(s:name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
        endif
    endfor
endif


if has('tabsidebar')
    function! s:TabSideBarLabel(text) abort
        let rest = &tabsidebarcolumns - len(a:text)
        if rest < 0
            let rest = 0
        endif
        return '%#TabSideBarLabel#' .. repeat(' ', rest / 2) .. a:text .. repeat(' ', rest / 2 + (rest % 2)) .. '%#TabSideBar#'
    endfunction

    function! TabSideBar() abort
        let tnr = get(g:, 'actual_curtabpage', tabpagenr())
        let lines = []
        let lines += ['', s:TabSideBarLabel(printf(' TABPAGE %d ', tnr)), '']
        for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
            let ft = getbufvar(x['bufnr'], '&filetype')
            let bt = getbufvar(x['bufnr'], '&buftype')
            let current = (tnr == tabpagenr()) && (x['winnr'] == winnr())
            let high1 = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
            let high2 = '%#TabSideBarModified#'
            let fname = fnamemodify(bufname(x['bufnr']), ':t')
            let lines += [
                \    high1
                \ .. ' '
                \ .. (!empty(bt)
                \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
                \      : (empty(bufname(x['bufnr']))
                \          ? '[No Name]'
                \          : fname))
                \ .. high2
                \ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
                \ ]
        endfor
        return join(lines, "\n")
    endfunction
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for name in ['TabSideBar', 'TabSideBarFill', 'TabSideBarSel']
        if !hlexists(name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', name)
        endif
    endfor
endif

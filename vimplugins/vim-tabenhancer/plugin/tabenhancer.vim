
let g:loaded_tabenhancer = 1

if has('timers') && exists(':redrawtabline')
    set showtabline=2
    set tabline=%!TabLine()
    function! s:vim_version() abort
        return  printf('Vim 8.1.%04s', substitute(split(execute('version'), "\n")[2], 'Included patches: 1-', '', ''))
    endfunction
    function! TabLine() abort
        try
            let weeks = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][strftime('%w')]
            let date = strftime('%Y/%m/%d')
            let time = strftime('%H:%M:%S')
            let s = printf('[%s] %s(%s) %s', s:vim_version(), date, weeks, time)
            let tsbcolumns = 0
            if has('tabsidebar')
                if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
                    let tsbcolumns = &tabsidebarcolumns
                endif
            endif
            let padding = repeat(' ', (&columns - len(s)) / 2 - tsbcolumns)
            return printf('%s%%#TabLineSel#%s', padding, s)
        catch
            return string(v:exception)
        endtry
    endfunction
    function! TabLineHandler(timer) abort
        " Not redraw during prompting.
        if mode() !~# 'r'
            redrawtabline
        endif
    endfunction
    if !exists('s:timer_tabline')
        let s:timer_tabline = timer_start(1000, 'TabLineHandler', { 'repeat' : -1, })
    endif
endif

if has('tabsidebar')
    set showtabsidebar=2
    set tabsidebarcolumns=20
    set tabsidebarwrap
    set tabsidebar=%!TabSideBar()
    function! TabSideBar() abort
        try
            if g:actual_curtabpage == tabpagenr()
                let t = 'TabSideBarSel'
            else
                let t = 'TabSideBar'
            endif
            let lines = ['']
            let s = printf('TABPAGE %d', g:actual_curtabpage)
            let rest = &tabsidebarcolumns - len(s) - 2
            let lines += [printf('%%#%s#%s|%s|%s', t,
                    \ repeat('=', rest / 2),
                    \ s,
                    \ repeat('=', rest / 2 + (rest % 2)))]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let s = '(No Name)'
                    if x.terminal
                        let s = '(Terminal)'
                    elseif x.quickfix
                        let s = '(QuickFix)'
                    elseif x.loclist
                        let s = '(LocList)'
                    elseif filereadable(bufname(x.bufnr))
                        let modi = getbufvar(x.bufnr, '&modified')
                        let read = getbufvar(x.bufnr, '&readonly')
                        let name = fnamemodify(bufname(x.bufnr), ':t')
                        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                    else
                        let ft = getbufvar(x.bufnr, '&filetype')
                        if !empty(ft)
                            let s = printf('[%s]', ft)
                        endif
                    endif
                    let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                    let lines += [printf('%s %s', (iscurr ? '>' : ' '), s)]
                endif
            endfor
            return join(lines, "\n")
        catch
            return string(v:exception)
        endtry
    endfunction
endif


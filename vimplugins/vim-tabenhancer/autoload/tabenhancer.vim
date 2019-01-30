
let s:vim_version = ''

function! tabenhancer#init() abort
    if has('timers') && exists(':redrawtabline')
        set showtabline=2
        set tabline=%!tabenhancer#tabline()
        if !exists('s:tabenhancer_timer')
            let s:tabenhancer_timer = timer_start(1000, 'tabenhancer#tabline_handler', { 'repeat' : -1, })
        endif
    endif
    if has('tabsidebar')
        set showtabsidebar=2
        set tabsidebarcolumns=20
        set tabsidebarwrap
        set tabsidebar=%!tabenhancer#tabsidebar()
    endif
endfunction

function! tabenhancer#vim_version() abort
    if empty(s:vim_version)
        let lines = split(execute('version'), "\n")
        let vimver = matchstr(lines[0], '^VIM - Vi IMproved \zs\d\+\.\d\+\ze')
        let patches = substitute(lines[2], 'Included patches: 1-', '', '')
        let s:vim_version = printf('Vim %s.%04s', vimver, patches)
    endif
    return s:vim_version
endfunction

function! tabenhancer#tabline() abort
    try
        let weeks = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][strftime('%w')]
        let date = strftime('%Y/%m/%d')
        let time = strftime('%H:%M:%S')
        let s = printf('[%s] %s(%s) %s', tabenhancer#vim_version(), date, weeks, time)
        let tsbcolumns = 0
        if has('tabsidebar')
            if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
                let tsbcolumns = &tabsidebarcolumns
            endif
        endif
        let padding = repeat(' ', (&columns - len(s)) / 2 - tsbcolumns)
        return printf('%%#Underlined#%s%s', padding, s)
    catch
        return string(v:exception)
    endtry
endfunction

function! tabenhancer#tabline_handler(timer) abort
    " Not redraw during prompting.
    if mode() !~# 'r'
        redrawtabline
    endif
endfunction

function! tabenhancer#tabsidebar() abort
    try
        let t = (g:actual_curtabpage == tabpagenr()) ? 'TabSideBarSel' : 'TabSideBar'
        let lines = ['']
        let s = printf('[TABPAGE %d]', g:actual_curtabpage)
        let lines += [printf('%%#%s#%s', t, s)]
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
                let lines += [printf('  %s %s', (iscurr ? '*' : ' '), s)]
            endif
        endfor
        return join(lines, "\n")
    catch
        return string(v:exception)
    endtry
endfunction

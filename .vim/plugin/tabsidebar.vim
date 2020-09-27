
let g:loaded_tabsidebar = 1

if !has('tabsidebar')
    finish
endif

silent! runtime autoload/nerdfont.vim
silent! runtime autoload/nerdfont_palette/defaults/palette.vim

let s:tsb_guibg = matchstr(trim(execute('highlight TabSideBar', 'silent!')), 'guibg=\S\+')
let s:tsbsel_guibg = matchstr(trim(execute('highlight TabSideBarSel', 'silent!')), 'guibg=\S\+')
let s:tsb_ctermbg = matchstr(trim(execute('highlight TabSideBar', 'silent!')), 'ctermbg=\S\+')
let s:tsbsel_ctermbg = matchstr(trim(execute('highlight TabSideBarSel', 'silent!')), 'ctermbg=\S\+')

function! s:with_icon(s, name, ft, highlight_name) abort
    let s = a:s
    let icon = ''
    let hl = '%#' .. a:highlight_name .. '#'
    if exists('*nerdfont#find')
        let icon = nerdfont#find(a:name)
        let ext = fnamemodify(a:name, ':t:e')
        if exists('g:nerdfont_palette#defaults#palette')
            for key in keys(g:nerdfont_palette#defaults#palette)
                if (-1 != index(g:nerdfont_palette#defaults#palette[key], ext)) || (-1 != index(g:nerdfont_palette#defaults#palette[key], a:ft))
                    if a:highlight_name == 'TabSideBar'
                        silent! execute printf('highlight %s %s %s', key, s:tsb_guibg, s:tsb_ctermbg)
                    elseif a:highlight_name == 'TabSideBarSel'
                        silent! execute printf('highlight %s %s %s', key, s:tsbsel_guibg, s:tsbsel_ctermbg)
                    endif
                    let hl = '%#' .. key .. '#'
                endif
            endfor
        endif
    endif
    return printf(' %s%s%%#%s#%s', hl, icon, a:highlight_name, s)
endfunction

function! s:display_string(wininfo, iscurr) abort
    let name = bufname(a:wininfo.bufnr)
    let ft = getbufvar(a:wininfo.bufnr, '&filetype')
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
    elseif 'diffy' == getbufvar(a:wininfo.bufnr, '&filetype')
        let s = '[Diffy]'
    elseif !empty(name)
        let modi = getbufvar(a:wininfo.bufnr, '&modified')
        let read = getbufvar(a:wininfo.bufnr, '&readonly')
        if filereadable(name)
            let name = fnamemodify(name, ':t')
        endif
        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
    endif
    return s:with_icon(s, name, ft, a:iscurr ? 'TabSideBarSel' : 'TabSideBar')
endfunction

function! Tabsidebar() abort
    try
        let wins = filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
        let s = printf('[%d/%d]', g:actual_curtabpage, tabpagenr('$'))
        let lines = [printf('%%#TabSideBar#%s%s', repeat(' ', &tabsidebarcolumns - len(s)), s)]
        for n in range(1, len(wins))
            let iscurr = (winnr() == wins[n - 1].winnr) && (g:actual_curtabpage == tabpagenr())
            let lines += [(s:display_string(wins[n - 1], iscurr))]
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


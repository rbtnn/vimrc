
let g:loaded_develop_toggleterminal = 1
let s:term_cmd = [&shell]

if has('win32') && executable('wmic') && has('gui_running')
    function! s:outcb(ch, mes) abort
        if 14393 < str2nr(trim(a:mes))
            let s:term_cmd = ['cmd.exe', '/k', 'doskey pwd=cd && doskey ls=dir /b && set prompt=$E[32m$$$E[0m']
        endif
    endfunction
    call job_start('wmic os get BuildNumber', { 'out_cb': function('s:outcb'), })
endif

function! s:hide_term_list() abort
    let xs = term_list()
    let showterms = map(filter(getwininfo(), { i,x -> x['terminal'] }), { i,x -> x['bufnr'] })
    call filter(xs, { _, x -> (-1 == index(showterms, x)) && ('finished' != term_getstatus(x)) })
    return xs
endfunction

function! s:get_winid_of_popupwinterm() abort
    for winid in popup_list()
        if get(getwininfo(winid), 0, { 'terminal' : v:false })['terminal']
            return winid
        endif
    endfor
    return 0
endfunction

function! s:toggle_terminal() abort
    let winid = s:get_winid_of_popupwinterm()
    if 0 < winid
        call popup_close(winid)
    else
        if utils#popupwin#check_able_to_open('toggle-terminal')
            let xs = s:hide_term_list()
            if !empty(xs)
                let bnr = xs[0]
            else
                let bnr = term_start(s:term_cmd, {
                    \   'hidden' : 1,
                    \   'term_highlight' : 'Terminal',
                    \   'term_finish' : 'close',
                    \   'term_kill' : 'kill',
                    \ })
            endif
            let opts = {}
            call popup_create(bnr, opts)
            call utils#popupwin#set_options(v:false)
        endif
    endif
endfunction

command! -nargs=0 ToggleTerminal   :call s:toggle_terminal()

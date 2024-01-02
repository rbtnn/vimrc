
let g:loaded_develop_quickterm = 1

function! s:term_list() abort
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
        let xs = s:term_list()
        if !empty(xs)
            let bnr = xs[0]
        else
            let bnr = term_start(&shell, {
                \   'hidden' : 1,
                \   'term_highlight' : 'Terminal',
                \   'term_finish' : 'close',
                \   'term_kill' : 'term',
                \ })
        endif
        let opts = {}
        call utils#popupwin#apply_size(opts)
        call utils#popupwin#apply_highlight(opts)
        call popup_create(bnr, opts)
    endif
endfunction

command! -nargs=0 ToggleTerminal   :call s:toggle_terminal()

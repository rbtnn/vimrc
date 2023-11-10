
function! git#grep#exec(q_args) abort
    let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
    call qfjob#start(cmd, {
        \ 'title': 'git grep',
        \ 'line_parser': function('s:line_parser'),
        \ })
endfunction



function s:line_parser(line) abort
    let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
    if !empty(m)
        let path = m[1]
        if !filereadable(path) && (path !~# '^[A-Z]:')
            let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
        endif
        return {
            \ 'filename': utils#iconv#exec(path),
            \ 'lnum': m[2],
            \ 'col': m[3],
            \ 'text': utils#iconv#exec(m[4]),
            \ }
    else
        return { 'text': utils#iconv#exec(a:line), }
    endif
endfunction



let g:loaded_develop_ripgrep = 1

if executable('rg')
    command! -nargs=* RipGrep      :call s:ripgrep(<q-args>)

    function! s:ripgrep(q_args) abort
        let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
        call qfjob#start(cmd, {
            \ 'title': 'ripgrep',
            \ 'line_parser': function('s:line_parser'),
            \ })
    endfunction

    function s:line_parser(line) abort
        let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
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
endif


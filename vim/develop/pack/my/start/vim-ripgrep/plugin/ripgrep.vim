
let g:loaded_develop_ripgrep = 1

if executable('rg')
    command! -nargs=* RipGrepSearch  :call s:ripgrep(<q-args>)
    command! -nargs=* RipGrepFiles   :call ripgrep#files(<q-args>)

    function! s:ripgrep(q_args) abort
        let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
        let g:ripgrep_ignore_patterns = get(g:, 'rggrep_ignore_patterns', [
            \ 'min.js$', 'min.js.map$',
            \ ])
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
            let filename = fnamemodify(path, ':t')
            let ok = v:true
            for pat in g:ripgrep_ignore_patterns
                if filename =~# pat
                    let ok = v:false
                    break
                endif
            endfor
            if ok
                return {
                    \ 'filename': iconv#exec(path),
                    \ 'lnum': m[2],
                    \ 'col': m[3],
                    \ 'text': iconv#exec(m[4]),
                    \ }
            else
                return {}
            endif
        else
            return { 'text': iconv#exec(a:line), }
        endif
    endfunction
endif


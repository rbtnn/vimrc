
function! ripgrep#files() abort
    call s:init()
    let prefixcmd = ['rg'] + g:ripgrep_glob_args + ['--files', '--hidden']
    let postcmd = []
    call ripgrep#common#exec('ripgrep#files', 'files', prefixcmd, postcmd, v:false, function('s:files_callback'), get(g:, 'ripgrep_ignore_patterns', [
        \ 'min.js$', 'min.js.map$', 'Thumbs.db$',
        \ ]), g:ripgrep_maximum)
endfunction

function! ripgrep#livegrep() abort
    call s:init()
    let prefixcmd = ['rg'] + g:ripgrep_glob_args + ['--vimgrep', '-uu']
    let postcmd = (has('win32') ? ['.\'] : ['.'])
    call ripgrep#common#exec('ripgrep#livegrep#exec', 'livegrep', prefixcmd, postcmd, v:true, function('s:livegrep_callback'), ['(os error \d\+)', '^[^:]*\<_viminfo:'], g:ripgrep_maximum)
endfunction



function! s:init() abort
    let g:ripgrep_maximum = get(g:, 'ripgrep_maximum', 300)
    let g:ripgrep_glob_args = get(g:, 'ripgrep_glob_args', [
        \ '--glob', '!NTUSER.DAT*',
        \ '--glob', '!.git',
        \ '--glob', '!.svn',
        \ '--glob', '!bin',
        \ '--glob', '!obj',
        \ '--glob', '!node_modules',
        \ '--line-buffered'
        \ ])
endfunction

function! s:files_callback(line) abort
    let path = fnamemodify(resolve(a:line), ':p:gs?\\?/?')
    call fileopener#open_file(path)
endfunction

function! s:livegrep_callback(line) abort
    let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
    if !empty(m)
        let path = m[1]
        let lnum = str2nr(m[2])
        let col = str2nr(m[3])
        if !filereadable(path) && (path !~# '^[A-Z]:')
            let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
        endif
        call fileopener#open_file(path, lnum, col)
    endif
endfunction

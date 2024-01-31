
function! vimrc#init() abort
    let g:git_lsfiles_ignore_exts = get(g:, 'git_lsfiles_ignore_exts', [
        \ 'exe', 'o', 'obj', 'xls', 'doc', 'xlsx', 'docx', 'dll', 'png', 'jpg', 'ico', 'pdf', 'mp3', 'zip',
        \ 'ttf', 'gif', 'otf', 'wav', 'm4a', 'ai', 'tgz'
        \ ])
    let g:git_lsfiles_ignore_patterns = get(g:, 'git_lsfiles_ignore_patterns', [])
    let g:git_lsfiles_maximum = get(g:, 'git_lsfiles_maximum', 1000)
    let g:git_enabled_qficonv = get(g:, 'git_enabled_qficonv', v:false)
    let g:git_enabled_match_query = get(g:, 'git_enabled_match_query', v:true)
    let g:filer_maximum = get(g:, 'filer_maximum', 1000)
    let g:ripgrep_ignore_patterns = get(g:, 'rggrep_ignore_patterns', [
        \ 'min.js$', 'min.js.map$',
        \ ])
endfunction

function! vimrc#error(msg) abort
    echohl Error
    echo a:msg
    echohl None
endfunction

function! vimrc#open_file(path, lnum = -1) abort
    if filereadable(a:path)
        if s:find_window_by_path(a:path)
        elseif s:can_open_in_current() && (&filetype != 'diff')
            silent! execute printf('edit %s', fnameescape(a:path))
        else
            silent! execute printf('new %s', fnameescape(a:path))
        endif
        if 0 < a:lnum
            silent! execute printf(':%d', a:lnum)
        endif
        normal! zz
    endif
endfunction

function! s:find_window_by_path(path) abort
    for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if x['bufnr'] == s:strict_bufnr(a:path)
            execute printf(':%dwincmd w', x['winnr'])
            return v:true
        endif
    endfor
    return v:false
endfunction

function! s:strict_bufnr(path) abort
    let bnr = bufnr(a:path)
    let fname1 = fnamemodify(a:path, ':t')
    let fname2 = fnamemodify(bufname(bnr), ':t')
    if (-1 == bnr) || (fname1 != fname2)
        return -1
    else
        return bnr
    endif
endfunction

function! s:can_open_in_current() abort
    let tstatus = term_getstatus(bufnr())
    if (tstatus != 'finished') && !empty(tstatus)
        return v:false
    elseif !empty(getcmdwintype())
        return v:false
    elseif &modified
        return v:false
    else
        return v:true
    endif
endfunction

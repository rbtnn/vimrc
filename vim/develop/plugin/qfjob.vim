function s:iconv(text) abort
    if has('win32') && exists('g:loaded_qficonv') && (len(a:text) < 500)
        return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
    else
        return a:text
    endif
endfunction

if executable('git')
    command! -nargs=*                                           GitGrep      :call s:gitgrep(<q-args>)

    function! s:gitgrep(q_args) abort
        let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
        call qfjob#start(cmd, {
            \ 'title': 'git grep',
            \ 'line_parser': function('s:gitgrep_line_parser'),
            \ })
    endfunction

    function s:gitgrep_line_parser(line) abort
        let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction
endif

if executable('rg')
    command! -nargs=*                                           RipGrep      :call s:ripgrep(<q-args>)

    function! s:ripgrep(q_args) abort
        let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
        call qfjob#start(cmd, {
            \ 'title': 'ripgrep',
            \ 'line_parser': function('s:ripgrep_line_parser'),
            \ })
    endfunction

    function s:ripgrep_line_parser(line) abort
        let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction
endif

if has('win32') && executable('msbuild')
    command! -nargs=* -complete=customlist,MSBuildRunTaskComp   MSBuild      :call s:msbuild(eval(g:msbuild_projectfile), <q-args>)
    let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

    function! s:msbuild(projectfile, args) abort
        if type([]) == type(a:args)
            let cmd = ['msbuild']
            if filereadable(a:projectfile)
                let cmd += ['/nologo', a:projectfile] + a:args
            else
                let cmd += ['/nologo'] + a:args
            endif
        else
            let cmd = printf('msbuild /nologo %s %s', a:args, a:projectfile)
        endif
        call qfjob#start(cmd, {
            \ 'title': 'msbuild',
            \ 'line_parser': function('s:msbuild_runtask_line_parser', [a:projectfile]),
            \ })
    endfunction

    function s:msbuild_runtask_line_parser(projectfile, line) abort
        let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(a:projectfile, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction

    function! MSBuildRunTaskComp(A, L, P) abort
        let xs = []
        let path = eval(g:msbuild_projectfile)
        if filereadable(path)
            for line in readfile(path)
                let m = matchlist(line, '<Target\s\+Name="\([^"]\+\)"')
                if !empty(m)
                    let xs += ['/t:' .. m[1]]
                endif
            endfor
        endif
        return xs
    endfunction
endif

if executable('dotnet')
    command! -nargs=* DotnetRun         :call s:dotnet_run(<q-args>)
    command! -nargs=* DotnetFormat      :call s:dotnet_format(<q-args>)
    command! -nargs=* DotnetBuild       :call s:dotnet_build(<q-args>)

    function! s:dotnet_run(args) abort
        call qfjob#start(['dotnet', 'run'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-run',
            \ 'line_parser': function('s:dotnet_default_line_parser'),
            \ })
    endfunction

    function! s:dotnet_format(args) abort
        call qfjob#start(['dotnet', 'format'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-format',
            \ 'line_parser': function('s:dotnet_default_line_parser'),
            \ })
    endfunction

    function! s:dotnet_build(args) abort
        call qfjob#start(['dotnet', 'build'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-build',
            \ 'line_parser': function('s:dotnet_default_line_parser'),
            \ })
    endfunction

    function s:dotnet_default_line_parser(line) abort
        let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
        if !empty(m)
            return {
                \ 'filename': s:iconv(m[1]),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction
endif

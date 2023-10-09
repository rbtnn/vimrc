
let g:loaded_develop_dotnet = 1

if executable('dotnet')
    command! -nargs=* DotnetRun         :call s:dotnet_run(<q-args>)
    command! -nargs=* DotnetFormat      :call s:dotnet_format(<q-args>)
    command! -nargs=* DotnetBuild       :call s:dotnet_build(<q-args>)

    function! s:dotnet_run(args) abort
        call qfjob#start(['dotnet', 'run'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-run',
            \ 'line_parser': function('s:line_parser'),
            \ })
    endfunction

    function! s:dotnet_format(args) abort
        call qfjob#start(['dotnet', 'format'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-format',
            \ 'line_parser': function('s:line_parser'),
            \ })
    endfunction

    function! s:dotnet_build(args) abort
        call qfjob#start(['dotnet', 'build'] + split(a:args, '\s\+'), {
            \ 'title': 'dotnet-build',
            \ 'line_parser': function('s:line_parser'),
            \ })
    endfunction

    function s:line_parser(line) abort
        let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
        if !empty(m)
            return {
                \ 'filename': utils#iconv#exec(m[1]),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': utils#iconv#exec(m[4]),
                \ }
        else
            return { 'text': utils#iconv#exec(a:line), }
        endif
    endfunction
endif


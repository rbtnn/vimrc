
let g:loaded_cargo = 1

function! s:getcwd() abort
    let cwd = getcwd()
    try
        if filereadable(expand('%'))
            call printf('lcd %s', escape(expand('%:h'), '\ '))
            let path = findfile('Cargo.Toml', '.;')
            return fnamemodify(path, ':p:h')
        else
            return cwd
        endif
    finally
        call printf('lcd %s', escape(cwd, '\ '))
    endtry
endfunction

function! s:cargo(q_args) abort
    let args = helper#trim(a:q_args)
    let cmd = ['cargo']
    if !empty(args)
        let cmd += split(args, '\s\+')
    endif
    let rootdir = s:getcwd()
    call job#new(cmd, rootdir, function('s:close_handler_cargo', [rootdir, (cmd)]))
endfunction

function! s:close_handler_cargo(rootdir, cmd, output)
    let lines = a:output
    call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
    let xs = []
    let errcnt = 0
    for line in lines
        let dict = {}
        let m = matchlist(line, '^\s*-->\s*\(.*\):\(\d\+\):\(\d\+\)$')
        if !empty(m)
            let path = fnamemodify(a:rootdir . '/' . m[1], ':p')
            if filereadable(path)
                let dict.filename = path
                let errcnt += 1
            endif
        endif
        if has_key(dict, 'filename')
            let dict.lnum = m[2]
            let dict.col = m[3]
            let dict.text = ''
        else
            let dict.text = line
        endif
        let xs += [dict]
    endfor
    call setqflist(xs)
    call setqflist([], 'r', { 'title': printf('(%s) %s', a:rootdir, join(a:cmd, ' ')), })
    copen
    execute (winnr('#') . 'wincmd w')
    if 0 < errcnt
        call helper#error('Build failure.')
    else
        call helper#echo('Build succeeded.')
    endif
endfunction

augroup cargo
    autocmd!
    autocmd FileType rust :command! -buffer -nargs=* Cargo  :call <SID>cargo(<q-args>)
augroup END


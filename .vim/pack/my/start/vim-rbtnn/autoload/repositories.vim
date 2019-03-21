
let s:cached_path = expand('~/.vim/.repositories')

function! repositories#readfile() abort
    if filereadable(s:cached_path)
        let xs = readfile(s:cached_path)
        call map(xs, { i, x -> fnamemodify(x, ':p') })
        call filter(xs, { i, x -> isdirectory(x) })
        return uniq(sort(xs))
    else
        return []
    endif
endfunction

function! repositories#winenter() abort
    let xs = repositories#readfile()
    for name in ['.git', '.svn']
        let path = finddir(name, '.;')
        if !empty(path)
            let path = fnamemodify(path, ':h')
            if -1 == index(xs, path)
                let xs = [path] + uniq(sort(xs))
                call writefile(xs, s:cached_path)
                break
            endif
        endif
    endfor
endfunction

function! repositories#bufenter() abort
    if filereadable(expand('%'))
        let xs = repositories#readfile()
        for name in ['.git', '.svn']
            let path = finddir(name, expand('%') .';')
            if !empty(path)
                let path = fnamemodify(path, ':h:p')
                if -1 == index(xs, path)
                    let xs += [path]
                    call writefile(xs, s:cached_path)
                    break
                endif
            endif
        endfor
    endif
endfunction

function! repositories#exec() abort
    let choices = repositories#readfile()[:10]
    let lines = []
    let n = 0
    for path in choices
        let n += 1
        let lines += [printf('%d: %s', n, fnamemodify(path, ':~'))]
    endfor
    if !empty(lines)
        let choice = confirm('Where do you want to change a current directory?', join(lines, "\n"))
        if 0 < choice
            execute printf('lcd %s', escape(choices[choice - 1], ' \'))
            echohl Question
            echo 'The current directory has changed: ' . getcwd()
            echohl None
        endif
    endif
endfunction


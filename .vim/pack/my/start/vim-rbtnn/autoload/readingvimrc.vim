
scriptversion 3

let s:V = vital#of('rbtnn')
let s:Http = s:V.import('Web.HTTP')

let s:next_url = 'https://raw.githubusercontent.com/vim-jp/reading-vimrc/gh-pages/_data/next.yml'

function readingvimrc#open_list() abort
    try
        let lines = []
        let next_is_url = 0
        for line in split(get(s:Http.get(s:next_url, {}, {}), 'content', ''), "\n")
            let m1 = matchlist(line, '^\s*- url: ''\(.*\)''$')
            let m2 = matchlist(line, '^\s*- url: >-$')
            if !empty(m1)
                call add(lines, m1[1])
            elseif !empty(m2)
                let next_is_url = 1
            elseif next_is_url
                call add(lines, trim(line))
                let next_is_url = 0
            endif
        endfor
        if 0 == len(lines)
        elseif 1 == len(lines)
            call readingvimrc#open_url(lines[0])
        else
            call s:new_window(lines)
            execute printf("nnoremap <silent><buffer><nowait><cr>    :<C-u>call readingvimrc#open_url(getline('.'))<cr>")
            let &l:statusline = '(readingvimrc)'
        endif
    catch
    endtry
endfunction

function readingvimrc#open_url(line) abort
    let url = substitute(substitute(a:line, 'github.com', 'raw.githubusercontent.com', 'g'), 'blob/', '', 'g')
    let lines = split(get(s:Http.get(url, {}, {}), 'content', ''), "\n")
    call s:new_window(lines)
    setfiletype vim
    setlocal number
    let &l:statusline = split(a:line, '/')[-1]
endfunction

function s:new_window(lines) abort
    new
    let pos = getpos('.')
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    call setpos('.', pos)
    nnoremap <silent><buffer>q       :<C-u>execute ((winnr('$') == 1) ? 'bdelete' : 'quit')<cr>
endfunction



if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let s:next_url = 'https://raw.githubusercontent.com/vim-jp/reading-vimrc/gh-pages/_data/next.yml'

function readingvimrc#open_list() abort
    try
        let lines = []
        let next_is_url = 0
        for line in split(http#get_content(s:next_url), "\n")
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
            call scratch#new(lines)
            execute printf("nnoremap <silent><buffer><nowait><cr>    :<C-u>call readingvimrc#open_url(getline('.'))<cr>")
        endif
    catch
    endtry
endfunction

function readingvimrc#open_url(line) abort
    let url = substitute(substitute(a:line, 'github.com', 'raw.githubusercontent.com', 'g'), 'blob/', '', 'g')
    let lines = split(http#get_content(url), "\n")
    call scratch#new(lines)
    setfiletype vim
    setlocal number
    wincmd T
endfunction


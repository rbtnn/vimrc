
function! s:set_common_highlights(colors_name, c1 = '#777777', c2 = '#bcbcbc', c3 = '#ffffff', c4 = '#000000') abort
    let normal_hl = hlget('Normal')[0]

    execute printf('highlight!       TabSideBar               guifg=%s   guibg=%s gui=NONE cterm=NONE', a:c1, normal_hl['guibg'])
    execute printf('highlight!       TabSideBarFill           guifg=NONE guibg=%s gui=NONE cterm=NONE',       normal_hl['guibg'])
    execute printf('highlight!       TabSideBarCurTab         guifg=%s   guibg=%s gui=BOLD cterm=NONE', a:c2, normal_hl['guibg'])
    execute printf('highlight!       VimrcDevPopupWin         guifg=%s   guibg=%s gui=NONE cterm=NONE', a:c3, a:c4)

    highlight! CursorIM                 guifg=NONE    guibg=#d70000

    " itchyny/vim-parenmatch
    if exists('g:loaded_parenmatch')
        let g:parenmatch_highlight = 0
        highlight! link  ParenMatch  MatchParen
    endif

    " itchyny/vim-lightline
    if exists('g:loaded_lightline') && !empty(a:colors_name)
        let g:lightline = { 'colorscheme': a:colors_name }
        call lightline#enable()
    endif
endfunction

function! s:colorscheme(colors_name) abort
    if a:colors_name == 'AhmedAbdulrahman/vim-aylin'
        colorscheme aylin
        call s:set_common_highlights('aylin')
        highlight!       SpecialKey               guifg=#444411
    elseif a:colors_name == 'danilo-augusto/vim-afterglow'
        colorscheme afterglow
        call s:set_common_highlights('afterglow')
    elseif a:colors_name == 'drewtempelmeyer/palenight.vim'
        colorscheme palenight
        call s:set_common_highlights('palenight')
    elseif a:colors_name == 'tomasr/molokai'
        colorscheme molokai
        call s:set_common_highlights('molokai')
        highlight!       Cursor                   guifg=#ffffff guibg=#d700d7
        highlight!       Special                                              gui=NONE
        highlight!       Macro                                                gui=NONE
        highlight!       StorageClass                                         gui=NONE
        highlight! link  DiffAdd                  Identifier
        highlight! link  DiffDelete               Special
        highlight!       DiffText                 gui=bold
    elseif a:colors_name == 'tyrannicaltoucan/vim-deep-space'
        colorscheme deep-space
        call s:set_common_highlights('')
    elseif a:colors_name == 'cormacrelf/vim-colors-github'
        let g:github_colors_soft = 0
        set background=light
        colorscheme github
        call s:set_common_highlights('github')
        highlight!       Comment                  guifg=#bbbbbb guibg=NONE
        highlight!       Error                    guifg=#d73a49 guibg=NONE
        highlight!       NonText                  guifg=NONE    guibg=#000000
    endif
endfunction

call s:colorscheme('AhmedAbdulrahman/vim-aylin')

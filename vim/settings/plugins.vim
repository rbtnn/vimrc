
augroup vimrc-plugins
    autocmd!
    autocmd VimEnter        *
        \ :if !exists(':PkgSync')
        \ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
        \ |endif
augroup END

function! PkgSyncSetup() abort
    let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
    silent! call mkdir(path, 'p')
    call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
        \ 'cwd': path,
        \ })
endfunction

function! s:is_installed(user_and_name) abort
    let xs = split(a:user_and_name, '/')
    return !empty(globpath($VIMRC_VIM, 'github/pack/' .. xs[0] .. '/*/' .. xs[1]))
endfunction

if s:is_installed('tyru/restart.vim')
    let g:restart_sessionoptions = &sessionoptions
endif

if s:is_installed('rbtnn/vim-textobj-string')
    nmap <silent>ds das
    nmap <silent>ys yas
    nmap <silent>vs vas
endif

if s:is_installed('kana/vim-operator-replace')
    nmap <silent>s   <Plug>(operator-replace)
    nmap <silent>ss  <Plug>(operator-replace)as
endif

if s:is_installed('haya14busa/vim-operator-flashy')
    map  <silent>y   <Plug>(operator-flashy)
    nmap <silent>Y   <Plug>(operator-flashy)$
endif

if s:is_installed('rbtnn/vim-lsfiles')
    let g:lsfiles_height = 20
    nnoremap <silent><space>  <Cmd>LsFiles<cr>
endif

if s:is_installed('rbtnn/vim-gitdiff')
    nnoremap <silent><C-s>    <Cmd>GitDiffNumStat -w<cr>
endif

if has('vim_starting')
    if s:is_installed('tomasr/molokai')
        if s:is_installed('itchyny/lightline.vim')
            let g:lightline = { 'colorscheme': 'molokai' }
        endif
        autocmd vimrc-plugins ColorScheme      *
            \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
            \ | highlight!       LsFilesPopupBorder       guifg=#a6e22e guibg=NONE    gui=BOLD cterm=NONE
            \ | highlight!       Special                                              gui=NONE
            \ | highlight!       Macro                                                gui=NONE
            \ | highlight!       StorageClass                                         gui=NONE
            \ | highlight! link  DiffAdd                  Identifier
            \ | highlight! link  DiffDelete               Special
        colorscheme molokai
    endif

    if v:false && s:is_installed('ajmwagar/vim-deus')
        if s:is_installed('itchyny/lightline.vim')
            let g:lightline = { 'colorscheme': 'deus' }
        endif
        autocmd vimrc-plugins ColorScheme      *
            \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
            \ | highlight! link  LsFilesPopupBorder       deusOrange
            \ | highlight! link  StatusLine               deusOrange
            \ | highlight! link  StatusLineNC             deusBlue
            \ | highlight! link  StatusLineTerm           deusOrange
            \ | highlight! link  StatusLineTermNC         deusBlue
        let g:deus_italic = 0
        colorscheme deus
    endif

    if v:false && s:is_installed('rbtnn/vim-colors-github')
        if s:is_installed('itchyny/lightline.vim')
            let g:lightline = { 'colorscheme': 'github' }
        endif
        autocmd vimrc-plugins ColorScheme      *
            \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
            \ | highlight!       Comment                  guifg=#bbbbbb guibg=NONE
            \ | highlight!       Error                    guifg=#d73a49 guibg=NONE
            \ | highlight! link  LsFilesPopupBorder       Question
        set background=light
        let g:github_colors_soft = 0
        colorscheme github
    endif
endif

if s:is_installed('rbtnn/vim-qfjob')
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
endif

scriptencoding utf-8
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')
let $VIMRC_PKGSYNC_DIR = expand('$VIMRC_VIM/github/pack/rbtnn/start/vim-pkgsync')

source $VIMRC_VIM/settings/options.vim
source $VIMRC_VIM/settings/autocmds.vim

if has('vim_starting')
    set packpath=$VIMRC_VIM/github
    set runtimepath=$VIMRC_VIM/develop,$VIMRUNTIME

    if has('win32') && has('gui_running')
        set linespace=0
        if filereadable(expand('$USERPROFILE/AppData/Local/Microsoft/Windows/Fonts/UDEVGothic-Regular.ttf'))
            \ || filereadable(expand('C:/Windows/Fonts/UDEVGothic-Regular.ttf'))
            " https://github.com/yuru7/udev-gothic
            set guifont=UDEV_Gothic:h16:cSHIFTJIS:qDRAFT
        else
            set guifont=ＭＳ_ゴシック:h18:cSHIFTJIS:qDRAFT
        endif
    endif

    silent! source ~/.vimrc.local

    if isdirectory($VIMRC_PKGSYNC_DIR)
        for s:setting in sort(split(globpath($VIMRC_VIM, 'settings/plugins/before/*'), '\n'))
            for s:plugin in sort(split(globpath($VIMRC_VIM, 'github/pack/*/*/*'), '\n'))
                let s:x = split(s:setting, '[\/]')[-1]
                let s:y = split(s:plugin, '[\/]')[-1]
                if (s:x == s:y .. '.vim') || (s:x == s:y)
                    execute 'source' s:setting
                endif
            endfor
        endfor
    endif

    filetype plugin indent on
    syntax enable
    packloadall

    if isdirectory($VIMRC_PKGSYNC_DIR)
        for s:setting in sort(split(globpath($VIMRC_VIM, 'settings/plugins/after/*'), '\n'))
            for s:plugin in sort(split(globpath($VIMRC_VIM, 'github/pack/*/*/*'), '\n'))
                let s:x = split(s:setting, '[\/]')[-1]
                let s:y = split(s:plugin, '[\/]')[-1]
                if (tolower(s:x) == tolower(s:y .. '.vim')) || (tolower(s:x) == tolower(s:y))
                    execute 'source' s:setting
                endif
            endfor
        endfor
    endif

    if !isdirectory($VIMRC_PKGSYNC_DIR)
        function! PkgSyncSetup() abort
            let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
            silent! call mkdir(path, 'p')
            call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
                \ 'cwd': path,
                \ })
        endfunction
        autocmd vimrc-plugins VimEnter *
            \ :if !exists(':PkgSync')
            \ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
            \ |endif
    endif
endif

source $VIMRC_VIM/settings/mappings.vim
source $VIMRC_VIM/settings/tabsidebar.vim
source $VIMRC_VIM/settings/vcvarsallterminal.vim

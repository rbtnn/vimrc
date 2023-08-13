let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')

source $VIMRC_VIM/settings/options.vim
source $VIMRC_VIM/settings/autocmds.vim

if has('vim_starting')
    set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    if has('win32') && has('gui_running')
        " https://github.com/yuru7/udev-gothic
        set guifont=UDEV_Gothic:h12:cSHIFTJIS:qDRAFT
        set linespace=0
    endif

    silent! source ~/.vimrc.local

    filetype plugin indent on
    syntax enable
    packloadall
endif

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

let s:installed_plugins = split(globpath($VIMRC_VIM, 'github/pack/*/*/*'), '\n')
let s:settings = split(globpath($VIMRC_VIM, 'settings/plugins/*'), '\n')
for s:plugin in s:installed_plugins
    for s:setting in s:settings
        let s:x = split(s:setting, '[\/]')[-1]
        let s:y = split(s:plugin, '[\/]')[-1]
        if (s:x == s:y .. '.vim') || (s:x == s:y)
            echo 'source' s:x
            execute 'source' s:x
        endif
    endfor
endfor

source $VIMRC_VIM/settings/mappings.vim
source $VIMRC_VIM/settings/tabsidebar.vim
source $VIMRC_VIM/settings/vcvarsallterminal.vim

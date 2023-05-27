
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')

source $VIMRC_VIM/settings/options.vim
source $VIMRC_VIM/settings/autocmds.vim

if has('vim_starting')
    set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    silent! source ~/.vimrc.local

    filetype plugin indent on
    syntax enable
    packloadall
endif

source $VIMRC_VIM/settings/plugins.vim
source $VIMRC_VIM/settings/mappings.vim
source $VIMRC_VIM/settings/tabsidebar.vim
source $VIMRC_VIM/settings/vcvarsallterminal.vim

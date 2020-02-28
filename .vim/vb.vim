
scriptencoding utf-8

function! s:bufenter() abort
    if &filetype == 'vb'
        syntax keyword vbKeyword ReadOnly Protected Imports Module Try Catch Overrides Overridable Throw Partial NotInheritable
        syntax keyword vbKeyword Shared Class Finally Using Continue Of Inherits Default Region Structure AndAlso OrElse
        syntax keyword vbKeyword Namespace Strict My MyBase IsNot
    endif
endfunction

augroup vimrc_vb
    autocmd!
    autocmd BufEnter * :call <SID>bufenter()
augroup END

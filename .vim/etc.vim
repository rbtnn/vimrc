
scriptencoding utf-8

function! s:bufenter() abort
    let ext = expand('%:t:e')
    if ext == 'uke'
        setfiletype uke
    endif
    if (ext == 'frm') || (ext == 'bas') || (ext == 'cls')
        setfiletype vb
    endif
    if &filetype == 'vb'
        syntax keyword vbKeyword ReadOnly Protected Imports Module Try Catch Overrides Overridable Throw Partial NotInheritable
        syntax keyword vbKeyword Shared Class Finally Using Continue Of Inherits Default Region Structure AndAlso OrElse
    endif
endfunction

augroup vimrc_etc
    autocmd!
    autocmd BufEnter * :call <SID>bufenter()
augroup END


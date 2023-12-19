
scriptencoding utf-8

let g:loaded_vb = 1

function! s:regex() abort
    return '^\s*\(Public\|Private\|Protected\)\?\s*\(Overridable\|Shared\)\?\s*\(Structure\|Enum\|Sub\|Function\)'
endfunction

function! s:bufenter() abort
    let ext = fnamemodify(bufname(), ':e')
    if ('frm' == ext) || ('bas' == ext) || ('cls' == ext)
        setfiletype vb
    endif
    if &filetype == 'vb'
        syntax keyword vbKeyword MustOverride MustInherit ReadOnly Protected Imports Module Try Catch Overrides Overridable Throw Partial NotInheritable
        syntax keyword vbKeyword Shared Class Finally Using Continue Of Inherits Default Region Structure AndAlso OrElse
        syntax keyword vbKeyword Namespace Strict My MyBase IsNot Handles And Or Delegate MarshalAs Not In
        nnoremap <buffer><nowait><silent>[[      :<C-u>call search(<SID>regex(), 'b')<cr>
        nnoremap <buffer><nowait><silent>]]      :<C-u>call search(<SID>regex(), '')<cr>
    endif
endfunction

augroup vim_vb
    autocmd!
    autocmd BufEnter * :call <SID>bufenter()
augroup END


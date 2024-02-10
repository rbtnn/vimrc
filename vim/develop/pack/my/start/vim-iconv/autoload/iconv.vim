
function iconv#exec(text) abort
    if has('win32') && (&encoding == 'utf-8') && exists('g:loaded_qficonv') && (len(a:text) < 500)
        return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
    else
        return a:text
    endif
endfunction


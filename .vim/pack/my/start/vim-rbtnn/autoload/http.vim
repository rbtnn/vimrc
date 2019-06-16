
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let s:V = vital#of('rbtnn')
let s:Http = s:V.import('Web.HTTP')

function http#get_content(url) abort
    return get(s:Http.get(a:url, {}, {}), 'content', '')
endfunction

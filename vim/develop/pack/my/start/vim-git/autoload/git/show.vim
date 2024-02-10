
function! git#show#exec(q_args) abort
    let lines = git#internal#system(['show'] + split(a:q_args, '\s\+'))
    new
    setlocal nolist
    let &l:statusline = printf('[git] show %s', a:q_args)
    call git#internal#setbuflines(lines)
endfunction

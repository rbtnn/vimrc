command! -nargs=0 Scouter :echo reduce(map(filter(git#internal#system(['ls-files']), { i,x -> (x =~# '\.\(vimrc\|vim\)$') }), { i,x -> len(readfile(x)) }), { acc, val -> acc + val })

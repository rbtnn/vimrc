
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

if has('clpum')
    set wildmode=popup
    set clpumheight=10
endif

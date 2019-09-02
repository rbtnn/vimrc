
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

syntax match   ukeBU  '^BU\(,[^,]*\)\{5,5\}$'      contains=ukeID,ukeComma
syntax match   ukeCD  '^CD\(,[^,]*\)\{10,10\}$'    contains=ukeID,ukeComma
syntax match   ukeCO  '^CO\(,[^,]*\)\{4,4\}$'      contains=ukeID,ukeComma
syntax match   ukeGA  '^GA\(,[^,]*\)\{6,6\}$'      contains=ukeID,ukeComma
syntax match   ukeGO  '^GO\(,[^,]*\)\{3,3\}$'      contains=ukeID,ukeComma
syntax match   ukeGR  '^GR\(,[^,]*\)\{2,2\}$'      contains=ukeID,ukeComma
syntax match   ukeGT  '^GT\(,[^,]*\)\{11,11\}$'    contains=ukeID,ukeComma
syntax match   ukeHH  '^HH\(,[^,]*\)\{8,8\}$'      contains=ukeID,ukeComma
syntax match   ukeHO  '^HO\(,[^,]*\)\{14,15\}$'      contains=ukeID,ukeComma
syntax match   ukeIR  '^IR\(,[^,]*\)\{9,9\}$'        contains=ukeID,ukeComma
syntax match   ukeIY  '^IY\(,[^,]*\)\{43,43\}$'      contains=ukeID,ukeComma
syntax match   ukeKK  '^KK\(,[^,]*\)\{13,13\}$'      contains=ukeID,ukeComma
syntax match   ukeKO  '^KO\(,[^,]*\)\{11,12\}$'      contains=ukeID,ukeComma
syntax match   ukeRE  '^RE\(\(,[^,]*\)\{29,29\}\|\(,[^,]*\)\{37,37\}\)$'      contains=ukeID_RE,ukeComma
syntax match   ukeSB  '^SB\(,[^,]*\)\{7,7\}$'      contains=ukeID,ukeComma
syntax match   ukeSI  '^SI\(,[^,]*\)\{43,43\}$'      contains=ukeID,ukeComma
syntax match   ukeSJ  '^SJ\(,[^,]*\)\{2,2\}$'      contains=ukeID,ukeComma
syntax match   ukeSK  '^SK\(,[^,]*\)\{6,6\}$'      contains=ukeID,ukeComma
syntax match   ukeSY  '^SY\(,[^,]*\)\{7,7\}$'        contains=ukeID,ukeComma
syntax match   ukeTI  '^TI\(,[^,]*\)\{9,9\}$'      contains=ukeID,ukeComma
syntax match   ukeTO  '^TO\(,[^,]*\)\{47,47\}$'      contains=ukeID,ukeComma
syntax match   ukeTR  '^TR\(,[^,]*\)\{17,17\}$'      contains=ukeID,ukeComma
syntax match   ukeTS  '^TS\(,[^,]*\)\{4,4\}$'      contains=ukeID,ukeComma

syntax keyword ukeID_RE   RE contained 
syntax keyword ukeID      BU CD CO GA GO GR GT HH HO IR IY KK KO SB SI SJ SK SY TI TO TR TS contained 
syntax match   ukeComma   ',' contained 

highlight link ukeID       Identifier
highlight link ukeID_RE    Special
highlight link ukeComma    SpecialKey


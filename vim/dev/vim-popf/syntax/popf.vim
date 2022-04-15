
if exists("b:current_syntax")
	finish
endif

syntax match   popfLnumAndCol  '(\d\+,\d\+)'                contained
syntax match   popfLine        '^[^|]\+(\d\+,\d\+)$'        contains=popfLnumAndCol
syntax match   popfSearch      '^>.*$'

highlight default link popfLine        Normal
highlight default link popfLnumAndCol  Comment
highlight default link popfSearch      Title



if exists("b:current_syntax")
	finish
endif

syntax match   popfSearch      '^>.*$'

highlight default link popfSearch      Title


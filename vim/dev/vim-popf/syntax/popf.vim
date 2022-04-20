
if exists("b:current_syntax")
	finish
endif

syntax match   popfSearch      '^\%1l[^>]*>'

highlight default link popfSearch      Title


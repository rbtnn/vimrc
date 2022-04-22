
if exists("b:current_syntax")
	finish
endif

syntax match   findSearch      '^\%1l[^>]*>'

highlight default link findSearch      Title


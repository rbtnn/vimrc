
syntax region  diffyComment         start='^#'            end='$'
syntax region  diffyInfoDiff        start='|\s*\d\+'      end='$' contains=diffyDelimiter,diffyInsertion,diffyDeletion
syntax region  diffyInfoBin         start='|\s*Bin'       end='$' contains=diffyDelimiter
syntax region  diffyInfoUnmerged    start='|\s*Unmerged'  end='$' contains=diffyDelimiter
syntax match   diffyDelimiter  '|' contained
syntax match   diffyInsertion  '+' contained
syntax match   diffyDeletion   '-' contained

highlight! def link diffyComment         Comment
highlight! def link diffyInsertion       DiffAdd
highlight! def link diffyDeletion        DiffDelete
highlight! def link diffyDelimiter       NonText
highlight! def link diffyInfoBin         Error
highlight! def link diffyInfoUnmerged    Error

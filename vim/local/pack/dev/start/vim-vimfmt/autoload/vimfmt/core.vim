
function! vimfmt#core#format(lines) abort
  let input_chars = empty(a:lines) ? [] : split(join(a:lines, "\n"), '\zs')
  let xs = []
  let i = 0
  let ok = v:true
  while ok && (i < len(input_chars))
    let ok = v:false
    for name in [
        \ 's:consume_linebreaks',
        \ 's:consume_command',
        \ 's:consume_untileol',
        \ ]
      let x = call(name, [input_chars[i:]])
      if !empty(x)
        let ok = v:true
        let i += len(x.raw)
        let xs += [x]
        break
      endif
    endfor
  endwhile

  let output = ''
  let is_head = v:true
  let indent_count = 0
  let is_continuous = v:false
  let is_vim9script = v:false
  for i in range(0, len(xs) - 1)
    let x1 = xs[i]
    let x2 = get(xs, i + 1, {})
    if x1.kind == 'linebreaks'
      let output = output .. (is_head ? "\n" : x1.formated_text)
      let is_head = v:true
    else
      if is_head
        if x1.formated_text =~# '^\s*vim9s\%[cript]$'
          let is_vim9script = v:true
        endif
        let is_continuous = (x1.kind == 'untileol') && (x1.formated_text =~# '^\s*\\')
        let indent_count = s:check_indent_count_dec(is_vim9script, indent_count, x1, x2)
        let output = output
          \ .. repeat('  ', indent_count + (is_continuous ? 1 : 0))
          \ .. matchstr(x1.formated_text, '^\s*\zs.*$')
        let indent_count = s:check_indent_count_inc(is_vim9script, indent_count, x1, x2)
      else
        let output = output .. x1.formated_text
      endif
      let is_head = v:false
    endif
  endfor
  if empty(xs)
    return []
  else
    return split(output, "\n", v:true)
  endif
endfunction

function! s:check_indent_count_inc(is_vim9script, indent_count, x1, x2) abort
  let indent_count = a:indent_count
  if a:x1.kind == 'command'
    if       (a:x1.formated_text =~# '^\s*fu\%[nction]$')
        \ || (a:x1.formated_text =~# '^\s*if$')
        \ || (a:x1.formated_text =~# '^\s*el\%[se]$')
        \ || (a:x1.formated_text =~# '^\s*elsei\%[f]$')
        \ || (a:x1.formated_text =~# '^\s*for$')
        \ || (a:x1.formated_text =~# '^\s*wh\%[ile]$')
        \ || (a:x1.formated_text =~# '^\s*try$')
        \ || (a:x1.formated_text =~# '^\s*cat\%[ch]$')
        \ || (a:x1.formated_text =~# '^\s*fina\%[lly]$')
      let indent_count += 1
    elseif (a:x1.formated_text =~# '^\s*au\%[group]$') && (get(a:x2, 'formated_text', '') !~# '^\s*END')
      let indent_count += 1
    elseif a:is_vim9script
      if       (a:x1.formated_text =~# '^\s*def$')
          \ || (a:x1.formated_text =~# '^\s*class$')
          \ || (a:x1.formated_text =~# '^\s*interface$')
          \ || (a:x1.formated_text =~# '^\s*enum$')
        let indent_count += 1
      elseif a:x1.formated_text =~# '^\s*export$'
        if       (get(a:x2, 'formated_text', '') =~# '^\s*def$')
            \ || (get(a:x2, 'formated_text', '') =~# '^\s*class$')
            \ || (get(a:x2, 'formated_text', '') =~# '^\s*interface$')
          let indent_count += 1
        endif
      endif
    endif
  endif
  return indent_count
endfunction

function! s:check_indent_count_dec(is_vim9script, indent_count, x1, x2) abort
  let indent_count = a:indent_count
  if a:x1.kind == 'command'
    if       (a:x1.formated_text =~# '^\s*endf\%[unction]$')
        \ || (a:x1.formated_text =~# '^\s*en\%[dif]$')
        \ || (a:x1.formated_text =~# '^\s*el\%[se]$')
        \ || (a:x1.formated_text =~# '^\s*elsei\%[f]$')
        \ || (a:x1.formated_text =~# '^\s*endfo\%[r]$')
        \ || (a:x1.formated_text =~# '^\s*endw\%[hile]$')
        \ || (a:x1.formated_text =~# '^\s*endt\%[ry]$')
        \ || (a:x1.formated_text =~# '^\s*cat\%[ch]$')
        \ || (a:x1.formated_text =~# '^\s*fina\%[lly]$')
        \ || (a:x1.formated_text =~# '^\s*enddef$')
        \ || (a:x1.formated_text =~# '^\s*endclass$')
        \ || (a:x1.formated_text =~# '^\s*endinterface$')
        \ || (a:x1.formated_text =~# '^\s*endenum$')
      let indent_count -= 1
    elseif (a:x1.formated_text =~# '^\s*au\%[group]$') && (get(a:x2, 'formated_text', '') =~# '^\s*END')
      let indent_count -= 1
    endif
  endif
  return indent_count
endfunction

function! s:consume_linebreaks(input_chars) abort
  let i = 0
  let n = 0
  while v:true
    let k = i
    while s:cmp_char_re(a:input_chars, k, '\s')
      let k += 1
    endwhile
    if s:cmp_char(a:input_chars, k, "\n")
      let i = k + 1
      let n += 1
    else
      break
    endif
  endwhile
  return s:make_retval(0 < n ? i : 0, 'linebreaks', a:input_chars[:i-1], repeat("\n", 2 < n ? 2 : n))
endfunction

function! s:consume_command(input_chars) abort
  let i = 0
  let ok = v:false
  let xs = []
  while s:cmp_char_re(a:input_chars, i, '\s')
    if i == 0
      let xs += [' ']
    endif
    let i += 1
  endwhile
  while v:true
    if s:cmp_char_re(a:input_chars, i, '[A-Za-z0-9_]')
      let xs += [a:input_chars[i]]
      let i += 1
      let ok = v:true
    else
      let ok2 = v:false
      let k = i
      if s:cmp_char(a:input_chars, k, "\n")
        let k += 1
        while s:cmp_char_re(a:input_chars, k, '\s')
          let k += 1
        endwhile
        if s:cmp_char(a:input_chars, k, '\')
          let k += 1
          if s:cmp_char_re(a:input_chars, k, '[A-Za-z0-9_]')
            let xs += [a:input_chars[k]]
            let k += 1
            let ok2 = v:true
          endif
        endif
      endif
      if ok2
        let i = k
        let ok = v:true
      else
        break
      endif
    endif
  endwhile
  return s:make_retval(ok ? i : 0, 'command', a:input_chars[:i-1], join(xs, ''))
endfunction

function! s:consume_untileol(input_chars) abort
  let i = 0
  while s:not_cmp_char(a:input_chars, i, "\n")
    let i += 1
  endwhile
  return s:make_retval(i, 'untileol', a:input_chars[:i-1], join(filter(a:input_chars[:i-1], { _,x -> x != "\n" }), ''))
endfunction

function! s:make_retval(i, kind, raw, formated_text) abort
  if 0 < a:i
    return { 'kind': a:kind, 'raw': a:raw, 'formated_text': a:formated_text, }
  else
    return {}
  endif
endfunction

function! s:cmp_char(input_chars, i, c) abort
  return get(a:input_chars, a:i, '') == a:c
endfunction

function! s:not_cmp_char(input_chars, i, c) abort
  return !s:cmp_char(a:input_chars, a:i, a:c) && (a:i < len(a:input_chars))
endfunction

function! s:cmp_char_re(input_chars, i, re) abort
  return get(a:input_chars, a:i, '') =~# a:re
endfunction

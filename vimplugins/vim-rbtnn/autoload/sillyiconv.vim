
scriptencoding utf-8

let s:V = vital#of('rbtnn')
let s:Bitwise = s:V.import('Bitwise')

function! s:char2binary(c)
    " echo s:char2binary('c')
    " [0,1,1,0 ,0,0,1,1]
    let bits = [0,0,0,0 ,0,0,0,0]
    if len(a:c) == 1
        let n = 1
        for i in range(7,0,-1)
            let bits[i] = s:Bitwise.and(char2nr(a:c),n) != 0
            let n = n * 2
        endfor
    else
    endif
    return bits
endfunction

function! s:count_1_prefixed(bits)
    " echo s:count_1_prefixed([1,1,0,0 ,0,0,1,1])
    " 2
    let c = 0
    for b in a:bits
        if b == 0
            break
        else
            let c = c + 1
        endif
    endfor
    return c
endfunction

function! sillyiconv#utf_8(input)
    " http://tools.ietf.org/html/rfc3629

    let cs = a:input
    let i = 0
    while i < len(cs)
        let bits = s:char2binary(cs[i])
        let c = s:count_1_prefixed(bits)

        " 1 byte utf-8 char. this is asci char.
        if c == 0
            let i = i + 1

            " 2~4 byte utf-8 char.
        elseif 2 <= c && c <= 4
            let i = i + 1
            " consume b10...
            for _ in range(1,c-1) "{{{
                let bits = s:char2binary(cs[i])
                let c = s:count_1_prefixed(bits)
                if c == 1
                    " ok
                else
                    " not utf-8
                    return 0
                endif
                let i = i + 1
            endfor "}}}
        else
            " not utf-8
            return 0
        endif
    endwhile
    return 1
endfunction

function! sillyiconv#euc_jp(input)
    " http://charset.7jp.net/euc.html

    let cs = a:input
    let i = 0
    while i < len(cs)
        if 0x00 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x7f
            let i = i + 1
        elseif 0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xfe
            let i = i + 1
            if 0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xfe
                let i = i + 1
            else
                return 0
            endif
        elseif 0x8e == char2nr(cs[i])
            let i = i + 1
            if 0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xdf
                let i = i + 1
            else
                return 0
            endif
        else
            return 0
        endif
    endwhile
    return 1
endfunction

function! sillyiconv#shift_jis(input)
    " http://charset.7jp.net/sjis.html

    let cs = a:input
    let i = 0
    while i < len(cs)
        if 0x00 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x7f
            let i = i + 1
        elseif 0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xdf
            let i = i + 1

        elseif (0x81 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x9f)
                \ || (0xe0 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xef)
            let i = i + 1
            if     (0x40 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x7e)
                    \ || (0x80 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xfc)
                let i = i + 1
            else
                return 0
            endif
        elseif 0x8e == char2nr(cs[i])
            let i = i + 1
            if 0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xdf
                let i = i + 1
            else
                return 0
            endif
        else
            return 0
        endif
    endwhile
    return 1
endfunction

function! sillyiconv#iso_2022_jp(input)
    " http://charset.7jp.net/jis.html
    " <mode>
    "   MODE_A : "ASCIIの開始"
    "   MODE_B : "漢字の開始（旧JIS漢字 JIS C 6226-1978）"
    "   MODE_C : "漢字の開始 (新JIS漢字 JIS X 0208-1983）"
    "   MODE_D : "漢字の開始 (JIS X 0208-1990）"
    "   MODE_E : "JISローマ字の開始"
    "   MODE_F : "半角カタカナの開始"

    let cs = a:input
    let mode = "MODE_A"
    let i = 0
    while i < len(cs)
        if 0x1b == char2nr(cs[i]) && 0x24 == char2nr(cs[i+1])  && 0x40 == char2nr(cs[i+2])
            let i = i + 3
            let mode = "MODE_B"
        elseif 0x1b == char2nr(cs[i]) && 0x24 == char2nr(cs[i+1])  && 0x42 == char2nr(cs[i+2])
            let i = i + 3
            let mode = "MODE_C"
        elseif 0x1b == char2nr(cs[i]) && 0x26 == char2nr(cs[i+1])  && 0x40 == char2nr(cs[i+2])
                \ && 0x1b == char2nr(cs[i+3]) && 0x24 == char2nr(cs[i+4])  && 0x42 == char2nr(cs[i+5])
            let i = i + 6
            let mode = "MODE_D"
        elseif 0x1b == char2nr(cs[i]) && 0x28 == char2nr(cs[i+1])  && 0x42 == char2nr(cs[i+2])
            let i = i + 3
            let mode = "MODE_A"
            "elseif 0x1b == char2nr(cs[i]) && 0x28 == char2nr(cs[i+1])  && 0x4a == char2nr(cs[i+2])
            "  let i = i + 3
            "  let mode = "MODE_E"
        elseif 0x1b == char2nr(cs[i]) && 0x28 == char2nr(cs[i+1])  && 0x49 == char2nr(cs[i+2])
            let i = i + 3
            let mode = "MODE_F"

        elseif mode =~ "MODE_A"
            if 0x00 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x7f
                let i = i + 1
            else
                return 0
            endif
        elseif mode =~ "MODE_F"
            if   (0x21 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x5f)
                    \ || (0xa1 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0xdf)
                let i = i + 1
            else
                return 0
            endif
        elseif mode =~ "MODE_B"
                \ || mode =~ "MODE_C"
                \ || mode =~ "MODE_D"
            if   (0x21 <= char2nr(cs[i]) && char2nr(cs[i]) <= 0x7e)
                    \ && (0x21 <= char2nr(cs[i+1]) && char2nr(cs[i+1]) <= 0x7e)
                let i = i + 2
            else
                return 0
            endif
        else
            return 0
        endif
    endwhile
    return 1
endfunction

function! sillyiconv#of(input)
    if sillyiconv#iso_2022_jp(a:input)
        return "iso-2022-jp"
    elseif sillyiconv#utf_8(a:input)
        return "utf-8"
    elseif sillyiconv#euc_jp(a:input)
        return "euc-jp"
    elseif sillyiconv#shift_jis(a:input)
        return "shift_jis"
    else
        throw printf("[sillyiconv] Unknown encoding of %s", string(a:input))
    endif
endfunction

function! sillyiconv#iconv_one_nothrow(val)
    let val = a:val
    try
        let val = sillyiconv#iconv_one(val)
    catch
    endtry
    return val
endfunction

function! sillyiconv#iconv_one(val)
    return get(sillyiconv#iconv([(a:val)]), 0, '')
endfunction

function! sillyiconv#iconv(lines, ...)
    let to_encode = a:0 > 0 ? a:1 : &encoding
    let encoded_lines = map(copy(a:lines), 'iconv(v:val, sillyiconv#of(v:val), to_encode)')
    let lines_str = join(encoded_lines, "\n")
    let lines_str = substitute(lines_str, "\r\n", "\r", "g")
    let lines_str = substitute(lines_str, "\n" ,"\r" ,"g")
    return split(lines_str, "\r")
endfunction

function! sillyiconv#system(cmd)
    return join(sillyiconv#iconv(split(system(a:cmd), "\n")), "\n")
endfunction

function! sillyiconv#qficonv()
    let xs = getqflist()
    for x in xs
        if has_key(x, 'text')
            let x['text'] = sillyiconv#iconv_one_nothrow(x['text'])
        endif
    endfor
    call setqflist(xs)
endfunction


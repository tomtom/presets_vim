" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    27


if !exists('g:presets#pad#tw')
    let g:presets#pad#tw = 72   "{{{2
endif


function! presets#pad#Pad(tw, ...) "{{{3
    let lborder = a:0 >= 1 ? a:1 : 0
    let rborder = a:0 >= 2 ? a:2 : 0
    " TLogVAR a:tw, lborder, rborder
    let tw = get(filter([a:tw, &g:tw], 'v:val != 0'), 0, g:presets#pad#tw)
    " TLogVAR tw, &columns
    let fill = &columns - 4 - tw
    let padding = fill / 2
    " TLogVAR fill, padding, bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
    if padding > 4
        call s:Padding('below', padding - rborder)
        call s:Padding('above', padding - lborder)
        " exec 'vert resize' (tw + 4)
    endif
    " TLogVAR bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
endf


function! s:Padding(where, padding) "{{{3
    if a:padding > 0
        " TLogVAR a:where, a:padding
        try
            " TLogVAR bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
            exec a:where 'vertical' a:padding 'split' s:PadName(a:where)
            " TLogVAR bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
            exec 'vert resize' a:padding
            setlocal buftype=nofile
            setlocal bufhidden=hide
            setlocal noswapfile
            setlocal nobuflisted
            setlocal foldmethod=manual
            setlocal foldcolumn=0
            setlocal nomodifiable
            setlocal nospell
            let &l:winminwidth = a:padding - 3
            setlocal winfixwidth
        finally
            " TLogVAR bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
            wincmd p
            " TLogVAR bufname('%'), bufnr('%'), winnr(), winwidth(winnr())
        endtry
    endif
endf


function! presets#pad#Unpad() "{{{3
    for where in ['below', 'above']
        let bufnr = bufnr(s:PadName(where))
        if bufnr > 0
            let winnr = bufwinnr(bufnr)
            while winnr > 0 && winnr('$') > 1
                exec winnr 'wincmd w'
                wincmd c
                let winnr = bufwinnr(bufnr)
            endwh
        endif
    endfor
endf


function! s:PadName(where) "{{{3
    return printf('__Presets_Padding_%s__', a:where)
endf



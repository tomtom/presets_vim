" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-04-24.
" @Last Change: 2010-04-24.
" @Revision:    87


let s:config_stack = []


if !exists('g:presets#font')
    " :read: let g:presets#font = ... "{{{2
    if has("gui_gtk2")
        let g:presets#font = 'monospace %s'
    elseif has("x11")
        let g:presets#font = '*-lucidatypewriter-medium-r-normal-*-%s-180-*-*-m-*-*'
    elseif has("gui_win32")
        let g:presets#font = 'Lucida_Sans_Typewriter:h%s:cANSI'
    endif
endif


if !exists('g:presets#font_sizes')
    " :read: let g:presets#font_sizes = {...} "{{{2
    let g:presets#font_sizes = {
                \ 'small': 10,
                \ 'normal': 12,
                \ 'big': 14,
                \ 'large': 16,
                \ 'Large': 18,
                \ }
endif


if !exists('g:presets#sets')
    let g:presets#sets = {}   "{{{2

    let g:presets#sets['normalscreen'] = {
                \ '10global': {
                \   '10guioptions': substitute(&guioptions, '\C[mrlRLbT]', '', 'g'),
                \   '20columns': 1000,
                \   '20lines': 1000,
                \ },
                \ '20buffer': {
                \ },
                \ '30window': {
                \ },
                \ }

    let g:presets#sets['darkscreen'] = {
                \ '10global': {
                \   '10foldcolumn': 12,
                \   '10guioptions': substitute(&guioptions, '\C[mrlRLbT]', '', 'g'),
                \   '10laststatus': 0,
                \   '10linespace': 8,
                \   '20guifont': printf(presets#font, g:presets#font_sizes.large),
                \   '30:maximize': ['call presets#Maximize()', printf('set lines=%d columns=%d|winpos %d %d', &lines, &columns, getwinposx(), getwinposy())],
                \ },
                \ '20buffer': {
                \ },
                \ '30window': {
                \   'foldcolumn': 12,
                \ },
                \ }

endif


if has('win16') || has('win32') || has('win64')
    fun! presets#Maximize() "{{{3
        simalt ~x
    endf
else
    fun! presets#Maximize() "{{{3
        set lines=99999 columns=99999 
    endf
endif


function! presets#Complete(ArgLead, CmdLine, CursorPos) "{{{3
    let sets = keys(g:presets#sets)
    if !empty(a:ArgLead)
        let slen = len(a:ArgLead)
        call filter(sets, 'strpart(v:val, 0, slen) ==# a:ArgLead')
    endif
    return sets
endf


function! presets#Push(name) "{{{3
    if has_key(g:presets#sets, a:name)
        let set = g:presets#sets[a:name]
        let previous = {}
        call s:Set(set, previous)
        call add(s:config_stack, previous)
        redraw
    else
        echoerr 'Presets: Unknown set: '. a:name
    endif
endf


function! presets#Pop() "{{{3
    if !empty(s:config_stack)
        let previous = remove(s:config_stack, -1)
        TLogVAR previous
        call s:Set(previous, {})
    endif
endf


function! s:OptName(name) "{{{3
    return substitute(a:name, '^\d\+', '', '')
endf


function! s:Set(preset, save) "{{{3
    for [type0, config] in sort(items(a:preset))
        let type = s:OptName(type0)
        let a:save[type] = {}
        call s:Set_{type}(config, a:save[type])
    endfor
endf


function! s:DoValue(save_config, opt, val) "{{{3
    if type(a:val) == 3
        if len(a:val) >= 2
            let a:save_config[a:opt] = a:val[1]
        endif
        return a:val[0]
    else
        return a:val
    endif
endf


function! s:Set_global(config, save_config) "{{{3
    for [opt0, val] in sort(items(a:config))
        let opt = s:OptName(opt0)
        if opt[0] == ':'
            exec s:DoValue(a:save_config, opt, val)
        else
            exec 'let a:save_config[opt0] = &g:'. opt
            exec 'let &g:'. opt .' = val'
        endif
        unlet val
    endfor
endf


function! s:Set_window(config, save_config) "{{{3
    let winnr = winnr()
    for [opt0, val] in sort(items(a:config))
        let opt = s:OptName(opt0)
        if opt[0] == ':'
            exec 'windo '. s:DoValue(a:save_config, opt, val)
        else
            exec 'let a:save_config[opt0] = &l:'. opt
            exec 'windo let &l:'. opt .' = val'
        endif
    endfor
    exec winnr .'wincmd w'
endf


function! s:Set_buffer(config, save_config) "{{{3
    let bufnr = bufnr('%')
    for [opt0, val] in sort(items(a:config))
        let opt = s:OptName(opt0)
        if opt[0] == ':'
            exec 'bufdo '. s:DoValue(a:save_config, opt, val)
        else
            exec 'let a:save_config[opt0] = &l:'. opt
            exec 'bufdo let &l:'. opt .' = val'
        endif
    endfor
    exec bufnr .'buffer'
endf



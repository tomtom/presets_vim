" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-04-24.
" @Last Change: 2010-05-04.
" @Revision:    153


let s:config_stack = []


if !exists('g:presets#font')
    " You might want to change this variable according to your 
    " preferences.
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
    " You might want to change this variable according to your 
    " preferences.
    " :read: let g:presets#font_sizes = {...} "{{{2
    let g:presets#font_sizes = {
                \ 'tiny': 8,
                \ 'small': 9,
                \ 'normal': 10,
                \ 'Normal': 11,
                \ 'big': 12,
                \ 'large': 14,
                \ 'Large': 16,
                \ }
endif


if !exists('g:presets#sets')
    " A dictionary with the keys:
    "
    "   include ... A list of other presets
    "   global  ... A dictionary of global options
    "   window  ... A dictionary of window-local options
    "   buffer  ... A dictionary of buffer-local options
    "
    " The option dictionaries keys usually are options names than should 
    " be set to its value. If the key starts with a colon (:) though, 
    " the value is an ex command.
    "
    " If the key defines a ex command, the value can be either a string 
    " or a list of two strings, where the second string is a command 
    " that undoes the effect of the first string when |:execute|d. If 
    " the value of a string begins with asterisk "*", the string is 
    " evaluated first via |eval()| -- the result of the evaluation 
    " should be the actual ex command.
    "
    " Any keys can be prepended with a number that defines its priority.
    let g:presets#sets = {}   "{{{2

    for [s:name, s:size] in items(g:presets#font_sizes)
        let g:presets#sets[s:name] = {
                \ '10global': {
                \   '30guifont': printf(presets#font, s:size),
                \ },
                \}
    endfor
    unlet s:name s:size

    let g:presets#sets['plain'] = {
                \ '10global': {
                \   '10guioptions': substitute(&guioptions, '\C[mrlRLbT]', '', 'g'),
                \ },
                \}
    
    let g:presets#sets['full'] = {
                \ '10global': {
                \   '30:maximize': ['set lines=1000 columns=1000', '*printf("set lines=%d columns=%d|winpos %d %d", &lines, &columns, getwinposx(), getwinposy())'],
                \ },
                \}


    let g:presets#sets['screen'] = {
                \ '00include': ['plain', 'full'],
                \ '10global': {
                \   '10foldcolumn': 1,
                \ },
                \ '20buffer': {
                \ },
                \ '30window': {
                \   'foldcolumn': 1,
                \ },
                \}

    let g:presets#sets['darkscreen'] = {
                \ '00include': ['plain'],
                \ '10global': {
                \   '10foldcolumn': 12,
                \   '10laststatus': 0,
                \   '10linespace': 8,
                \   '20:maximize': ['call presets#Maximize()', '*printf("set lines=%d columns=%d|winpos %d %d", &lines, &columns, getwinposx(), getwinposy())'],
                \   '30guifont': printf(presets#font, g:presets#font_sizes.large),
                \ },
                \ '20buffer': {
                \ },
                \ '30window': {
                \   'foldcolumn': 12,
                \ },
                \}

endif


if !exists('*presets#Maximize')
    if has('win16') || has('win32') || has('win64')

        " Maximize the window.
        " You might need to redefine it if it doesn't work for you.
        fun! presets#Maximize() "{{{3
            simalt ~x
        endf

    else

        " :nodoc:
        fun! presets#Maximize() "{{{3
            set lines=1000 columns=1000 
        endf

    endif
endif


" :nodoc:
function! presets#Complete(ArgLead, CmdLine, CursorPos) "{{{3
    let sets = keys(g:presets#sets)
    if !empty(a:ArgLead)
        let slen = len(a:ArgLead)
        call filter(sets, 'strpart(v:val, 0, slen) ==# a:ArgLead')
    endif
    return sets
endf


" Push the preset NAME onto the configuration stack.
function! presets#Push(name) "{{{3
    let names = presets#Complete(a:name, '', 0)
    if len(names) != 1
        echoerr 'Presets: Ambivalent or unknown name: '. a:name .' ('. join(keys(g:presets#sets), ', ') .')'
    else
        let name = names[0]
        if has_key(g:presets#sets, name)
            let set = g:presets#sets[name]
            let previous = {}
            call s:Set(set, previous, 0)
            call add(s:config_stack, previous)
            " redraw
        else
            echoerr 'Presets: Unknown set: '. name
        endif
    endif
endf


" Pop the last preset from the configuration stack.
function! presets#Pop() "{{{3
    if !empty(s:config_stack)
        let previous = remove(s:config_stack, -1)
        " TLogVAR previous
        call s:Set(previous, {}, 1)
    endif
endf


function! s:OptName(name) "{{{3
    return substitute(a:name, '^\d\+', '', '')
endf


function! s:Items(dict, descending_order) "{{{3
    let items = sort(items(a:dict))
    " if a:descending_order
    "     call reverse(items) 
    " endif
    return items
endf


function! s:Set(preset, save, descending_order) "{{{3
    for [type0, config] in s:Items(a:preset, a:descending_order)
        let type = s:OptName(type0)
        if type == 'include'
            for name in config
                let preset = g:presets#sets[name]
                call s:Set(preset, a:save, a:descending_order)
            endfor
        else
            if !has_key(a:save, type)
                let a:save[type] = {}
            endif
            call s:Set_{type}(config, a:save[type], a:descending_order)
        endif
        unlet config
    endfor
endf


function! s:Value(string) "{{{3
    if a:string[0] == '*'
        let val = eval(strpart(a:string, 1))
        " TLogVAR val
    else
        let val = a:string
    endif
    return val
endf


function! s:DoValue(save_config, opt, val) "{{{3
    if type(a:val) == 3
        " TLogVAR a:val
        if len(a:val) >= 2
            let a:save_config[a:opt] = s:Value(a:val[1])
        endif
        return s:Value(a:val[0])
    else
        return s:Value(a:val)
    endif
endf


function! s:Set_global(config, save_config, descending_order) "{{{3
    for [opt0, val] in s:Items(a:config, a:descending_order)
        let opt = s:OptName(opt0)
        " TLogVAR opt, val
        if opt[0] == ':'
            exec s:DoValue(a:save_config, opt, val)
        else
            exec 'let a:save_config[opt0] = &g:'. opt
            exec 'let &g:'. opt .' = val'
        endif
        unlet val
    endfor
endf


function! s:Set_window(config, save_config, descending_order) "{{{3
    let winnr = winnr()
    for [opt0, val] in s:Items(a:config, a:descending_order)
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


function! s:Set_buffer(config, save_config, descending_order) "{{{3
    let bufnr = bufnr('%')
    for [opt0, val] in s:Items(a:config, a:descending_order)
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



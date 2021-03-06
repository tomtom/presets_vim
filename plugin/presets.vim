" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/presets_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-04-24.
" @Last Change: 2012-09-16.
" @Revision:    51
" GetLatestVimScripts: 0 0 :AutoInstall: presets.vim
" Quickly switch between vim configurations


if &cp || exists("loaded_presets")
    finish
endif
let loaded_presets = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:presets_default')
    " The preset to set after startup.
    let g:presets_default = ''   "{{{2
endif


" :display: :Preset[!] [PRESET]
" Push the configuration of PRESET.
"
" If no PRESET argument is given, list the presets on the configuration 
" stack.
"
" With [!], pop previous presets from the configuration stack. This 
" happens before pushing new presets.
"
" This command supports certain special names -- see |presets#Push()| 
" for details.
command! -bang -nargs=? -complete=customlist,presets#Complete Preset
            \ if !empty("<bang>") | call presets#Pop(-1) | endif |
            \ if empty(<q-args>) |
            \   if empty("<bang>") | call presets#Pop(1) | call presets#List(0) | endif |
            \ else |
            \   call presets#Push(<q-args>) |
            \ endif


" List the presets on the configuration stack.
command! ListPresets call presets#List(1)


" @TPluginInclude
augroup Presets
    autocmd!
    if exists('g:presets_default') && !empty(g:presets_default)
        if has('vim_starting')
            exec 'autocmd VimEnter * Preset!' g:presets_default
        else
            exec 'Preset!' g:presets_default
        endif
    endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo

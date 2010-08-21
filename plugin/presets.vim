" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-04-24.
" @Last Change: 2010-08-21.
" @Revision:    25
" GetLatestVimScripts: 0 0 :AutoInstall: presets.vim
" Quickly switch between vim configurations


if &cp || exists("loaded_presets")
    finish
endif
let loaded_presets = 1

let s:save_cpo = &cpo
set cpo&vim

" :display: :Preset[!] [PRESET]
" Push the configuration of PRESET.
"
" With [!], pop the previous preset from the configuration stack before 
" pushing PRESET.
"
" If no PRESET argument is given, pop the previous preset from the 
" configuration stack.
"
" This command supports certain special names -- see |presets#Push()| 
" for details.
command! -bang -nargs=? -complete=customlist,presets#Complete Preset
            \ if empty(<q-args>) |
            \   call presets#Pop() |
            \ else |
            \   if !empty("<bang>") | call presets#Pop() | endif |
            \   call presets#Push(<q-args>) |
            \ endif


let &cpo = s:save_cpo
unlet s:save_cpo
finish

CHANGES:
0.1
- Initial release


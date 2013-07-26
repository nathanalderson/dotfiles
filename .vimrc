set nocompatible

"vundle stuff
filetype off
if has("win32") || has("win16")
    let bundle_path = "C:/Program\\ Files\\ -\\ Portable/Vim/vimfiles/bundle"
else
    let bundle_path = "~/.vim/bundle"
endif
execute "set rtp+=".bundle_path.'/vundle'
call vundle#rc(bundle_path)
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'godlygeek/tabular.git'
Bundle 'altercation/vim-colors-solarized.git'
Bundle 'tpope/vim-repeat.git'
Bundle 'tpope/vim-unimpaired.git'
Bundle 'scrooloose/nerdcommenter.git'
Bundle 'tpope/vim-surround.git'
Bundle 'chriskempson/vim-tomorrow-theme.git'
Bundle 'nathanalderson/perforce.vim.git'
Bundle 'nathanalderson/Command-T.git'
Bundle 'pangloss/vim-javascript'
Bundle 'ervandew/supertab'
Bundle 'mileszs/ack.vim'
Bundle 'JDeuce/jinja-syntax'
Bundle 'groenewege/vim-less'
Bundle 'chriskempson/base16-vim'
Bundle 'kana/vim-textobj-function'
Bundle 'kana/vim-textobj-indent'
Bundle 'kana/vim-textobj-line'
Bundle 'kana/vim-textobj-syntax'
Bundle 'kana/vim-textobj-lastpat'
Bundle 'kana/vim-textobj-django-template'
Bundle 'lucapette/vim-textobj-underscore'
Bundle 'kana/vim-textobj-user'
Bundle 'sorin-ionescu/python.vim'
Bundle 'mattdbridges/bufkill.vim'
" vim-scripts repos
if &t_Co >= 256 || has("gui_running")
    Bundle 'CSApprox'
endif
Bundle 'VimClojure'
" non github repos
" Bundle 'git://git.wincent.com/command-t.git'

source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

filetype plugin indent on

if has("gui_running")
    " do GUI-only stuff
    if &lines < 35
        set lines=35
        set columns=130
    endif
    set guioptions-=T  "remove toolbar
    set guioptions+=c  "use non-modal confirm prompts
else
    " do terminal-only stuff
endif

if has("win32") || has("win16")
    set guifont=Inconsolata:h12:cANSI
    set csprg=C:\Program\ Files\ -\ Portable\cscope158a\cscope.exe
    let vimfilesdir = "C:/temp/vim_backup//"
    " silent execute '!del "c:\temp\vim_backup\*~"'

    let s:p4root = "C:\\p4workspace\\"

    " maximize the window
    command! MaximizeWindow simalt ~x
else
    set guifont=Inconsolata\ 12
    let vimfilesdir = "~/.vim/backup//"
    let s:p4root = "/home/nalderso/p4workspace/"
    " silent execute '!rm "~/.vim/backup/*~"'
endif

" colors
set background=dark
if has("gui_running")
    colorscheme base16-eighties
else
    colorscheme Tomorrow-Night  " can't get base16 to look right in the terminal
endif

" tabs
function! SetTabWidth(size)
    execute "set ts=".a:size
    execute "set shiftwidth=".a:size
    execute "set softtabstop=".a:size
    set expandtab
endfunction
command! -nargs=* SetTabWidth call SetTabWidth('<args>')
call SetTabWidth(4)

" Enable nice word wrapping
function! Wrap()
    set wrap
    set linebreak
    set nolist
    set textwidth=0
    set wrapmargin=0
endfunction
command! Wrap call Wrap()

" basic usability
set modelines=0
set hidden
set scrolloff=3
set clipboard=unnamed
set autoindent
set nowrapscan
set ttyfast
set wildmenu
set wildmode=list:full
set wildignore+=*.pyc,*.o,*.obj.,*.d,.git,*.gcno,*.gcda
if version >= 703
    set relativenumber
endif
set encoding=utf-8
set list
set listchars=tab:▸\ 
set listchars+=trail:·
set autoread
set nowrap
set textwidth=100
set formatoptions-=t
if &t_Co >= 256 || has("gui_running")
    set cursorline
else
    set nocursorline
endif
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=
command! W w
command! Q q

" backups and such
set nobackup
set nowritebackup
execute "set backupdir=".vimfilesdir
execute "set directory=".vimfilesdir
if version >= 703
    execute "set undodir=".vimfilesdir
    set undofile
endif

" searching
nnoremap / /\v
vnoremap / /\v
cnoremap s/ s/\v
nnoremap <leader><space> :noh<cr>
set ignorecase
set smartcase
set gdefault
set nohlsearch

" random custom mappings
inoremap jk <ESC>
nnoremap j gj
nnoremap k gk
nnoremap <leader>q gqip
nnoremap <leader>v V`]
"nnoremap <leader><leader> <c-^>
nnoremap <leader>o :only<CR>
nnoremap <S-h> ^
nnoremap <S-l> $
nnoremap <leader>. @:
nnoremap <F8> :set nohlsearch!<CR>
" nnoremap <S-C-W> :0,bd<CR>
nnoremap <leader>h :cd %:p:h<CR>
nmap <F4> :cn<CR>
nmap <F3> :cp<CR>

" window management
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <leader>- <C-w>s<C-w>j
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"insert mode custom keymapping
:inoremap <C-]> <C-X><C-]>
:inoremap <C-F> <C-X><C-F>
:inoremap <C-D> <C-X><C-D>
:inoremap <C-L> <C-X><C-L>
:inoremap <C-BS> <C-W>

" Tabularize
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a{ :Tabularize /{<CR>
vmap <Leader>a{ :Tabularize /{<CR>
nmap <Leader>a: :Tabularize /:<CR>
vmap <Leader>a: :Tabularize /:<CR>
nmap <Leader>a, :Tabularize /,/l0l1<CR>
vmap <Leader>a, :Tabularize /,/l0l1<CR>
nmap <Leader>a\| :Tabularize /\|<CR>
vmap <Leader>a\| :Tabularize /\|<CR>
vmap <Leader>aw :Tabularize /\v\S+/l1l0<CR>
nmap <Leader>a/ :Tabularize /\v\/+<CR>
vmap <Leader>a/ :Tabularize /\v\/+<CR>
" Tabularize (first match only)
nmap <Leader>a1= :Tabularize /^.\{-}\zs=<CR>
vmap <Leader>a1= :Tabularize /^.\{-}\zs=<CR>
nmap <Leader>a1{ :Tabularize /^.\{-}\zs{<CR>
vmap <Leader>a1{ :Tabularize /^.\{-}\zs{<CR>
nmap <Leader>a1: :Tabularize /^.\{-}\zs:<CR>
vmap <Leader>a1: :Tabularize /^.\{-}\zs:<CR>
nmap <Leader>a1, :Tabularize /^.\{-}\zs,/l0l1<CR>
vmap <Leader>a1, :Tabularize /^.\{-}\zs,/l0l1<CR>
nmap <Leader>a1\| :Tabularize /^.\{-}\zs\|<CR>
vmap <Leader>a1\| :Tabularize /^.\{-}\zs\|<CR>
vmap <Leader>a1w :Tabularize /^.\{-}\zs\S+/l1l0<CR>

" Command-T
let g:CommandTMaxFiles=50000
let g:CommandTMatchWindowReverse=1
let g:CommandTCancelMap=['<ESC>','<C-c>']   "doesn't work in zsh by default?
let g:CommandTDelayUpdate=0
let g:BufKillBindings=1     "skip bufkill bindings which interfere with Command-T
set updatetime=250
nnoremap <silent> <leader>g :CommandTTag<CR>

" Turn off buffkill leader-key mappings which conflict with Command-T \b
let g:BufKillCreateMappings=0

" perforce integration
nnoremap @p4e :!p4 edit %:e

" additional extensions
au BufNewFile,BufRead *.bps set filetype=tcl
au BufNewFile,BufRead *.jsonp set filetype=javascript
au BufNewFile,BufRead *.rmd set filetype=cpp

" Ignore timestamp lines in Google Test output
let &errorformat = '%-G%.%#[Timestamp ]%.%#' . ',' . &efm

" Comments
let NERDSpaceDelims=1

" CScope
set cscopetag                           " CTRL-] uses cscope and tags file
set csto=0                              " check cscope first, then tags file
set cscopequickfix=s-,c-,d-,i-,t-,e-    " use quickfix list
set cspc=0                              " show full path
nmap <leader>ss mT:cs find s <C-R>=expand("<cword>")<CR><CR>'T:cope<CR>
nmap <leader>s  :cs find s 

" python.vim
let python_highlight_all=1

" Manage different projects
let s:projects = {
    \   'taml':          { 'path': s:p4root."tacore/TAMainline/tree/source/"
    \                    , 'type': 'tacore' }
    \ , 'sr63':          { 'path': s:p4root."tacore/rel/SR_6.3.x-R/tree/source/"
    \                    , 'type': 'tacore' }
    \ , 'nd':            { 'path': s:p4root."package/ipv6_neighbor_discovery/main/"
    \                    , 'type': 'package' }
    \ , 'ip_utilities':  { 'path': s:p4root."package/ip_utilities/main/"
    \                    , 'type': 'package' }
    \ , 'adtran_io':     { 'path': s:p4root."package/adtran_io/main/"
    \                    , 'type': 'package' }
    \ }
function! OpenProject(project)
    let s:current_project = a:project
    cd `=s:projects[s:current_project]['path']`
    set nocsverb
    cs add .
    cs add ..
    cs add ../..
    set csverb
    let file_list = '../../cscope.files'
    if s:projects[s:current_project]['type'] == 'tacore' && filereadable(file_list)
        let g:CommandTListFile = file_list
    else
        let g:CommandTListFile = ''
    endif
    CommandTFlush
endfunction
command! -complete=customlist,ListProjects -nargs=1 Project call OpenProject(<f-args>)
function! ListProjects(A,L,P)
    return keys(s:projects)
endfunction

function! Make()
    if s:projects[s:current_project]['type'] == 'package'
        cd linux
        make -j all
        cd ..
        botright copen
    endif
endfunction
command! Make call Make()

command! Web  cd web/modules

" TODO:
" - Consider remapping Caps-Lock and/or the weird menu key to something more
"   useful
" - Extend surround to allow /* */

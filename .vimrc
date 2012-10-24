set nocompatible

"vundle stuff
filetype off
if has("win32") || has("win16")
    let vundle_path = "C:/Program\\ Files\\ -\\ Portable/Vim/vimfiles/bundle/vundle"
else
    let vundle_path = "~/.vim/bundle/vundle"
endif
execute "set rtp+=".vundle_path
call vundle#rc()
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'godlygeek/tabular.git'
Bundle 'altercation/vim-colors-solarized.git'
Bundle 'tpope/vim-repeat.git'
Bundle 'tpope/vim-unimpaired.git'
Bundle 'tpope/vim-commentary.git'
Bundle 'tpope/vim-surround.git'
Bundle 'chriskempson/vim-tomorrow-theme.git'
Bundle 'nathanalderson/perforce.vim.git'
Bundle 'pangloss/vim-javascript'
Bundle 'ervandew/supertab'
Bundle 'mileszs/ack.vim'
Bundle 'JDeuce/jinja-syntax'
Bundle 'groenewege/vim-less'
Bundle 'hced/bufkill-vim'
" vim-scripts repos
Bundle 'python.vim'
" non github repos
Bundle 'git://git.wincent.com/command-t.git'

source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

filetype plugin indent on

set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

if has("gui_running")
    " do GUI-only stuff
    set lines=35
    set columns=130
    set guioptions-=T  "remove toolbar

else
    " do terminal-only stuff
    colorscheme default
endif 

if has("win32") || has("win16")
    set guifont=Inconsolata:h12:cANSI
    set csprg=C:\Program\ Files\ -\ Portable\cscope157a\cscope.exe
    let vimfilesdir = "C:/temp/vim_backup//"
    " silent execute '!del "c:\temp\vim_backup\*~"'

    " cd shortcuts
    nnoremap @frodo :cd C:\p4workspace\Frodo\tree\source\<CR>
    nnoremap @web   :cd C:\projects\WEBGUI_5K\web\modules\<CR>

    " maximize the window
    command MaximizeWindow simalt ~x
else
    set guifont=Inconsolata\ 12
    let vimfilesdir = "~/.vim/backup//"
    " silent execute '!rm "~/.vim/backup/*~"'
endif

" basic usability
colorscheme Tomorrow-Night
set modelines=0
set hidden
set ts=4
set shiftwidth=4
set softtabstop=4
set expandtab
set scrolloff=3
set clipboard=unnamed
set autoindent
set nowrapscan
set ttyfast
set wildmenu
set wildmode=list:full
set wildignore+=*.pyc
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
set cursorline
command W w
command Q q

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
nnoremap <leader><space> :noh<cr>
set ignorecase
set smartcase
set gdefault
set nohlsearch

" random custom mappings
inoremap jj <ESC>
nnoremap <leader>q gqip
nnoremap <leader>v V`]
"nnoremap <leader><leader> <c-^>
nnoremap <leader>o :only<CR>
nnoremap <C-h> ^
nnoremap <C-l> $
nnoremap <leader>. @:
nnoremap <F8> :set nohlsearch!<CR>
" nnoremap <C-S-w> :0,bd<CR>
nnoremap <leader>h :cd %:p:h<CR>

" window management
nnoremap <leader>w <C-w>v<C-w>l

"insert mode custom keymapping
:inoremap  
:inoremap  
:inoremap  
:inoremap  
:inoremap <C-BS> 

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

" Command-T
let g:CommandTMaxFiles=50000
let g:CommandTMatchWindowReverse=1
let g:CommandTCancelMap=['<ESC>','<C-c>']   "doesn't work in zsh by default?
nnoremap <silent> <leader>g :CommandTTag<CR>

" perforce integration
nnoremap @p4e :!p4 edit %:e

" additional extensions
au BufNewFile,BufRead *.bps set filetype=tcl
au BufNewFile,BufRead *.jsonp set filetype=javascript

" TODO:
" - Consider remapping Caps-Lock and/or the weird menu key to something more
"   useful
" - Extend surround to allow /* */

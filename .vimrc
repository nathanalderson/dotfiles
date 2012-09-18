set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

"Pathogen
call pathogen#infect()
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
    set cursorline
    set lines=50
    set columns=200
    set nowrap
    set guioptions-=T  "remove toolbar

    " command-T
    nnoremap <silent> <leader>g :CommandTTag<CR>
    let g:CommandTMatchWindowReverse=1
else
    " do terminal-only stuff
    colorscheme default
endif 

if has("win32") || has("win16")
    set guifont=Consolas:h12:cANSI
    set csprg=C:\Program\ Files\ -\ Portable\cscope157a\cscope.exe
    set backupdir=C:/temp/vim_backup//
    set directory=C:/temp/vim_backup//
    set undodir=C:/temp/vim_backup//
    " silent execute '!del "c:\temp\vim_backup\*~"'

    " cd shortcuts
    nnoremap @frodo :cd C:\p4workspace\Frodo\tree\source\<CR>
    nnoremap @web   :cd C:\projects\WEBGUI_5K\web\modules\<CR>
else
    set guifont=Inconsolata\ 12
    set backupdir=~/.vim/backup//
    set directory=~/.vim/backup//
    set undodir=~/.vim/backup//
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
set undofile
set clipboard=unnamed
set autoindent
set nowrapscan
set ttyfast
set wildmenu
set wildmode=list:full
set relativenumber
set encoding=utf-8
set list
set listchars=tab:▸\ 
set listchars+=trail:·
set autoread
set nobackup
set nowritebackup

" searching
nnoremap / /\v
vnoremap / /\v
nnoremap <leader><space> :noh<cr>
set ignorecase
set smartcase
set gdefault
set nohlsearch

" random custom mappings
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
nmap <Leader>a, :Tabularize /,<CR>
vmap <Leader>a, :Tabularize /,<CR>
nmap <Leader>a> :Tabularize /=><CR>
vmap <Leader>a> :Tabularize /=><CR>
nmap <Leader>a\| :Tabularize /\|<CR>
vmap <Leader>a\| :Tabularize /\|<CR>

" Command-T
let g:CommandTMaxFiles=50000

" perforce integration
nnoremap @p4e :!p4 edit %:e

" TODO:
" - Consider remapping Caps-Lock and/or the weird menu key to something more
"   useful
" - Extend surround to allow /* */

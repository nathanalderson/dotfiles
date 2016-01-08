set nocompatible
set shell=bash
set ssl

"vundle stuff
filetype off
if has("win32") || has("win16")
    let bundle_path = "C:/Program\\ Files\\ -\\ Portable/Vim/vimfiles/bundle"
else
    let bundle_path = "~/.vim/bundle"
endif
execute "set rtp+=".bundle_path.'/Vundle.vim'
call vundle#begin(bundle_path)
Plugin 'gmarik/Vundle.vim'

" My Plugins here:
"
" original repos on github
Plugin 'godlygeek/tabular.git'
Plugin 'altercation/vim-colors-solarized.git'
Plugin 'tpope/vim-repeat.git'
Plugin 'tpope/vim-unimpaired.git'
Plugin 'scrooloose/nerdcommenter.git'
Plugin 'tpope/vim-surround.git'
Plugin 'chriskempson/vim-tomorrow-theme.git'
Plugin 'nathanalderson/perforce.vim.git'
Plugin 'pangloss/vim-javascript'
Plugin 'ervandew/supertab'
Plugin 'mileszs/ack.vim'
Plugin 'rking/ag.vim'
Plugin 'JDeuce/jinja-syntax'
Plugin 'groenewege/vim-less'
Plugin 'chriskempson/base16-vim'
Plugin 'kana/vim-textobj-function'
Plugin 'kana/vim-textobj-indent'
Plugin 'kana/vim-textobj-line'
Plugin 'kana/vim-textobj-syntax'
Plugin 'kana/vim-textobj-lastpat'
Plugin 'kana/vim-textobj-django-template'
Plugin 'lucapette/vim-textobj-underscore'
Plugin 'kana/vim-textobj-user'
Plugin 'sorin-ionescu/python.vim'
Plugin 'mattdbridges/bufkill.vim'
Plugin 'scrooloose/syntastic.git'
Plugin 'tfnico/vim-gradle'
Plugin 'derekwyatt/vim-scala'
Plugin 'endel/vim-github-colorscheme'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-scripts/fontzoom.vim'
Plugin 'regedarek/ZoomWin'
Plugin 'nathanalderson/yang.vim'
Plugin 'wincent/command-t'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-commentary'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-dispatch'
Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
Plugin 'w0ng/vim-hybrid.git'
Plugin 'morhetz/gruvbox'
" Plugin 'nathanalderson/Command-T.git'
" vim-scripts repos
if &t_Co >= 256 || has("gui_running")
    Plugin 'CSApprox'
endif
Plugin 'VimClojure'

call vundle#end()

source $VIMRUNTIME/mswin.vim
set selectmode=

filetype plugin indent on

if has("gui_running")
    " do GUI-only stuff
    if &lines < 35
        set lines=35
        set columns=130
    endif
    set guioptions-=T  "remove toolbar
    set guioptions-=m  "remove menu
    set guioptions+=c  "use non-modal confirm prompts
else
    " do terminal-only stuff
endif

if has("win64") || has("win32") || has("win16")
    set guifont=Consolas:h11:cANSI
    set csprg=C:\Program\ Files\ -\ Portable\cscope158a\cscope.exe
    let vimfilesdir = "C:/temp/vim_backup//"
    " silent execute '!del "c:\temp\vim_backup\*~"'

    let s:p4root = "C:\\p4workspace\\"

    " maximize the window
    command! MaximizeWindow simalt ~x
    set clipboard=unnamed
else
    if has("gui_running")
        set guifont=Inconsolata\ for\ PowerLine\ 12,Inconsolata\ 12
    else
        set guifont=Inconsolata\ 12
    endif
    let vimfilesdir = "~/.vim/backup//"
    let s:p4root = "/home/nalderso/p4workspace/"
    " silent execute '!rm "~/.vim/backup/*~"'
    set clipboard=unnamedplus
endif

" colors
set background=dark
if has("gui_running")
    colorscheme gruvbox
else
    colorscheme gruvbox
endif

" tabs
function! SetTabWidth(size)
    execute "set ts=".a:size
    execute "set shiftwidth=".a:size
    execute "set softtabstop=".a:size
    set expandtab
endfunction
command! -nargs=* SetTabWidth call SetTabWidth('<args>')
call SetTabWidth(4) " default tabwidth is 4
autocmd Filetype scala call SetTabWidth(2)
autocmd Filetype ruby call SetTabWidth(2)
autocmd Filetype javascript call SetTabWidth(2)

" Enable nice word wrapping
function! Wrap()
    set wrap
    set linebreak
    set nolist
    set textwidth=0
    set wrapmargin=0
endfunction
command! Wrap call Wrap()

" Trim trailing whitespace
command! Trim :%s/\v\s+$/

" Don't use Ex mode, use Q for formatting
map Q gq

" Use the mouse
if has('mouse')
  set mouse=a
endif

" basic usability
set modelines=0
set hidden
set scrolloff=3
set autoindent
set nowrapscan
set ttyfast
set wildmode=list:full
set wildignore+=*.pyc,*.o,*.obj.,*.d,.git,*.gcno,*.gcda,venv,*.class,*.jar
set number
set list
let &listchars="tab:▸ ,trail:·,extends:…,precedes:…"
set nowrap
set textwidth=100
set formatoptions-=t
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=
if &t_Co >= 256 || has("gui_running")
    set cursorline
else
    set nocursorline
endif
autocmd GUIEnter * set visualbell t_vb=
" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
command! W w
command! Q q
command! CD cd %:p:h

" autosave on focus lost
autocmd FocusLost * silent! wa

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
nmap <C-tab> <C-^>
nnoremap Y y$
nnoremap & :&&<CR>
xnoremap & :&&<CR>
nnoremap <leader>* Oprintln(s"***** ")<ESC>hi
vnoremap L $
vnoremap H ^

" window management
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <leader>- <C-w>s<C-w>j
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"insert mode custom keymapping
inoremap <C-]> <C-X><C-]>
inoremap <C-F> <C-X><C-F>
inoremap <C-D> <C-X><C-D>
inoremap <C-L> <C-X><C-L>
inoremap <C-BS> <C-W>

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
let g:CommandTTraverseSCM="pwd"
set updatetime=250
nnoremap <silent> <leader>g :CommandTTag<CR>

" ctrl-p
" let g:ctrlp_user_command = ['build.gradle', 'cd %s && git ls-files']
let g:ctrlp_root_markers = ['build.gradle']
nnoremap <silent> <leader>t :CtrlP<CR>
nnoremap <silent> <leader>b :CtrlPBuffer<CR>
nnoremap <silent> <leader>m :CtrlPMRUFiles<CR>
nnoremap <leader>p :let g:ctrlp_working_path_mode='a'<CR>

" Syntastic
nnoremap <S-F5> :SyntasticCheck<CR>
let g:syntastic_python_checkers=['pylint']
let g:syntastic_cpp_checkers=['cppcheck']
let g:syntastic_python_pylint_post_args = '--disable=C'
let g:syntastic_enable_balloons=0
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=0     " this feature doesn't work well with the perforce plugin.
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': [] }

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
set errorformat^=%-GIn\ file\ included\ from\ %f:%l:%c:,%-GIn\ file
           \\ included\ from\ %f:%l:%c\\,,%-GIn\ file\ included\ from\ %f
           \:%l:%c,%-GIn\ file\ included\ from\ %f:%l

" Comments
let NERDSpaceDelims=1
autocmd FileType groovy set commentstring=//\ %s

" NerdTree
nmap <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" CScope
set cscopetag                           " CTRL-] uses cscope and tags file
set csto=0                              " check cscope first, then tags file
set cscopequickfix=s-,c-,d-,i-,t-,e-    " use quickfix list
set cspc=0                              " show full path
nmap <leader>ss mT:cs find s <C-R>=expand("<cword>")<CR><CR>'T:cope<CR>
nmap <leader>s  :cs find s 

" python.vim
let python_highlight_all=1

" Ag and Ack
let g:ackprg="ack --column --smart-case"
let g:ag_mapping_message=0
let g:agprg="ag --column --smart-case"

"Airline
if &guifont =~ 'PowerLine'
  let g:airline_powerline_fonts=1
endif
let g:airline_detect_modified=1
let g:airline#extensions#whitespace#enabled = 0
let g:airline_mode_map = {
  \ '__' : '-',
  \ 'n'  : 'N',
  \ 'i'  : 'I',
  \ 'R'  : 'R',
  \ 'c'  : 'C',
  \ 'v'  : 'V',
  \ 'V'  : 'V',
  \ '' : 'V',
  \ 's'  : 'S',
  \ 'S'  : 'S',
  \ '' : 'S',
  \ }

"fugitive
autocmd User fugitive if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif
autocmd BufReadPost fugitive://* set bufhidden=delete

" TODO:
" - Consider remapping Caps-Lock and/or the weird menu key to something more
"   useful
" - Extend surround to support /* */
" - Extend surround to support spaces
" - Check out projectionist.vim

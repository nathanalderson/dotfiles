set nocompatible
set shell=bash
set ssl
set termguicolors

" add dotfiles dir to beginning of runtimepath
set rtp^=~/dotfiles/.vim

" *******
" Initialize vim-plug
" *******
if has("win32") || has("win16")
  let bundle_path = "C:/Program\\ Files\\ -\\ Portable/Vim/vimfiles/bundle"
elseif has('nvim')
  let bundle_path = "~/.config/nvim/bundle"
  let install_path = stdpath('data') . '/site/autoload/plug.vim'
else
  let bundle_path = "~/.vim/bundle"
  let install_path = "~/.vim/autoload/plug.vim"
endif

" download vim-plug if needed
if empty(glob(install_path))
  execute '!curl -fLo ' . install_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(bundle_path)

source $VIMRUNTIME/mswin.vim
silent! unmap <C-H>
set selectmode=

" *******
" Plugins
" *******

" colorschemes
Plug 'lifepillar/vim-solarized8'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'
Plug 'nightsense/vimspectr'
Plug 'rakr/vim-one'
" enable this on 88/256-color terminals
" Plug 'godlygeek/CSApprox'

" Language support
Plug 'lepture/vim-jinja'
Plug 'groenewege/vim-less'
Plug 'derekwyatt/vim-scala'
Plug 'nathanalderson/yang.vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'mattn/emmet-vim'
Plug 'Quramy/tsuquyomi' " typescript fanciness
Plug 'Quramy/vim-js-pretty-template'
Plug 'leafgarland/typescript-vim'
Plug 'evedovelli/rst-robotframework-syntax-vim'
Plug 'mfukar/robotframework-vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'udalov/kotlin-vim'
Plug 'cespare/vim-toml'

" version control
Plug 'nfvs/vim-perforce'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" text objects
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-lastpat'
Plug 'kana/vim-textobj-django-template'
Plug 'lucapette/vim-textobj-underscore'
Plug 'kana/vim-textobj-user'
Plug 'reedes/vim-textobj-sentence'

" other
Plug 'psf/black', { 'on': 'Black' }
Plug 'tpope/vim-sensible'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-commentary'
Plug 'mileszs/ack.vim'
Plug 'rking/ag.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'scrooloose/syntastic'
Plug 'tfnico/vim-gradle'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'vim-scripts/fontzoom.vim'
Plug 'regedarek/ZoomWin'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-dispatch'
Plug 'christoomey/vim-tmux-navigator'
Plug 'reedes/vim-pencil'
Plug 'junegunn/goyo.vim'
Plug 'nathanalderson/yanktohtml'

" neovim
if has('nvim')
    Plug 'Shougo/deoplete.nvim'
    Plug 'deoplete-plugins/deoplete-jedi'
    Plug 'davidhalter/jedi-vim'
else
    Plug 'ervandew/supertab'
end

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()

if has("gui_running")
    " do GUI-only stuff
    if &lines < 35
        set lines=35
        set columns=130
    endif
    set guioptions-=T  "remove toolbar
    set guioptions-=m  "remove menu
    set guioptions-=rL "remove right and left scroll bars
    set guioptions+=c  "use non-modal confirm prompts
else
    " do terminal-only stuff
    set t_ut=
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
        set guifont=Cascadia\ Code\ SemiLight\ 12,Fantasque\ Sans\ Mono\ 12,Inconsolata\ for\ PowerLine\ 12,Inconsolata\ 12
    else
        set guifont=Cascadia\ Code:h12
    endif
    let vimfilesdir = "~/.vim/backup/"
    let s:p4root = "/home/nalderso/p4workspace/"
    " silent execute '!rm "~/.vim/backup/*~"'
    set clipboard=unnamedplus
endif

" colors
set background=dark
colorscheme gruvbox
" let g:airline_theme='deus'

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
autocmd Filetype typescript call SetTabWidth(2)

" Composition mode (for editing prose)
let g:goyo_width = 120
function! Compose()
    Goyo
    PencilToggle
    nnoremap <S-h> g^
    vnoremap <S-h> g^
    nnoremap <S-l> g$
    vnoremap <S-l> g$
endfunction
command! Compose call Compose()

" Enable nice word wrapping
function! Wrap()
    set wrap
    set linebreak
    set nolist
    set textwidth=0
    set wrapmargin=0
    nnoremap <S-h> g^
    vnoremap <S-h> g^
    nnoremap <S-l> g$
    vnoremap <S-l> g$
endfunction
command! Wrap call Wrap()

" Save file as root
function! Write()
    w !sudo tee %
    edit!
endfunction
command! Write call Write()

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
set noerrorbells novisualbell t_vb=
set foldlevelstart=99
autocmd GUIEnter * set visualbell t_vb=
if &t_Co >= 256 || has("gui_running")
    set cursorline
else
    set nocursorline
endif

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" ...except for git commits
autocmd FileType gitcommit execute "normal! ggm\""

" vim-anywhere
autocmd BufNewFile,BufRead /tmp/vim-anywhere/* set syntax=markdown

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
nnoremap <S-h> ^
nnoremap <S-l> $
vnoremap <S-h> g^
vnoremap <S-l> g$
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

" window management
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <leader>- <C-w>s<C-w>j

"insert mode custom keymapping
inoremap <C-]> <C-X><C-]>
inoremap <C-F> <C-X><C-F>
inoremap <C-D> <C-X><C-D>
inoremap <C-L> <C-X><C-L>
inoremap <C-BS> <C-W>
inoremap <C-h> <C-W>

nnoremap <F5> :Dispatch<CR>
autocmd FileType java,scala,groovy let b:dispatch = 'gw build'

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
let g:syntastic_python_checkers=['pylint', 'mypy']
let g:syntastic_cpp_checkers=['cppcheck']
let g:syntastic_python_pylint_post_args = '--disable=C'
let g:syntastic_typescript_checkers = ['tsuquyomi']
let g:syntastic_enable_balloons=0
let g:syntastic_always_populate_loc_list=1
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': ['typescript'],
                           \ 'passive_filetypes': [] }

" BufKill
let g:BufKillCreateMappings=0     "skip bufkill bindings which interfere with Command-T
nmap <silent> <C-^> :BA<CR>

" ZoomWin
nnoremap <C-o> :ZoomWin<CR>

" vim-perforce
let g:perforce_auto_source_dirs=['/home/nalderso/p4workspace']

if has('nvim')
    let g:python_host_prog = "/usr/bin/python"
    let g:python3_host_prog = "/usr/bin/python3"
end

" UltiSnips
let g:UltiSnipsExpandTrigger='<c-s>'
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = expand('~/dotfiles/.vim/UltiSnips')

" deoplete & jedi
if has('nvim')
    let g:deoplete#enable_at_startup = 1
    autocmd CompleteDone * silent! pclose!
    let g:deoplete#sources#jedi#ignore_private_members = 1
    let g:jedi#completions_enabled = 0
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
end

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
nmap <C-/> gcc

" NerdTree
let NERDTreeShowHidden=1
nmap <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" CScope
set cscopetag                           " CTRL-] uses cscope and tags file
set csto=0                              " check cscope first, then tags file
set cscopequickfix=s-,c-,d-,i-,t-,e-    " use quickfix list
set cspc=0                              " show full path
nmap <leader>ss mT:cs find s <C-R>=expand("<cword>")<CR><CR>'T:cope<CR>
nmap <leader>s  :cs find s 

" black
let g:black_linelength=100

" Ag and Ack
let g:ackprg="ack --column --smart-case"
let g:ag_mapping_message=0
let g:ag_prg="ag --column --smart-case"

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

" fugitive
autocmd User fugitive if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif
autocmd BufReadPost fugitive://* set bufhidden=delete

if !has('nvim')
    " supertab
    " let g:SuperTabDefaultCompletionType = "context"
    autocmd FileType *
        \ if &omnifunc != '' |
        \   call SuperTabChain(&omnifunc, "<c-p>") |
        \ endif
end

" tsuquyomi
let g:tsuquyomi_disable_quickfix = 1
map <C-)> <Plug>(TsuquyomiReferences)

" TODO:
" - Extend surround to support /* */
" - Check out projectionist.vim

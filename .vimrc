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

silent! unmap <C-H>
set selectmode=


" *******
" Plugins
" *******

if !exists('g:vscode')
" colorschemes
Plug 'lifepillar/vim-solarized8'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'
Plug 'rakr/vim-one'
if has('nvim')
Plug 'tjdevries/colorbuddy.nvim' " required for lalitmee/cobalt2.nvim
Plug 'lalitmee/cobalt2.nvim'
Plug 'loctvl842/monokai-pro.nvim'
endif
" enable this on 88/256-color terminals
" Plug 'godlygeek/CSApprox'

" coc.nvim
if has('nvim')
let g:coc_global_extensions = [
            \'@yaegassy/coc-ansible',
            \'coc-elixir',
            \'coc-flutter',
            \'coc-json',
            \'coc-pyright',
            \'coc-snippets',
            \]
endif

" other (non-vscode)
Plug 'mileszs/ack.vim'
Plug 'rking/ag.vim'
Plug 'scrooloose/syntastic'
Plug 'regedarek/ZoomWin'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tfnico/vim-gradle'
Plug 'vim-scripts/fontzoom.vim'
if has('nvim')
Plug 'nvim-lualine/lualine.nvim'
Plug 'aserowy/tmux.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif
Plug 'tpope/vim-dispatch'
Plug 'reedes/vim-pencil'
Plug 'junegunn/goyo.vim'

" Language support
if has('nvim')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
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
Plug 'kevinoid/vim-jsonc'
Plug 'pearofducks/ansible-vim'
Plug 'elixir-editors/vim-elixir'
Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'

" version control
Plug 'airblade/vim-gitgutter'

end " !exists('g:vscode')

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
Plug 'amiralies/vim-textobj-elixir'

" other
Plug 'psf/black', { 'on': 'Black' }
Plug 'tpope/vim-sensible'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-commentary'
Plug 'qpkorr/vim-bufkill'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'nathanalderson/yanktohtml'
Plug 'lambdalisue/suda.vim' " workaround for https://github.com/neovim/neovim/issues/1716

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
    if !has('nvim')
        set guioptions+=c  "use non-modal confirm prompts
    endif
else
    " do terminal-only stuff
    set t_ut=
endif

if exists("g:neovide")
    " prevents overly bold text
    let g:neovide_text_gamma = 0.8
    let g:neovide_text_contrast = 0.1
endif

if has("win64") || has("win32") || has("win16")
    set guifont=Consolas:h11:cANSI
    let vimfilesdir = "C:/temp/vim_backup//"
    " silent execute '!del "c:\temp\vim_backup\*~"'

    let s:p4root = "C:\\p4workspace\\"

    " maximize the window
    command! MaximizeWindow simalt ~x
    set clipboard=unnamed
else
    set guifont=Fantasque\ Sans\ Mono:h10
    let vimfilesdir = "~/.vim/backup/"
    let s:p4root = "/home/nalderso/p4workspace/"
    " silent execute '!rm "~/.vim/backup/*~"'
    set clipboard=unnamedplus
endif

if !exists('g:vscode')

" colors
set background=dark
if has('nvim')
    lua require('monokai-pro').setup({
        \ filter = "pro"
      \ })
    colors monokai-pro
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
autocmd Filetype typescript call SetTabWidth(2)
autocmd Filetype yaml call SetTabWidth(2)

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
" command! Write call Write()
command! -nargs=? -complete=file Write SudaWrite

end " !exists('g:vscode')

" Trim trailing whitespace
command! Trim :%s/\v\s+$/

" Make buffer a scratch buffer
function! Scratch()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
endfunction

command! Scratch call Scratch()

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

if !exists('g:vscode')

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" ...except for git commits
autocmd FileType gitcommit execute "normal! ggm\""

" vim-anywhere
autocmd BufNewFile,BufRead /tmp/vim-anywhere/* set syntax=markdown

end " !exists('g:vscode')

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
    if has('nvim')
        execute "set undodir=".vimfilesdir."/nvimundo"
    else
        execute "set undodir=".vimfilesdir
    end
    set undofile
endif

" searching
if !exists('g:vscode')
    nnoremap / /\v
    vnoremap / /\v
    cnoremap s/ s/\v
end
nnoremap <leader><space> :noh<cr>
set ignorecase
set smartcase
set gdefault
set nohlsearch

" random custom mappings
inoremap jk <ESC>
nmap j gj
nmap k gk
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

" Ctrl[-Shift]-v paste
inoremap <C-v> <C-r>+
inoremap <C-S-v> <C-r>+
cnoremap <C-v> <C-r>+
cnoremap <C-S-v> <C-r>+
vnoremap <C-v> "+p
vnoremap <C-S-v> "+p
nnoremap <C-v> "+p
nnoremap <C-S-v> "+p

if !exists('g:vscode')

" neovim terminal
if has('nvim')
    nnoremap <C-t> :terminal zsh<CR>
    tnoremap jk <C-\><C-n>
    tnoremap <ESC> <C-\><C-n>
    tnoremap <C-h> <Cmd>wincmd h<CR>
    tnoremap <C-j> <Cmd>wincmd j<CR>
    tnoremap <C-k> <Cmd>wincmd k<CR>
    tnoremap <C-l> <Cmd>wincmd l<CR>
    augroup nvim_terminal | au!
        autocmd TermEnter term://* startinsert
        autocmd BufEnter term://* startinsert
    augroup end
endif

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

end " !exists('g:vscode')

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

" SplitJoin
autocmd FileType elixir let b:splitjoin_split_callbacks += [
    \ 'sj#js#SplitObjectLiteral',
    \ 'sj#html#SplitTags',
    \ 'sj#html#SplitAttributes'
    \ ]
autocmd FileType elixir let b:splitjoin_join_callbacks += [
    \ 'sj#js#JoinObjectLiteral',
    \ 'sj#html#JoinAttributes',
    \ 'sj#html#JoinTags'
    \ ]
autocmd FileType heex let b:splitjoin_split_callbacks = [
    \ 'sj#elixir#SplitDoBlock',
    \ 'sj#elixir#SplitArray',
    \ 'sj#elixir#SplitPipe',
    \ 'sj#js#SplitObjectLiteral',
    \ 'sj#html#SplitTags',
    \ 'sj#html#SplitAttributes'
    \ ]
autocmd FileType heex let b:splitjoin_join_callbacks = [
    \ 'sj#elixir#JoinDoBlock',
    \ 'sj#elixir#JoinArray',
    \ 'sj#elixir#JoinCommaDelimitedItems',
    \ 'sj#elixir#JoinPipe',
    \ 'sj#js#JoinObjectLiteral',
    \ 'sj#html#JoinAttributes',
    \ 'sj#html#JoinTags'
    \ ]
autocmd FileType kotlin let b:splitjoin_split_callbacks = [
    \ 'sj#java#SplitIfClauseBody',
    \ 'sj#java#SplitIfClauseCondition',
    \ 'sj#java#SplitLambda',
    \ 'sj#java#SplitFuncall',
    \ 'sj#js#SplitObjectLiteral'
    \ ]
autocmd FileType kotlin let b:splitjoin_join_callbacks = [
    \ 'sj#java#JoinLambda',
    \ 'sj#java#JoinIfClauseCondition',
    \ 'sj#java#JoinFuncall',
    \ 'sj#java#JoinIfClauseBody',
    \ 'sj#js#JoinObjectLiteral'
    \ ]

if !exists('g:vscode')

" COC
" Use <C-j>/<C-k> to trigger completion with characters ahead and navigate
inoremap <silent><expr> <C-j>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<C-j>" :
      \ coc#refresh()
inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

end " !exists('g:vscode')

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
autocmd FileType json set commentstring=//\ %s  " jsonc is a thing
nmap <C-/> gcc

" NerdTree
let NERDTreeShowHidden=1
nmap <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" black
let g:black_linelength=100

" Ag and Ack
let g:ackprg="ack --column --smart-case"
let g:ag_mapping_message=0
let g:ag_prg="ag --column --smart-case"

" surround
let g:surround_37 = "<% \r %>"
let g:surround_61 = "<%= \r %>"

if !exists('g:vscode')

if has('nvim')
" tmux.nvim
lua require("tmux").setup({
        \ navigation = {
        \ enable_default_keybindings = true,
        \ cycle_navigation = false,
    \ },
\ })
endif

if has('nvim')
" lualine
lua require('lualine').setup {
    \ options = {
        \ section_separators = '',
        \ component_separators = '',
        \ theme = 'monokai-pro',
    \ },
\ }
endif

" fugitive
autocmd User fugitive if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif
autocmd BufReadPost fugitive://* set bufhidden=delete

" tsuquyomi
let g:tsuquyomi_disable_quickfix = 1
map <C-)> <Plug>(TsuquyomiReferences)

" TODO:
" - Extend surround to support /* */
" - Check out projectionist.vim

end " !exists('g:vscode')

if exists('g:vscode')
    " go to next/previous change
    nnoremap [c <Cmd>call VSCodeNotify("workbench.action.editor.previousChange")<CR>
    nnoremap ]c <Cmd>call VSCodeNotify("workbench.action.editor.nextChange")<CR>
end

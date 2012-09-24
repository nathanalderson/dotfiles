set vimdir="C:\Program Files - Portable\Vim"

REM delete backup files
del %vimdir%\_vimrc.bkup
del %vimdir%\vimfiles\autoload\pathogen.vim.bkup

REM backup existing files
move %vimdir%\_vimrc %vimdir%\_vimrc.bkup
move %vimdir%\vimfiles\autoload\pathogen.vim %vimdir%\vimfiles\autoload\pathogen.vim.bkup

REM hard-link to new files
MKLINK /H %vimdir%\_vimrc .vimrc
MKLINK /H %vimdir%\vimfiles\autoload\pathogen.vim .vim\autoload\pathogen.vim

@echo off
set vimdir="C:\Program Files - Portable\Vim"

REM delete backup files
del %vimdir%\_vimrc.bkup

REM backup existing files
move %vimdir%\_vimrc %vimdir%\_vimrc.bkup

REM hard-link to new files
MKLINK /H %vimdir%\_vimrc .vimrc

REM install Vundle
mkdir -p %vimdir%\vimfiles\bundle\vundle
git clone https://github.com/gmarik/vundle.git %vimdir%\vimfiles\bundle\vundle
vim +BundleInstall +qall

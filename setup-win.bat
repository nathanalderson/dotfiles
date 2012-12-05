@echo off
set vimdir="C:\Program Files - Portable\Vim"

REM install Vundle
mkdir -p %vimdir%\vimfiles\bundle\vundle
git clone https://github.com/gmarik/vundle.git %vimdir%\vimfiles\bundle\vundle
vim +BundleInstall +qall

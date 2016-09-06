#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=".vimrc .bashrc .zshrc .oh-my-zsh/custom .tmux.conf .gitconfig .gitignore_global .vim/spell/en.utf-8.add .i3 .i3status.conf"    # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~..."
mkdir -p $olddir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
echo "Backing up and linking files..."
for file in $files; do
    mv ~/$file $olddir
    ln -s $dir/$file ~/$file
done

# install Vundle
echo "Installing Vundle..."
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +BundleInstall +qall

# create vim backup directory
mkdir ~/.vim/backup

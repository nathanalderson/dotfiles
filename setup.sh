#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=".vimrc .zshrc .oh-my-zsh/custom .tmux.conf .pam_environment"    # list of files/folders to symlink in homedir

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
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
vim +BundleInstall +qall

# create vim backup directory
mkdir ~/.vim/backup

# make command-t
# note, probably need to install something like:
# sudo apt-get install ruby ruby-dev build-essential
echo "Building command-t"
cd ~/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
cd -

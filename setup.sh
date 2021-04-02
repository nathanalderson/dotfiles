#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
# list of files/folders to symlink in homedir
files=".vimrc .bashrc .zshrc .tmux.conf .gitconfig .gitignore_global .i3 .i3status.conf .ideavimrc"

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

# create vim backup directory
mkdir -p ~/.vim/backup

# setup idea
find ~ -maxdepth 1 -type d -name ".IdeaIC*" | xargs -I{} ln -sf .idea/idea.properties {}/config/idea.properties

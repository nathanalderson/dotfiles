apt-get update
apt-get -y install vim-gnome git zsh keepass2 xdotool ruby ruby-dev curl openssh-server dropbox
apt-get -y install fonts-inconsolata fonts-sil-gentiumplus fonts-fantasque-sans curl g++ python-pip
apt-get -y install tmux

git clone https://github.com/nathanalderson/dotfiles.git
dotfiles/setup.sh

chsh -s /bin/zsh

echo Other things to do...
echo  "* Download and install dropbox (https://www.dropbox.com/install?os=lnx)"
echo  "* Set a global keyboard shortcut for keepass (look under Menu > Preferences > System Settings > Keyboard > ...)"
echo  "* Download and install chrome (https://www.google.com/intl/en/chrome/browser/?hl=en&brand=CHFX&utm_campaign=en&utm_source=en-oa-na-us-bk-bng&utm_medium=oa)"

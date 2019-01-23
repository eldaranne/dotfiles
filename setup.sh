#!/bin/sh

BASE_DIR=$PWD

# Essentials
echo 'Installing essentials'
sudo apt install --assume-yes build-essential tig terminator clang cmake zsh git xfonts-terminus fonts-firacode vim ssh

# i3
echo 'Installing i3 and its dependencies'
sudo apt install --assume-yes i3 rofi xiccd feh udevil kbdd compton compton-conf

# Polybar dependencies
echo ''Installing polybar dependencies
sudo apt install --assume-yes unifont ccache libcairo2-dev xcb-proto libasound2-dev libcurl4-openssl-dev libmpdclient-dev libiw-dev
sudo apt install --assume-yes libxcb1-dev libxcb-xkb-dev libxcb-randr0-dev libxcb-util-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-render0-dev libxcb-composite0-dev libxcb-sync-dev libxcb-damage0-dev libxcb-composite0-dev libxcb-xrm-dev libxcb-cursor-dev python-xcbgen

# Build polybar
echo 'Building Polybar'
if [ -d polybar ]; then
    rm -rf polybar
fi
git clone --recurse-submodules https://github.com/jaagr/polybar.git
cd polybar && mkdir build && cd build && \
cmake                            \
  -DCMAKE_C_COMPILER="clang"     \
  -DCMAKE_CXX_COMPILER="clang++" \
  -DENABLE_ALSA:BOOL="ON"        \
  -DENABLE_I3:BOOL="ON"          \
  -DENABLE_MPD:BOOL="ON"         \
  -DENABLE_NETWORK:BOOL="ON"     \
  -DENABLE_CURL:BOOL="ON"        \
  -DBUILD_IPC_MSG:BOOL="ON"      \
  -DWITH_XCOMPOSITE:BOOL="ON"    \
  -DWITH_XCURSOR:BOOL="ON"       \
  -DWITH_XDAMAGE:BOOL="ON"       \
  -DWITH_XKB:BOOL="ON"           \
  -DWITH_XRANDR:BOOL="ON"        \
  -DWITH_XRANDR_MONITORS:BOOL="ON" \
  -DWITH_XRENDER:BOOL="ON"       \
  -DWITH_XRM:BOOL="ON"           \
  -DWITH_XSYNC:BOOL="ON"         \
  .. && make && sudo make install

# Linux theme
echo 'Fetching numix theme'
sudo apt-add-repository ppa:numix/ppa
sudo apt update
sudo apt install --assume-yes gtk-chtheme lxappearance numix-icon-theme-circle

# Powerline font
echo 'Installing powerline font'
cd $BASE_DIR
wget -O powerline-fonts.zip https://github.com/powerline/fonts/archive/master.zip
unzip powerline-fonts.zip
./powerline-fonts/install.sh
rm -rf powerline-fonts
rm powerline-fonts.zip

# Siji font
echo 'Installing siji font'
if [ -d siji ]; then
    rm -rf siji
fi
git clone --recurse-submodules https://github.com/stark/siji && cd siji && ./install.sh -d ~/.fonts

# Bitmap fonts
echo 'Enable bitmap fonts'
sudo ln -s /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d/
sudo unlink /etc/fonts/conf.d/70-no-bitmaps.conf
sudo dpkg-reconfigure fontconfig

cd $BASE_DIR

# Copy all config files
cp -r .zprezto ~/
ln -s ~/.zprezto/runcoms/zlogin ~/.zlogin
ln -s ~/.zprezto/runcoms/zlogout ~/.zlogout
ln -s ~/.zprezto/runcoms/zpreztorc ~/.zpreztorc
ln -s ~/.zprezto/runcoms/zprofile ~/.zprofile
ln -s ~/.zprezto/runcoms/zshrc ~/.zshrc
ln -s ~/.zprezto/runcoms/zshenv ~/.zshenv
cp .vimrc ~/
cp .Xresources ~/
cp .fehbg ~/
cp -ra .config ~/.config

# Configure git
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.st status
git config --global alias.br branch
git config --global alias.st status
git config --global alias.unstage "reset HEAD --git"
git config --global user.name "Jérémie Soria"
git config --global user.email "jeremie@corstem.ai"
git config --global diff.tool vscode
git config --global merge.tool vscode
git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"
git config --global mergetool.vscode.cmd "code --wait \$MERGED"
git config --global core.editor "code --wait"
git config --global core.autocrlf "true"
git config --global core.safecrlf "warn"

# Use zsh by default
chsh -s $( which zsh)

# Manage ssh-agent with keychain
sudo apt install --assume-yes keychain
echo "# ssh-agent at first launch of zsh
eval \`keychain --eval --agents ssh id_rsa\`" >> ~/.zshrc


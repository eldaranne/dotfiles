#!/bin/sh

PWD=$(pwd)
cd ~

# Essentials
echo 'Installing essentials'
sudo apt install terminator clang cmake zsh git xfonts-terminus vim

# i3
echo 'Installing i3 and its dependencies'
sudo apt install i3 rofi xiccd feh udevil kbdd compton compton-conf

# Polybar dependencies
echo ''Installing polybar dependencies
sudo apt install unifont ccache libcairo2-dev xcb-proto libasound2-dev libcurl4-openssl-dev libmpdclient-dev libiw-dev
sudo apt install libxcb1-dev libxcb-xkb-dev libxcb-randr0-dev libxcb-util-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-render0-dev libxcb-composite0-dev libxcb-sync-dev libxcb-damage0-dev libxcb-composite0-dev libxcb-xrm-dev libxcb-cursor-dev python-xcbgen

# Build polybar
echo 'Building Polybar'
if [ ! -d polybar ]
git clone https://github.com/jaagr/polybar.git
fi
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
  .. && make -j$(nproc) && sudo make install && cd ../../ 
cd ~ && rm -rf polybar

# Linux theme
echo 'Fetching numix theme'
sudo apt-add-repository ppa:numix/ppa
sudo apt update
sudo apt install gtk-chtheme lxappearance numix-icon-theme-circle

# Powerline font
echo 'Installing powerline font'
cd ~
wget -O powerline-fonts.zip https://github.com/powerline/fonts/archive/master.zip
unzip powerline-fonts.zip
./powerline-fonts/install.sh
rm -rf powerline-fonts
rm powerline-fonts.zip

# Siji font
echo 'Installing siji font'
git clone https://github.com/stark/siji && cd siji && ./install.sh -d ~/.fonts && cd .. && rm -rf siji

# Bitmap fonts
echo 'Enable bitmpa fonts'
sudo ln -s /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d/
sudo unlink /etc/fonts/conf.d/70-no-bitmaps.conf
sudo dpkg-reconfigure fontconfig

# Use zsh by default
chsh -s $( which zsh)

cd $PWD

# Copy all config files
cp -a .z* ~/
cp .vimrc ~/
cp .Xresources ~/
cp .fehbg ~/
cp -ra .config ~/.config


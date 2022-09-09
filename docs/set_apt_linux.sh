#!/usr/bin/sudo bash

sudo apt install nala -y

# Essential packages
sudo nala install ssh \
vim htop git curl \
make build-essential software-properties-common mercurial binutils bison re2c \
python3-apt python3-pip python3-dev python3-setuptools \
pandoc highlight gzip tar plocate pkg-config bzip2 openssl \
libxml2-dev libevent-dev libbz2-dev libcurl4-openssl-dev libpng-dev \
libjpeg-dev libonig-dev libtidy-dev libxslt-dev libzip-dev \
autoconf libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev \
libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev libsqlite3-dev -y

# Cool stuff
sudo nala install viu neofetch hollywood cmatrix jp2a speedtest-cli -y

# Ranger utils support
sudo nala install caca-utils imagemagick ffmpeg librsvg2-bin atool unrar p7zip-full p7zip-rar -y

# Snap install
sudo snap install bashtop cpufetch gdu-disk-usage-analyzer ascii-image-converter lolcat starship -y

# system pip3 install
sudo pip3 install thefuck gdown ntfy[emoji]

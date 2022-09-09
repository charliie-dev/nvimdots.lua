#!/usr/bin/env bash

# NOTE: use sudo sh script.sh to run scripts with sudo privileges.

mkdir -p /var/swap # make swap dir

cd /var/swap # enter swap dir

dd if=/dev/zero of=/var/swap/swapfile bs=1M count=1024 # assign swap with 1024*1M

chmod 600 swapfile

mkswap swapfile # change it into swap format

swapon /var/swap/swapfile # activate swap

echo "/var/swap/swapfile swap swap defaults 0 0" >>/etc/fstab # set for auto-mount while system reboot

# Delete swap
# swapoff /swapfile
# rm -rf /swapfile

#!/usr/bin/sudo bash

mkdir -p /var/swap # 创建目录

cd /var/swap # 进入目录

dd if=/dev/zero of=/var/swap/swapfile bs=1M count=1024 # 分配个1024*1M的文件

chmod 600 swapfile # （推荐）修改权限为 0600

mkswap swapfile # 格式化为交换区格式

swapon /var/swap/swapfile # 开启交换区

echo "/var/swap/swapfile swap swap defaults 0 0" >>/etc/fstab # set for auto-mount while system reboot

# Delete swap
# swapoff /swapfile
# rm -rf /swapfile

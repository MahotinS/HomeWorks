#!/bin/bash
sudo -i
#**** включаем сервер NFS ****
systemctl enable firewalld --now
systemctl status firewalld

#**** создаем директорию ****
mkdir -p /mnt/nfs_share

#**** вносим информацию в /etc/fstab по экспортируемой директории с сервера ****
echo "192.168.56.10:/var/nfs_share/ /mnt/nfs_share nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0">> /etc/fstab

#*** рестарт служб ****
systemctl daemon-reload
systemctl restart remote-fs.target

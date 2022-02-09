#!/bin/bash
sudo -i

#**** включаем сервер NFS ****
systemctl enable firewalld --now
systemctl status firewalld
firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
firewall-cmd --reload

#**** проверяем наличие слушаемых портов ****
ss -tnplu

#***** создаем деректорбю upload ****
mkdir -p /var/nfs_share/upload

#**** изменяем владельца ****
chown -R nfsnobody:nfsnobody /var/nfs_share

#**** иназначаем права ****
chmod 0777 /var/nfs_share/upload

#**** вносим информацию в /etc/exports по экспортируемой директории и клиенту ****
echo "/var/nfs_share/ 192.168.56.11/24(rw,sync,root_squash)">> /etc/exports

#**** расшариваем директорию ****
exportfs -r
# **** проверяем расшаривание ****
exportfs -s
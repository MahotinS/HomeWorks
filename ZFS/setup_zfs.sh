#!/bin/bash
sudo -i
echo '**************  install zfs repo  **************'
    yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
echo '**************  import gpg key  **************'
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
echo '**************  install DKMS style packages for correct work ZFS  **************'
    yum install -y epel-release kernel-devel zfs
echo '**************  change ZFS repo  **************'
    yum-config-manager --disable zfs
    yum-config-manager --enable zfs-kmod
    yum install -y zfs
echo '**************  Add kernel module zfs  **************'
    modprobe zfs
echo '**************  install wget  **************'
    yum install -y wget

echo '**************  yum install -y yum-utils  **************'
    yum install -y yum-utils

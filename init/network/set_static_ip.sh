#!/bin/bash
#配置虚拟机的静态ip
#如果没有网络。请检查$gw和网络中的网关地址是否一致
dir=/etc/sysconfig/network-scripts/
tmp1=`ifconfig |grep flags`
ens=`echo $tmp1 |awk -F":" '{print $1}'`
echo $dir"ifcfg-"$ens
cat > $dir"ifcfg-"$ens << EOF
NAME=$ens
DEVICE=$ens
BOOTPROTO=dhcp
ONBOOT=yes
EOF


systemctl restart network
tmp2=`ifconfig $ens | grep netmask`
ip=`echo $tmp2 |awk '{print $2}' `
gw=`echo $ip | awk -F"." '{print $1"."$2"."$3}'`".1"
nm=`echo $tmp2 |awk  '{print $4}'`
#echo $tmp2
#echo $gw
#echo $nm
cat > $dir"ifcfg-"$ens << EOF
NAME=$ens
DEVICE=$ens
BOOTPROTO=static
ONBOOT=yes
IPADDR=$ip
GATEWAY=$gw
NETMASK=$nm
DNS1=$gw
DNS2=8.8.8.8
EOF
systemctl restart network
ifconfig

#!/bin/bash
#设置时区
timedatectl set-timezone Asia/Shanghai
#同步时间
#推荐使用ntpd，因为ntpd是渐进式的矫正时间，ntpdate是断崖式的矫正时间
if  echo 'rpm -qa |egrep ^ntp*.|wc -l' -eq 0;then
        yum install -y ntp
        systemctl start ntpd
fi
#if ! crontab -l|grep ntpdate &>/dev/null ;then
#        (echo "59 * * * * ntpdate ntp1.aliyun.com >/dev/null 2>&1";crontab -l) |crontab
#fi


#禁用selinux
setenforce 0 
sed  -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config

#清空防火墙,停用firwalld，安装iptables
systemctl stop firewalld
systemctl disable firewalld
yum install -y iptables\*
systemctl start iptables
systemctl enable iptables
iptables -F
iptables-save > /etc/sysconfig/iptables

#history显示时间和用户名
#对当前窗口暂时有效
#sed -i '$a export HISTTIMEFORMAT="%F %T `whoami` "' /etc/bashrc
#source /etc/bashrc

#禁止root远程登录
# !请注意一定要有能sudo的用户再禁止root用户远程登录
#sed -i 's/#PermitRootLogin yes/PermitRootLogin on/' /etc/ssh/sshd_config

#禁止定时任务发送邮件
#sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab

#设置最大文件打开数
if ! grep "*       soft    nofile  65535" /etc/security/limits.conf &>/dev/null; then
cat >> /etc/security/limits.conf <<EOF
*       soft    nofile  65535
*       hard    nofile  65535
EOF

fi

#系统内核优化
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_syn_backlog = 20480
net.ipv4.tcp_fin_timeout = 20
EOF

#减少swap的使用
echo "0" > /proc/sys/vm/swappiness

#配置阿里yum源
yum install -y wget
budir=/etc/yum.repos.d/backup`date "+%Y%m%d"`
mkdir $budir
mv /etc/yum.repos.d/Cen*repo $budir
wget -P /etc/yum.repos.d/  http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache


#安装系统性能分析工具以及其他
#yum install gcc make autoconf vim sysstat net-tool iostat iftop iotp lrzsz lsof wget curl -y
yum install -y vim net-tool wget curl 
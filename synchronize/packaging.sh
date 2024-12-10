#!/bin/bash
# 全网服务器备份解决方案_rsync客户端打包脚本
# author:Mr.chen
# 2017-3-7

Path=/backup
backup_Server=192.168.0.16
local_IP=`/sbin/ifconfig ens33|awk -F"[ :]+" 'NR==2{print $3}'`
Dir=${local_IP}_$(date +%F_%w)


mkdir -p $Path/$Dir
[ -f /var/spool/cron/root ] && cp -rp /var/spool/cron/root $Path/$Dir/
[ -f /etc/rc.d/rc.local ] && cp -rp /etc/rc.d/rc.local $Path/$Dir/
[ -d /server/scripts ] && cp -rp /server/scripts $Path/$Dir/
[ -d /var/html/www ] && cp -rp /var/html/www $Path/$Dir/
[ -d /var/logs ] && cp -rp /var/logs $Path/$Dir/
[ -f /etc/sysconfig/iptables ] && cp -rp /etc/sysconfig/iptables $Path/$Dir/
cd $Path

tar -zcf $Path/${Dir}.tar.gz $Dir

rm -rf $Path/$Dir
# 创建md5sum验证信息
/usr/bin/md5sum $Path/${Dir}.tar.gz > $Path/md5sum_$(local_IP).txt

# 推送打包的文件到备份服务器
rsync -az $Path/ rsync_backup@${backup_Server}::backup --password-file=/etc/rsync.password
# 找出超过7天的备份并删除
find $Path/ -name "${local_IP}*" -type f -mtime +7 | xargs rm -rf

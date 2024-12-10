#!/bin/bash
# 全网服务器备份解决方案_rsync服务器端检查脚本
# author:Mr.chen
# 2017-3-8

#. /etc/init.d/functions
Path=/backup
fileName="md5sum.txt"
# 一共有几台客户端在推送数据
rsync_ClientNum=1

#/etc/init.d/postfix status &>/dev/null || /etc/init.d/postfix start


if [ `find $Path/ -type f -name "md5sum*" | wc -l` -eq $rsync_ClientNum ];then
	for filepath in `find $Path/ -type f -name "md5sum*"`
	do
		/usr/bin/md5sum -c $filepath
		if [ $? -eq 0 ];then
			action "${filepath}备份正常！" /bin/true
			rm -rf $filepath
		else
			action "${filepath}备份异常！" /bin/false
			echo "${filepath}备份异常！" | mail -s "$(date +%F)备份检查告警" xxxxxxxx@qq.com
		fi
	done
else
	echo “Rsync客户端推送不完整！”
#	echo "Rsync推送不完整" | mail -s "$(date +%F)备份推送告警" xxxxxxxxx@qq.com
fi

# 找出超过180天的不是周1的备份文件并删除
find $Path/ ! -name "*_2.tar.gz" -mtime +180 -type f | xargs rm -rf

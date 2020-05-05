#!/bin/bash
# 普通date格式会跟随系统字符集，可能会出现英文，所以用date -R
#删除iptables规则：iptables -D INPUT -s $IP -j DROP
DATE=$(date -R|awk -F'[ :]+' 'NR==1{print $2"/"$3"/"$4":"$5":"$6}')
SED_NUM=100
LOG_FILE=/usr/local/nginx/logs/access.log
ABNORMAL_IP=$(tail -n5000 $LOG_FILE |grep $DATE|awk -v sed_num=$SED_NUM '{a[$1]++}END{for(i in a)if(a[i]>sed_num)print i}')
for IP in $ABNORMAL_IP;do
  if [ $(iptables -vnL|grep -c "$IP") -eq 0  ];then
    iptables -I INPUT -s $IP -j DROP
    echo "$DATE $IP" >>/tmp/drop_ip.log
  fi
done

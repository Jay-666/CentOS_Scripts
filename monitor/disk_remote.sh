#!/bin/bash
#批量检测服务器磁盘使用情况
#host.info为同级目录下的文件，需手动记录其他服务器的ip、登录名、sshd端口
#使用ssh密钥登录，默认之前登录过
HOST_INFO=host.info
for IP in $(awk '/^[^#]/{print $1}' $HOST_INFO);do
  USER=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
  PORT=$(awk -v ip=$IP 'ip==$1{print $3}' $HOST_INFO)
  TMP_FILE=/tmp/disk.tmp
  ssh -p $PORT $USER@$IP 'df -h' > $TMP_FILE
  if [ `echo $?` != 0 ] ;then
    echo $IP "连接失败！"
    continue
  fi
  USE_RATE_LIST=$(awk '/^\/dev/{print $6"="int($5)}' $TMP_FILE)
  for USE_RATE in $USE_RATE_LIST;do
    MOUNTED=${USE_RATE%=*}
    USE=${USE_RATE#*=}
    if [ $USE -ge 80 ]; then
      echo "Warning:$IP 的$MOUNTED挂载点使用率为$USE!"
    fi
  done
done

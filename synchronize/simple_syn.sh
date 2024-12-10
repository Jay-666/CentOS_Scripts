#!/bin/bash
#本地单向同步
MON_DIR=/opt
#使用inotifywait命令监控/opt目录，当有文件创建时，执行后面的命令
inotifywait -mqr --format %f -e create $MON_DIR |\
#读取inotifywait命令的输出，即创建的文件名
while read files;do
  #使用rsync命令将/opt目录同步到/tmp/opt目录
  rsync -avz /opt /tmp/opt
done


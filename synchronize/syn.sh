#!/bin/bash
#本地单向同步

MON_DIR=/data
BACKUP_SERVER=192.168.0.16

inotifywait -mqr -e create,move,delete,attrib,modify $MON_DIR |\
while read event;do
  rsync -a --delete $MON_DIR $BACKUP_SERVER:/backup/
  #echo "`date +%F\ %T` 出现事件$event" >> /var/log/rsync.log 2>&1
done


#!/bin/bash
#本地单向同步
MON_DIR=/opt
inotifywait -mqr -e create,move,delete,attrib,modify $MON_DIR |\
while read event;do
  rsync -a --delete /opt 192.168.0.15:/backup/192.168.0.13
  echo "`date +%F\ %T` 出现事件$event" >> /var/log/rsync.log 2>&1
done


#!/bin/bash
#kill -USR1 pid  --重新开启一个新的日志文件
LOG_DIR=/usr/local/nginx/logs
YESTERDAY=$(date -d "yesterday" +%F)
LOG_MONTH_DIR=$LOG_DIR/$(date +%Y-%m)
LOG_FILE_LIST="access.log"

for LOG_FILE in $LOG_FILE_LIST;do
  [ ! -d $LOG_MONTH_DIR ] && mkdir -p $LOG_MONTH_DIR
  mv $LOG_DIR/$LOG_FILE $LOG_MONTH_DIR/${LOG_FILE}_${YESTERDAY}
done

kill -USR1 $(cat /usr/local/nginx/logs/nginx.pid)

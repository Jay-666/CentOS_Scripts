#!/bin/bash
MON_DIR=/opt
inotifywait -mqr --format %f -e create $MON_DIR |\
while read files;do
  echo "$(date +'%F %T') $files" >> file_mon.log
  #echo "$(date +'%F %T') $files" |mail -s "dir monitor" xxx@163.com
done

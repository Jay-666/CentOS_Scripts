#!/bin/bash
#本地单向同步
MON_DIR=/opt
inotifywait -mqr --format %f -e create $MON_DIR |\
while read files;do
  rsync -avz /opt /tmp/opt
done


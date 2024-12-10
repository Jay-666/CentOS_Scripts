#!/bin/bash
##@Author: jay-666
##@Date: 2022-09-01 16:41:22
##@Last Modified by:   jay-666
##@Last Modified time: 2023-03-23 10:20:00
##@@Description:使用mysqldump备份数据库，逻辑过于简单，弃用
DATE=$(date +%F_%H-%M-%S)
HOST=localhost
USER=root
PASSWD=123
BACKUP_DIR=/data/db_backup
DB_LIST=$(mysql -h$HOST -u$USER -p$PASSWD -s -e "show databases;" 2>/dev/null |egrep -v "Database|information_schema|mysql|performance_schema|sys" )

for DB in $DB_LIST;do
  BACKUP_NAME=${BACKUP_DIR}/${DB}_${DATE}.sql
  if ! mysqldump -h$HOST -u$USER -p$PASSWD -B $DB >$BACKUP_NAME>/dev/null;then
    echo $BACKUP_NAME "备份失败！"
  fi

done

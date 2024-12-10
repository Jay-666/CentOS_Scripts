#!/bin/bash
##@Author: jay-666
##@Date:   2020-11-25 10:39:16
##@Last Modified by:   jay-666
##@Last Modified time: 2020-11-25 10:39:16
##Description: 备份mysql数据库,针对表进行备份
DATE=$(date +%F_%H-%M-%S)
HOST=localhost
USER=root
PASSWD=123
BACKUP_DIR=/data/db_backup
DB_LIST=$(mysql -h$HOST -u$USER -p$PASSWD -s -e "show databases;" 2>/dev/null |egrep -v "Database|information_schema|mysql|performance_schema|sys" )

for DB in $DB_LIST;do
  BACKUP_DB_DIR=${BACKUP_DIR}/${DATE}/${DB}
  [ ! -d ${BACKUP_DB_DIR} ] && mkdir -p ${BACKUP_DB_DIR}
  TABLES_LIST=$(mysql -h$HOST -u$USER -p$PASSWD -s -e "use $DB;show tables;" 2>/dev/null )
  for TABLE in $TABLES_LIST; do
    BACKUP_NAME=$BACKUP_DB_DIR/${TABLE}.sql
    if ! mysqldump -h$HOST -u$USER -p$PASSWD $DB $TABLE > $BACKUP_NAME 2>/dev/null;then
      echo "$BACKUP_NAME 备份失败!"
    fi 
  done

done


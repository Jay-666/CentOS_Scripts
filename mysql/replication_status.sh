#!/bin/bash
##Author: jay-666
##Date: 2024-12-10
##Description:检测主从同步工作是否正常
##Description:在从服务器执行，把脚本写入时间任务，并发邮件警报
HOST=localhost
USER=root
PASSWD=123
IO_SQL_STATUS=$(mysql -h$HOST -u$USER -p$PASSWD -e 'show slave status\G' 2>dev/null |awk '/Slavw_.*_Running:/print{$1$2}')
for i in $IO_SQL_STATUS;do
  STATUS_NAME=${i%:*}
  STATUS=${i#*:}
  if [ "$STATUS" != "Yes" ];then
    echo "Error: MySQL Master-Slave $STATUS_NAME status is $STATUS"
  fi
done

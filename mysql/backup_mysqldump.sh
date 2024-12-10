#!/bin/sh
##@Author: jay-666
##@Date:   2020-11-25 10:39:16
##@Last Modified by:   jay-666
##@Last Modified time: 2020-11-25 10:39:16
##Description: 备份mysql数据库,忽略某些表（已删除）,自定义备份数据库名，压缩，清理

# 定义数据库用户名和密码
DB_USER=backupuser
DB_PASS=backuppassword
# 定义MySQL二进制文件目录
BIN_DIR="/usr/local/mysql/bin"
# 定义备份文件存放目录
BCK_DIR="/home/mysql/backup"
# 获取当前日期
DATE=`date '+%d.%m.%y'`
# 定义要备份的数据库名称
#DB_NAME="indiglib"
# 定义要备份的数据库名称数组
databases=(datebase_name1 database_name2)
# 定义保留天数
keepdays=10

# 定义要忽略的表
#ignoretb="--ignore-table=${DB_NAME}.tables111 --ignore-table=${DB_NAME}.tables222 “


# 如果备份目录不存在，则创建
if [ ! -d ${BCK_DIR} ]
    then
        echo -e "\e[1;31 the directory ${BCK_DIR} don't exist! creating it... \e[0m"
        mkdir -p ${BCK_DIR}
fi

# 删除超过保留天数的文件
find $BCK_DIR  -type f  -regextype posix-extended -regex  ".*\.(sql|log|out|gz|tar|zip|txt|marc|iso|ISO|xls|xlsx)"  -mtime +${keepdays} -exec rm {} \; >/dev/null 2>&1 &

# 同步文件系统
sync;sync;

# 遍历要备份的数据库名称数组
for db in ${databases[*]}
    do
        # 执行mysqldump命令备份数据库，并将结果压缩
        $BIN_DIR/mysqldump  --single-transaction -u$DB_USER -p$DB_PASS --opt --flush-logs --no-create-db --skip-add-drop-table --set-gtid-purged=OFF --hex-blob  --master-data --databases $db|gzip >$BCK_DIR/${db}_${DATE}.sql.gz&
    done

# 退出脚本
exit 0

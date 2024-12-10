#!/bin/bash
##@Author: jay-666
##@Date:   2024-12-10 10:20:00
##@Last Modified by:   jay-666
##@Last Modified time: 2024-12-10
##@Description: MySQL 数据库备份脚本，使用 mydumper 工具进行全量备份和增量备份，使用方法: $0 {full|incr}
## 全量备份：每天凌晨2点执行一次
## 0 2 * * * root /etc/cron.backup/backup_mydump.sh full >> /etc/cron.backup/backup.log 2>&1
## 增量备份：每2小时执行一次（从凌晨开始）
## 0 */2 * * * root /etc/cron.backup/backup_mydump.sh incr >> /etc/cron.backup/backup.log 2>&1


# 备份类型
BACKUP_TYPE=$1 # 全量备份|增量备份
# 配置部分
MYSQL_USER="your_mysql_user"          # MySQL 用户名
MYSQL_PASSWORD="your_mysql_password"  # MySQL 密码
MYSQL_HOST="127.0.0.1"                # MySQL 主机
MYSQL_PORT="3306"                     # MySQL 端口

BACKUP_BASE_DIR="/path/to/backup"     # 备份文件的根目录
FULL_BACKUP_DIR="$BACKUP_BASE_DIR/full"  # 全量备份目录
INCR_BACKUP_DIR="$BACKUP_BASE_DIR/incremental" # 增量备份目录

# 确保备份目录存在
mkdir -p "$FULL_BACKUP_DIR"
mkdir -p "$INCR_BACKUP_DIR"

# 获取当前时间戳
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 日志文件
LOG_FILE="$BACKUP_BASE_DIR/backup.log"

# 检查是否安装 mydumper
if ! command -v mydumper &> /dev/null; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 错误：未找到 mydumper 命令，请安装后再运行脚本。" | tee -a "$LOG_FILE"
    exit 1
fi

# 全量备份函数
backup_full() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 开始全量备份..." | tee -a "$LOG_FILE"
    mydumper \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --outputdir="$FULL_BACKUP_DIR/$TIMESTAMP" \
        --threads=4 \
        --compress \
        --verbose=3
    if [ $? -eq 0 ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 全量备份完成！" | tee -a "$LOG_FILE"
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 全量备份失败！" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# 增量备份函数
backup_incremental() {
    # 找到最近一次的备份点（全量或增量）
    LAST_BACKUP_DIR=$(ls -td "$FULL_BACKUP_DIR"/* "$INCR_BACKUP_DIR"/* 2>/dev/null | head -n 1)
    
    # 如果没有找到全量备份，执行全量备份
    if [ -z "$LAST_BACKUP_DIR" ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 未找到备份点，开始执行全量备份..." | tee -a "$LOG_FILE"
        backup_full
        LAST_BACKUP_DIR=$(ls -td "$FULL_BACKUP_DIR"/* | head -n 1)
    fi

    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 开始增量备份，基于上次备份点：$LAST_BACKUP_DIR" | tee -a "$LOG_FILE"
    mydumper \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --outputdir="$INCR_BACKUP_DIR/$TIMESTAMP" \
        --threads=4 \
        --compress \
        --incremental \
        --incremental-base-dir="$LAST_BACKUP_DIR" \
        --verbose=3
    if [ $? -eq 0 ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 增量备份完成！" | tee -a "$LOG_FILE"
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 增量备份失败！" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# 主逻辑
case $BACKUP_TYPE in
    full)
        backup_full
        ;;
    incr)
        backup_incremental
        ;;
    *)
        echo "使用方法: $0 {full|incr}"
        exit 1
        ;;
esac

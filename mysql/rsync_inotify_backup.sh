#!/bin/bash
##@Author: jay-666
##@Date:   2024-12-10 10:20:00
##@Last Modified by:   jay-666
##@Last Modified time: 2024-12-10
##@Description: 异地备份MySQL备份文件
##@Description: 必须安装有inotify-tools 和 rsync ，命令：yum install -y inotify-tools rsync
##@Description: 需要配置免密登录，命令：ssh-keygen -t rsa -P "" && ssh-copy-id -i ~/.ssh/id_rsa.pub $REMOTE_USER@$REMOTE_HOST
##@Description: 使用方法：nohup ./rsync_inotify_backup.sh &

# 配置部分
LOCAL_DIR="/home/mysql/backup"           # 本地备份目录
REMOTE_USER="your_remote_user"           # 远程服务器的用户名
REMOTE_HOST="backup_node"                # 远程服务器的主机名或IP
REMOTE_DIR="/home/mysql/remote_backup"   # 远程备份目录
LOG_FILE="/var/log/rsync_backup.log"     # 日志文件路径

# 检查是否安装 inotify-tools 和 rsync
if ! command -v inotifywait &> /dev/null || ! command -v rsync &> /dev/null; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 错误：请安装 inotify-tools 和 rsync。" | tee -a "$LOG_FILE"
    exit 1
fi

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 定义同步函数
sync_to_remote() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 开始同步到远程服务器..." | tee -a "$LOG_FILE"
    rsync -avz --delete "$LOCAL_DIR/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 同步完成。" | tee -a "$LOG_FILE"
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] 同步失败，请检查日志。" | tee -a "$LOG_FILE"
    fi
}

# 初次同步
sync_to_remote

# 使用 inotifywait 监听本地目录变化
echo "[$(date +"%Y-%m-%d %H:%M:%S")] 监听目录：$LOCAL_DIR" | tee -a "$LOG_FILE"

inotifywait -m -r -e create,modify,delete,move "$LOCAL_DIR" --format '%w%f %e' | while read file event
do
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] 检测到变化：$file ($event)" | tee -a "$LOG_FILE"
    sync_to_remote
done

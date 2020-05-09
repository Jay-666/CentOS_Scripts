#!/bin/bash
DATE=$(date +%F_%T)

WWWROOT=/usr/local/nginx/html/$1

BACKUP_DIR=/data/backup
WORK_DIR=/tmp
PROJECT_NAME=php-demo

#拉取代码
cd $WORK_DIR
if [ ! -d $PROJECT_NAME ];then
  git clone https://github.com/Jay-666/php-demo.git
  cd $PROJECT_NAME
else
  cd $PROKECT
  git pull
fi

#部署
if [ ! -d $WWWROOT ];then
  mkdir -p $WWWROOT
else
  [ ! -d $BACKUP_DIR/ninx$DATE ] && mkdir -p $BACKUP_DIR/nginx$DATE
  cp $WWWROOT/* $BACKUP_DIR/nginx$DATE
fi
rsync -avz --exclude=.git $WORK_DIR/$PROJECT_NAME/* $WWWROOT

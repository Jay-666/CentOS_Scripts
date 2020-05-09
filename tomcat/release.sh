#!/bin/bash
#需要 git wget unzip maven /data/backup
#参数1：tomcat文件夹名
DATE=$(date +%F_%T)

TOMCAT_NAME=$1
TOMCAT_DIR=/usr/local/$TOMCAT_NAME
ROOT=${TOMCAT_DIR}/webapps/ROOT
GIT_LINK=https://github.com/lizhenliang/tomcat-java-demo.git

BACKUP_DIR=/data/backup
WORK_DIR=/tmp
PROJECT_NAME=tomcat-java-demo

#拉取代码
cd $WORK_DIR
if [ ! -d $PROJECT_NAME ];then
  git clone $GIT_LINK
  cd $PROJECT_NAME
else
  cd $PROJECT_NAME
  git pull
fi

#构建
mvn clean package -Dmaven.test.skip=true
if [ $? -ne 0 ]; then
  echo "maven bauid failure!"
  exit 1
fi

#部署
TOMCAT_PID=$(ps -ef|grep "$TOMCAT_NAME"|egrep -v "grep|$$" |awk 'NR==1{print $2}' )
[ $TOMCAT_PID!="" ] && kill -9 $TOMCAT_PID
[ -d $ROOT ]&& mv $ROOT $BACKUP_DIR/${TOMCAT_NAME}_ROOT$DATE
unzip $WORK_DIR/$PROJECT_NAME/target/*.war -d $ROOT
$TOMCAT_DIR/bin/startup.sh

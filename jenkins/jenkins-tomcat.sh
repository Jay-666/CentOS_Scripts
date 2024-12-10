#!/bin/bash
#需要 root权限 git maven /data/backup

#备份文件后缀
DATE=$(date +%F_%T)
#tomcat目录名
TOMCAT_NAME=tomcat8.0
#tomcat完整路径
TOMCAT_DIR=/usr/local/$TOMCAT_NAME
#tomcat  ROOT路径
ROOT=${TOMCAT_DIR}/webapps/ROOT

#备份存放路径
BACKUP_DIR=/data/backup
#jenkins存放git拉取代码的路径
WORK_DIR=/var/lib/jenkins/workspace
#项目名
PROJECT_NAME=Java-test
#maven的家目录
MAVEN_HOME=/usr/local/maven3.6

#防止jenkins默认shell执行完后，终止其子进程
BUILD_ID=DONTKILLME

#构建
cd ${WORK_DIR}/${PROJECT_NAME}
${MAVEN_HOME}/bin/mvn clean
if [ $? -ne 0 ]; then
  echo "maven bauid failure!"
  exit 1
fi
${MAVEN_HOME}/bin/mvn package
if [ $? -ne 0 ]; then
  echo "maven bauid failure!"
  exit 1
fi


#部署
TOMCAT_PID=$(ps -ef|grep "$TOMCAT_NAME"|egrep -v "grep|$0" |awk 'NR==1{print $2}' )
#ps $TOMCAT_PID
[ $TOMCAT_PID!="" ] && kill -9 $TOMCAT_PID
#[ $TOMCAT_PID!="" ] && $TOMCAT_DIR/bin/shutdown.sh

[ -d $ROOT ]&& mv $ROOT $BACKUP_DIR/${TOMCAT_NAME}_ROOT$DATE
cp -f  $WORK_DIR/$PROJECT_NAME/target/*.war   ${ROOT}.war
$TOMCAT_DIR/bin/startup.sh


TOMCAT_NEW_PID=$(ps -ef|grep "$TOMCAT_NAME"|egrep -v "grep|$$" |awk 'NR==1{print $2}' )
echo "启动成功，tomcat pid:${TOMCAT_NEW_PID}"

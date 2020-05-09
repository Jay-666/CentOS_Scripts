#!/bin/bash
#需要 git wget unzip maven /data/backup
DATE=$(date +%F_%T)

TOMCAT_NAME=tomcat8.0
TOMCAT_DIR=/usr/local/$TOMCAT_NAME
ROOT=${TOMCAT_DIR}/webapps/ROOT
#GIT_LINK=https://github.com/lizhenliang/tomcat-java-demo.git

BACKUP_DIR=/data/backup
WORK_DIR=/var/lib/jenkins/workspace
PROJECT_NAME=Java-test
#防止jenkins默认shell执行完后，终止其子进程
BUILD_ID=DONTKILLME

#构建
cd ${WORK_DIR}/${PROJECT_NAME}
/usr/local/maven3.6/bin/mvn clean
if [ $? -ne 0 ]; then
  echo "maven bauid failure!"
  exit 1
fi
/usr/local/maven3.6/bin/mvn package
if [ $? -ne 0 ]; then
  echo "maven bauid failure!"
  exit 1
fi


#部署
TOMCAT_PID=$(ps -ef|grep "$TOMCAT_NAME"|egrep -v "grep|$0" |awk 'NR==1{print $2}' )
ps $TOMCAT_PID
[ $TOMCAT_PID!="" ] && kill -9 $TOMCAT_PID
#[ $TOMCAT_PID!="" ] && $TOMCAT_DIR/bin/shutdown.sh

[ -d $ROOT ]&& mv $ROOT $BACKUP_DIR/${TOMCAT_NAME}_ROOT$DATE
cp -f  $WORK_DIR/$PROJECT_NAME/target/*.war   ${ROOT}.war
$TOMCAT_DIR/bin/startup.sh


TOMCAT_NEW_PID=$(ps -ef|grep "$TOMCAT_NAME"|egrep -v "grep|$$" |awk 'NR==1{print $2}' )
echo "启动成功，tomcat pid:${TOMCAT_NEW_PID}"

#!/bin/bash
#创建多个用户并设置随机密码、账户密码保存在user.info
#参数：用户名
USER_LIST=$@
USER_FILE=./user.info
for USER in $USER_LIST; do
  if ! id $USER &>/dev/null ;then
    PASS=$(echo $RANDOM |md5sum|cut -c 1-8)
    useradd $USER
    echo $PASS |passwd --stdin $USER >/dev/null
    echo "$USER  $PASS">> $USER_FILE
    echo "$USER User create sucessful."
  else
    echo "$USER User already exists"
  fi
done

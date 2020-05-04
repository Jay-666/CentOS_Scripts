#!/bin/bash
#批量检测网站运行是否正常，URL_LIST改成想要检测的网站地址
URL_LIST="www.baidu.com www.xiaoxiao.com"
declare -i FILT_COUNT
for URL in $URL_LIST; do
  FILT_COUNT=0
  for (( i=1;i<=3;i++ ));do
    HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" $URL)
    if [ ${HTTP_CODE:0:1} -eq 2 -o  ${HTTP_CODE:0:1} -eq 3 ]; then
      echo "$URL 访问成功"
      break
    else
      let FILT_COUNT++
    fi
  done
  if [ $FILT_COUNT -eq 3 ];then
    echo "warning: $URL access failure!"
  fi

done



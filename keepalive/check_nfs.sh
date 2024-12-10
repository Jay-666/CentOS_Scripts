#!/bin/bash
#auto check nfs process
NUM=$(netstat -ltp|grep nfs |wc -l)
if [[ $NUM -eq 0 ]];then
	systemctl stop keepalived
fi

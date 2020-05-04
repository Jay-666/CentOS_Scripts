#!/bin/bash
#access.log路径
LOG=$1
echo "访问最多的10个IP"
#awk '{a[$1]++}END{print "UV:",length(a)}' $LOG
awk '{a[$1]++}END{for(v in a)print a[v],v}' $LOG| sort -rn -k1|head -10
echo "--------------"
echo "被访问最多的页面"
#echo "PV:" `wc -l LOG`
awk '{a[$11]++}END{print "PV:",length(a);for(v in a)print a[v],v}' $LOG |sort -rn -k1 |head -10
echo "--------------"
echo "访问状态码数量"
awk '{a[$9]++}END{for(v in a)print a[v],v}' $LOG |sort -rn -k1|head -10
echo "--------------"
echo "04/May/2020:00:54:09至04/May/2020:11:54:09的访问最多的IP"
awk '$4>="[04/May/2020:00:54:09" && $4<="[04/May/2020:11:54:09" {a[$1]++}END{for(v in a)print a[v],v}' $LOG |sort -rn -k1|head -10
echo "--------------" 

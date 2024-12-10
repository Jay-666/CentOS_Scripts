#!/bin/bash
echo "------------ CPU top10 ------------"
ps -eo pid,pcpu,pmem,args --sort=-pcpu |head -n 10
echo "---------- Menory top 10 ----------"
ps -eo pid,pcpu,pmem,args --sort=-pmem |head -n 10

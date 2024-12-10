# Centos7_scrips
Linux系统运维shell脚本

| 目录 | 描述        |
| ---- | ----------- |
| DOS  | 检测DOS攻击 |
|init|对Centos7系统做一些出事的优化|
|lnmp|一键部署lnmp|
|monitor|查看系统资源（CUP、内存、磁盘）使用情况|
|mysql|mysql分表备份\|分库备份\|检测主从同步是否正常\|全量增量备份\|异地备份|
|network|给虚拟机配置静态IP|
|nginx|一键发布PHP项目\|日志切割与分析|
|safety|检测入侵|
|synchronize|rsync+inotify同步|
|tomcat|一键发布Java项目|
|useradd|一键添加用户|
|web|监控网站访问是否正常|

tip：有些脚本实际需要搭配时间任务使用的



。  
├── DOS  
│   └── drop_ip.sh  
├── init  
│   └── init.sh  
├── lnmp  
│   └── lnmp.sh  
├── monitor  
│   ├── availability.sh  
│   ├── disk_remote.sh  
│   ├── host.info  
│   └── process_higt.sh  
├── mysql  
│   ├── backup_databases.sh  
│   ├── backup_tables.sh  
│   └── isSyn.sh  
├── network  
│   └── set_static_ip.sh  
├── nginx  
│   ├── acclog.sh  
│   ├── logcut.sh  
│   └── release.sh  
├── README.md  
├── safety  
│   └── mon_dir.sh  
├── synchronize  
│   └── simple_syn.sh  
├── tomcat 
│   └── release.sh  
├── useradds  
│   └── useradds.sh  
└── web  
    └── web.sh  

#!/bin/bash
#源码安装nginx
#下载源http://mirrors.sohu.com/nginx/
NGINX_V=1.14.2
PHP_V=7.4.5
MYSQL_V=5.7.23
INSTALL_DIR=/usr/local
TMP_DIR=/tmp
mPWD=$PWD
function cmd_status(){
  if [ $? -eq 0 ] ;then
    echo $1"，成功"
  else
    echo $1",失败"
    exit
  fi
}

function install_nginx(){
  cd $TMP_DIR
  yum install pcre pcre-devel.x86_64 openssl zlib zlib-devel gcc gcc-c++ openssl openssl-devel wget -y
  id nginx >/dev/null
  if [ $? -ne 0 ];then useradd nginx -s /sbin/nologin; fi
  if [ ! -e ${TMP_DIR}/nginx-${NGINX_V}.tar.gz ] ;then wget http://mirrors.sohu.com/nginx/nginx-${NGINX_V}.tar.gz; fi
  cmd_status "nginx - 下载源码包"
  tar zxf nginx-${NGINX_V}.tar.gz
  cd nginx-${NGINX_V}
  ./configure --prefix=$INSTALL_DIR/nginx \
  --with-http_stub_status_module \
  --with-http_ssl_module \
  --with-pcre
  cmd_status "nginx - 平台环境检测"
  make
  cmd_status "nginx - 编译" 
  make install
  cmd_status "nginx - 编译安装" 
  #添加对php的支持
  sed -i '65,71s/^[[:space:]]\+#//g' $INSTALL_DIR/nginx/conf/nginx.conf
  sed -i '45s/index.html/index.php index.html/g' $INSTALL_DIR/nginx/conf/nginx.conf
  echo "fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;" >> $INSTALL_DIR/nginx/conf/fastcgi_params
  #测试页面
  echo "ok" >$INSTALL_DIR/nginx/html/status.html
  echo '<?php echo "ok"?>'  >$INSTALL_DIR/nginx/html/status.php
  /usr/local/nginx/sbin/nginx
  cmd_status "nginx - 启动"
}


function install_php(){
  cd $TMP_DIR
  #安装epel源，和php相关支持包
  [ ! -e /etc/yum.repos.d/epel.repo ] && rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &&yum clean all &&yum makecache fast
  yum install -y gcc gcc-c++ libxml2-devel openssl openssl-devel libcurl-devel libjpeg-devel libpng libpng-devel freetype freetype-devel libmcrypt-devel libmcrypt wget  oniguruma oniguruma-devel sqlite-devel bzip2 bzip2-devel libxslt libxslt-devel
# yum install -y gcc gcc-c++ libxml2-devel openssl openssl-devel libcurl-devel libjpeg-devel libpng libpng-devel freetype freetype-devel libmcrypt-devel libmcrypt bzip2 bzip2-devel libxslt libxslt-devel libzip libzip-devel 
 if [ ! -e php-${PHP_V}.tar.gz ] ;then wget   https://www.php.net/distributions/php-${PHP_V}.tar.gz ; fi
  cmd_status "下载php源码包"
  if [ ! -d ${INSTALL_DIR}/php ];then
    [ ! -e  php-${PHP_V} ] && tar zxf php-${PHP_V}.tar.gz
    cd php-${PHP_V}
#    ./configure --prefix=${INSTALL_DIR}/php --enable-sockets --enable-fpm --enable-cli --enable-mbstring --enable-pcntl --enable-soap --enable-opcache --disable-fileinfo --disable-rpath --with-mysqli --with-pdo-mysql --with-iconv-dir --with-openssl --with-fpm-user=nginx--with-fpm-group=nginx--with-curl --with-mhash --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-zip --with-zlib --enable-simplexml --with-libxml-dir
   ./configure \
  --prefix=${INSTALL_DIR}/php \
  --with-config-file-path=${INSTALL_DIR}/php/etc  \
  --with-curl \
  --with-freetype-dir \
  --with-gd \
  --with-gettext \
  --with-iconv-dir \
  --with-kerberos \
  --with-libdir=lib64 \
  --with-libxml-dir \
  --with-mysqli \
  --with-openssl \
  --with-pcre-regex \
  --with-pdo-mysql \
  --with-pdo-sqlite \
  --with-pear \
  --with-png-dir \
  --with-jpeg-dir \
  --with-xmlrpc \
  --with-xsl \
  --with-zlib \
  --with-bz2 \
  --with-mhash \
  --enable-fpm \
  --enable-bcmath \
  --enable-libxml \
  --enable-inline-optimization \
  --enable-gd-native-ttf \
  --enable-mbregex \
  --enable-mbstring \
  --enable-opcache \
  --enable-pcntl \
  --enable-shmop \
  --enable-soap \
  --enable-sockets \
  --enable-sysvsem \
  --enable-sysvshm \
  --enable-xml \
  --enable-zip
   cmd_status "准备php平台环境"
    make
    cmd_status "编译"
    make install
    cmd_status "安装编译"
  fi
  #配置php
  cp ${TMP_DIR}/php-${PHP_V}/php.ini-production ${INSTALL_DIR}/php/etc/php.ini
  cat >${INSTALL_DIR}/php/etc/php-fpm.conf<<EOF
[global]
pid = /var/run/php/php-fpm.pid                
error_log = /var/log/php/php-fpm_err.log    
[www]
listen = /tmp/php-fpm.sock                 
listen.allowed_clients = 127.0.0.1
listen = 127.0.0.1:9000
listen.mode = 666
user = nginx                    
group = nginx                  
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024
EOF
  mkdir /var/log/php /var/run/php -p
  id nginx >/dev/null
  if [ $? -ne 0 ];then useradd nginx -s /sbin/nologin; fi  
  chown -R nginx.nginx /var/log/php /var/run/php
  cp ${TMP_DIR}/php-${PHP_V}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
  sed -i "18s|php_fpm_PID.*|php_fpm_PID=\/var\/run\/php\/php-fpm.pid|" /etc/init.d/php-fpm
  chmod 755 /etc/init.d/php-fpm
  #测试
  /usr/local/php/sbin/php-fpm -t
  cmd_status "测试"
  /etc/init.d/php-fpm start
  cmd_status "php启动成功"
  
}

#为编译mysql添加临时swap分区
function swap_tmp(){
  case $1 in
   add)
     dd if=/dev/zero of=/swapfile bs=1M count=2048
     mkswap /swapfile
     swapon /swapfile;;
   rm)
     swapoff /swapfile
     rm /swapfile
   esac
}


function install_mysql(){
  yum install gcc gcc-c++ ncurses-devel perl autoconf wget cmake -y
  cd $TMP_DIR
  [ ! -e ${TMP_DIR}/mysql-boost-${MYSQL_V}.tar.gz ]  && wget http://mirrors.sohu.com/mysql/MySQL-${MYSQL_V:0:3}/mysql-boost-${MYSQL_V}.tar.gz
  tar zxf mysql-boost-${MYSQL_V}.tar.gz 
  [ ! `id mysql>/dev/null` ] && useradd -s/sbin/nologin mysql
  mkdir -p /data/mysql/data
  chown -R mysql:mysql /data/mysql
  cd $TMP_DIR/mysql-${MYSQL_V}
  swap_tmp "add"
  cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_BOOST=boost
  cmd_status "编译前平台准备"
  make
  cmd_ststus "编译"
  make install
  cmd_status "安装编译"
  swap_tmp "rm"
  cat >${INSTALL_DIR}/mysql/etc/my.cnf<<EOF
[mysqld]
user=mysql
port=3306
basedir = /usr/local/mysql
datadir=/data/mysql/data
socket=/tmp/mysql.sock
log-error=/data/mysql/mysql-error.log
pid-file=/data/mysql/mysql.pid
tmpdir=/tmp

[mysqld_safe]
log-error=/data/mysql/mysql-error.log
pid-file=/data/mysql/mysql.pid

[client]
socket=/tmp/mysql.sock

EOF
  chown -R mysql:mysql ${INSTALL_DIR}mysql
  ${INSTALL_DIR}/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql/data --pid-file=/data/mysql/mysql.pid --tmpdir=/tmp
  cmd_status "mysql初始化"
  cp ${INSTALL_DIR}/mysql/support-files/mysql.server /etc/init.d/mysql
  sed -i "s|^basedir=.*|basedir=${INSTALL_DIR}\/mysql|" /etc/init.d/mysql
  sed -i "s|^datadir=.*|datadir=/data/mysql/data|" /etc/init.d/mysql 
  sed -i "s|conf=.*|conf=${INSTALL_DIR}/mysql/etc/my.cnf  " /etc/init.d/mysql
  /etc/init.d/mysql start
  cmd_status "mysql服务器启动"
  echo "export PATH=$PATH:${INSTALL_DIR}/mysql/bin" >>/etc/profile
  source /etc/profile


}



function main(){
  echo -e "1. install nginx"
  echo -e "2. install php"
  echo -e "3. install mysql"
  echo -e "4. install nginx+php"
  read -p "请选择你需要的操作,或按q退出：" index
   
  case $index in
    1) install_nginx;;
    2) install_php;;
    3) install_mysql;;
    4) install_nginx
       install_php;;
    q) exit
  esac
}


main

#!/bin/bash
# instal mysql and download main or slave match room
# dateTime:2018/04/11
# do not support change install path;install defualt path is :/usr/local/mysql 
# if change datadir, you can use args $3

downmysql(){
	if [ $1=="main"  ];then
		wget -P /tmp ftp://10.10.10.28/pub/zabbix/mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz
		wget -P /etc ftp://10.10.10.28/pub/zabbix/my.cnf
	else
		wget -P /tmp http://10.10.16.31/pub/zabbix/mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz
		wget -P /etc http://10.10.16.31/pub/zabbix/my.cnf
	fi

	tar -zxf /tmp/mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz -P /usr/local/
	cd /usr/local && ln -s /usr/local/mysql-5.7.16-linux-glibc2.5-x86_64 mysql
	cd /usr/local/mysql && chown mysql:mysql ./ -R
}

adduser(){
	/usr/bin/id mysql
	[ $? ] && echo `/usr/bin/id mysql` || `useradd -u 3000 mysql`
	[ $? ] || 
}


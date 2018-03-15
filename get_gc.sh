#!/bin/bash
#ReadMe：Tomcat用户jvm相关数据获取，并提供给zabbix使用
#For zabbix:
#修改UnsafeUserParameters 值为1，保证可以使用其他符号
#添加:
#UserParameter=java.oc,cat /tmp/java_gc|cut -d" " -f 1
#UserParameter=java.ou,cat /tmp/java_gc|cut -d" " -f 2
#UserParameter=java.pmc,cat /tmp/java_gc|cut -d" " -f 3
#UserParameter=java.pmu,cat /tmp/java_gc|cut -d" " -f 4
#UserParameter=java.fgc,cat /tmp/java_gc|cut -d" " -f 5
#UserParameter=java.fgct,cat /tmp/java_gc|cut -d" " -f 6
#

check_crontab(){
	#导出定时
	/usr/bin/crontab -l >/tmp/crontab.tmp_old
	#取消自我定时
	sed -e '/get_gc.sh/d' /tmp/crontab.tmp_old >/tmp/crontab.tmp
	if [ "$1" == "0" ];then
		echo "* * * * * /var/tmp/scripts/get_gc.sh" >> /tmp/crontab.tmp_old
	else
		echo "*/$1 * * * * /var/tmp/scripts/get_gc.sh" >> /tmp/crontab.tmp_old
	fi	
	test -f /tmp/crontab.tmp_old && /usr/bin/crontab /tmp/crontab.tmp_old || echo /usr/bin/crontab /tmp/crontab.tmp
}

f_main(){
	[ -z $1 ] || check_crontab  $1
	java_pid=`ps -ef | grep "org.apache.catalina.startup.Bootstrap" |grep -v "grep"| awk '{print $2}'`

	oc=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $7}'`
	ou=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $8}'`
	pmc=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $9}'`
	pmu=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $10}'`
	fgc=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $13}'`
	fgct=`/usr/local/java/bin/jstat -gc ${java_pid}| awk 'NR==2{print $14}'`

	java_oc=`echo "scale=0;${oc}/1024"| bc`
	java_ou=`echo "scale=1;${ou}/1024"| bc`
	java_pmc=`echo "scale=1;${pmc}/1024"| bc`
	java_pmu=`echo "scale=1;${pmu}/1024"| bc`

	echo ${java_oc}" "${java_ou}" "${java_pmc}" "${java_pmu}" "${fgc}" "${fgct} >/tmp/java_gc

}

for((i=1;i<=6;i++))
do
	f_main $1 2>/dev/null &
	sleep 10
done
#f_main $1
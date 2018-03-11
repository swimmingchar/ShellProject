#!/bin/bash
#------swiming------
#说明：  日志解压
#时间：20180116
#version:0.1
#filename:unzip.sh
export LANG=en_US.utf-8

unzip_main() {
	#解压路径
	unzip_path="/opt/catlogs/all"
	#获取时间
	unzip_date=`date +%Y%m%d`
	del_date=`date -d '8 days ago' +%Y%m%d`
	zip_path="/backup/logbak"
	#解压密码
	unzip_pass="HzYb?2016"

	find ${zip_path} -type f -name "*${unzip_date}*" >/tmp/${unzip_date}_tmp.txt
	#开始解压
	echo -e ${unzip_date} "zip start unzip at `date +%H:%M:%S`!\n"
	while read unzip_filename ; do
		#openssl enc -d -des3 -k HzYb?2016 -in payment-channel-web_201801130005.tar.gz |tar xzv
		unzip_appname=`echo ${unzip_filename}|awk -F/ {'print $4'}`
		unzip_ip=`echo ${unzip_filename}|awk -F/ {'print $5'}`
		test -d ${unzip_path}/${unzip_appname}/${unzip_ip} || mkdir -p ${unzip_path}/${unzip_appname}/${unzip_ip}
		/usr/bin/openssl enc -d -des3 -k ${unzip_pass} -in ${unzip_filename} |tar -xzv --strip-components 1 -C ${unzip_path}/${unzip_appname}/${unzip_ip}
		if [[ $? ]]; then
			cd ${unzip_path}/${unzip_appname}/${unzip_ip}
			`whereis gzip|awk {'print $2'}` -d *.gz
			echo -e ${unzip_filename}" untar at `date +%H:%M:%S` success!\n"
		fi
	done </tmp/${unzip_date}_tmp.txt

	[[ $? ]] && echo -e ${unzip_date} "all zip success unzip at `date +%H:%M:%S`!\n\n\n"

	##日志删除
	find ${unzip_path} -type f -name "*${del_date}*" >/tmp/del_${unzip_date}_tmp.txt
	while read del_filename ; do
		test -f ${del_filename} && rm ${del_filename} && echo -e ${del_filename}&" Delete success! at `date +%H:%M:%S`\n" || echo -e ${del_filename}&" Delete FAIL! at `date +%H:%M:%S`\n"
	done < /tmp/del_${unzip_date}_tmp.txt

	[[ $? ]] && echo -e "7 days ago all log delete at `date +%H:%M:%S`!\n\n\n"

}

unzip_main 1>& /tmp/unzip_`date +%Y%m%d`.log
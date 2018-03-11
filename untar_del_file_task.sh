#!/bin/bash
#------swiming------
#说明：日志解压
#时间：
#version:1.1
#filename:untar_del_file.sh
#userinfo:/var/tmp/script/untar_del_file_task.sh payment-channel-web_201801130005.tar.gz
export LANG=en_US.utf-8
log_path="/var/tmp/script"

unzip_main() {
	#解压路径:
	unzip_path="/opt/catlogs/all"
	#备份文件路劲
	zip_path="/backup/logbak"
	#日志存留时间
	del_date=`date -d '8 days ago' +%Y%m%d`
	#解压文件名
	unzip_name=$1
	#解压应用名
	unzip_appname=cat ${unzip_main}| awk -F_ {‘print $1’}
	#解压file,exp:payment-channel-web_201801130005
	unzip_signe=cat ${unzip_main}| awk -F. {‘print $1’}
	#中转文件，用于存放解压中间数据，最后可删除
	file_tmp=${log_path}/logs/temp_${unzip_signe}.list
	test -f ${file_tmp} && cat /dev/null > ${file_tmp}
	#删除文件列表--需要确定有没有一个文件传给我两次的情况
	del_list=${log_path}/logs/del_${unzip_signe}.list
	test -f ${del_list} && cat /dev/null > ${del_list}
	#一天汇总删除文件列表
	del_list_all=${log_path}/logs/all_del_${del_date}.list
	test -f ${del_list_all} && cat /dev/null > ${del_list_all}
	#错误日志
	err_list=${log_path}/logs/err_${del_date}.list
	test -f ${err_list} && cat /dev/null > ${err_list}
	#解压密码
	unzip_pass="HzYb?2016"

	unzip_appname_ip=`ls -1 ${zip_path}/${unzip_appname}/`

	#开始解压
	echo -e ${unzip_name} "zip start unzip at `date +%H:%M:%S`!\n"

	for unzip_ip in ${unzip_appname_ip}; do
		unzip_filename=${zip_path}/${unzip_appname}/${ip}/${unzip_name}
		#如果有文件，解压，否则继续
		if [[ -f ${unzip_filename} ]]; then
			test -d ${unzip_path}/${unzip_appname}/${unzip_ip} || mkdir -p ${unzip_path}/${unzip_appname}/${unzip_ip}
			/usr/bin/openssl enc -d -des3 -k ${unzip_pass} -in ${unzip_filename} |tar -xv -C ${unzip_path}/${unzip_appname}/${unzip_ip}|tee ${file_tmp}
		elif
			echo ${unzip_filename}" is not in! at "`date +%H:%M:%S`!\n
		fi

		#添加删除文件列表全路径
		echo -e "\n\n"${unzip_appname}-${unzip_ip}" 删除文件列表如下："
		while read line ;do
			new_file=`echo ${line}|cut -d/ -f 2| awk -F.gz {'print $1'}`
			echo -e ${unzip_path}/${unzip_appname}/${unzip_ip}/${new_file}|tee -a ${del_list}
		done < ${file_tmp}

		#第二次解压开始
		echo -e "\n"${unzip_appname}-${unzip_ip}"UNGZ!"
		if [[ $? ]]; then
			/bin/gzip -d ${unzip_path}/${unzip_appname}/${unzip_ip}/*.gz
			echo -e "\n"${unzip_filename}" untar at `date +%H:%M:%S` success!\n"
		fi
	done


	#删除日志
	del_all_day_file_list=`find ${log_path}/logs -name "del_${del_date}*.list" `

	if [[ "" != "${del_all_day_file_list}" ]]; then
		#汇总删除文件列表至删除list
		for i in ${del_all_day_file_list}; do
			cat $i >> ${del_list_all}
		done

		while read del_filename ; do
			test -f ${del_filename} && rm ${del_filename} && echo -e "rm "${del_filename}"\n"${del_filename}" delete success! at `date +%H:%M:%S`\n" || echo -e ${del_filename}" delete fail! at `date +%H:%M:%S`\n">>${err_list}
		done < ${del_list_all}
	else
		echo -e "no file need delete on "${unzip_date}
	fi

	#删除临时文件
	test -f ${log_path}/logs/${file_list_tmp} && rm ${log_path}/logs/${file_list_tmp}

	#删除定时任务
	#导出
	/usr/bin/crontab -l >/tmp/crontab.untar.list
	#过滤
	sed -i  /#untar_task/d /tmp/crontab.untar.list
	#还原
	/usr/bin/crontab /tmp/crontab.untar.list
}

unzip_main $1 1>& ${log_path}/logs/$1-`date +%s`.log
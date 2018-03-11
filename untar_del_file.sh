#!/bin/bash
#------swiming------
#说明：日志解压
#时间： 201801240020/201801240005
#version:0.2
#filename:untar_del_file.sh
#userinfo:/var/tmp/script/untar_del_file.sh 201801240005
export LANG=en_US.utf-8
log_path="/var/tmp/script"

unzip_main() {
	#解压路径:
	unzip_path="/opt/catlogs/all"
	#备份文件路劲
	zip_path="/backup/logbak"
	#解压参数
	unzip_date=$1
	#日志删除时间定义
	del_date=`date -d '8 days ago' +%Y%m%d`
	#解密解压文件列表
	untar_list=${log_path}/logs/untar_${unzip_date}.list
	test -f ${untar_list} && cat /dev/null>${untar_list}
	#每次解压生成删除文件列表
	del_list=${log_path}/logs/del_${unzip_date}.list
	test -f ${del_list} && cat /dev/null > ${del_list}
	#一天汇总删除文件列表
	del_list_all=${log_path}/logs/all_del_${del_date}.list
	test -f ${del_list_all} && cat /dev/null > ${del_list_all}
	#中转文件，用于存放解压中间数据，最后可删除
	file_list_tmp=${log_path}/logs/tar_temp_${unzip_date}.list
	test -f ${file_list_tmp} && cat /dev/null > ${file_list_tmp}
	#错误日志
	err_list=${log_path}/logs/err_${unzip_date}.list
	test -f ${err_list} && cat /dev/null > ${err_list}
	#解压密码
	unzip_pass="HzYb?2016"

	find ${zip_path} -name "*${unzip_date}.tar.gz" >${untar_list}
	#开始解压
	echo -e ${unzip_date} "zip start unzip at `date +%H:%M:%S`!\n"
	while read unzip_filename ; do
		#openssl enc -d -des3 -k HzYb?2016 -in payment-channel-web_201801130005.tar.gz |tar xzv
		unzip_appname=`echo ${unzip_filename}|awk -F/ {'print $4'}`
		unzip_ip=`echo ${unzip_filename}|awk -F/ {'print $5'}`

		test -d ${unzip_path}/${unzip_appname}/${unzip_ip} || mkdir -p ${unzip_path}/${unzip_appname}/${unzip_ip}
		/usr/bin/openssl enc -d -des3 -k ${unzip_pass} -in ${unzip_filename} |tar -xv -C ${unzip_path}/${unzip_appname}/${unzip_ip} | tee ${file_list_tmp}

		#添加删除文件列表全路径
		echo -e "\n\n"${unzip_appname}-${unzip_ip}" 删除文件列表如下："
		while read line ;do
			new_file=`echo ${line}|cut -d/ -f 2| awk -F.gz {'print $1'}`
			echo -e ${unzip_path}/${unzip_appname}/${unzip_ip}/${new_file}|tee -a ${del_list}
		done < ${file_list_tmp}

		if [[ $? ]]; then
			cd ${unzip_path}/${unzip_appname}/${unzip_ip}
			`whereis gzip|awk {'print $2'}` -d *.gz
			echo -e "\n"${unzip_filename}" untar at `date +%H:%M:%S` success!\n"
		fi
	done < ${untar_list}

	[[ $? ]] && echo -e ${unzip_date} " all tar success unzip at `date +%H:%M:%S`!\n\n\n"

	##日志删除
	test -f ${log_path}/del_${del_date}.list && rm ${log_path}/del_${del_date}.list
	#get del_filelist
	del_filename_list=`find ${log_path}/logs -name "del_${del_date}*.list" `

	if [[ "" != "$del_filename_list" ]]; then
		#汇总删除文件列表至删除list
		for i in ${del_filename_list}; do
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
}

test -d ${log_path}/logs || mkdir -p ${log_path}/logs

unzip_main $1 1>& ${log_path}/logs/$1.log
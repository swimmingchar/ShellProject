#!/bin/bash
#移动备份文件到磁带机目录

#日期不带"-"的月份截取方法：awk -F"2016" {'print $2'}|cut  -c1,2
#
#日期带"-"的月份截取方法：awk -F"2016" {'print $2'}|awk -F"-" {'print $2'}

copyBackFile(){
	#$1: 全路径文件名;#$2: 文件名;#$3: 月份

	#检查并创建文件夹
	getAppName=`echo $1|awk -F/ {'print $4'}| head -1`
	getFileIp=`echo $1|awk -F/ {'print $5'}| head -1`
	typeBackPath="/backup/typeback/2016/"$3"/"${getAppName}"/"${getFileIp}"/"
	test -d ${typeBackPath} || mkdir -p ${typeBackPath} >> ${mkPath} && mv $1 ${typeBackPath} >> ${moved_comd} && echo $1" to "${typeBackPath}" successed!" >> ${moved}
}


#变量
moved="moved`date +%s`.log"
test -f ${moved} || cat /dev/null > ${moved}
flshFile="flshFile`date +%s`.log"
test -f ${flshFile} || cat /dev/null > ${flshFile}
noFlshFile="noFlshFile`date +%s`.log"
test -f ${noFlshFile} || cat /dev/null > ${noFlshFile}
#测试使用
#mkPath="mkPath`date +%s`.log"
#test -f ${mkPath} || cat /dev/null > ${mkPath}
#moved_comd="moved_comd`date +%s`.list"
#test -f ${moved_comd} || cat /dev/null > ${moved_comd}


while read line ; do
	#判断标识
	Ft=1
	#月份带斜杠判断标识
	flshGet=`basename ${line} |awk -F"2016" {'print $2'}|awk -F"-" {'print $2'} `
	noFlshGet=`basename ${line} |awk -F"2016" {'print $2'}|cut  -c1,2 `
	test -f ${line} && \
	case ${flshGet} in
		01|02|03|04|05|06|07|08|09|10|11|12)
			Ft=0
			echo "flshFile:" ${line} >> ${flshFile}
			copyBackFile ${line} `basename ${line}` ${flshGet}
			;;
	esac

	test -f ${line} && [[ ${Ft} == "1" ]] && \
	case ${noFlshGet} in
		01|02|03|04|05|06|07|08|09|10|11|12)
			echo "noFlshFile:" ${line} >> ${noFlshFile}
			copyBackFile ${line} `basename ${line}` ${noFlshGet}
			;;
	esac
done < /home/tomcat/test
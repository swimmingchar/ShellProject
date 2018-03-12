#!/bin/bash
#1、移动备份文件到磁带机目录
#2、检查文件是否备份成果，生产两个文件，noMoved*.log 和 movedFile*.log 两个文件
#注意：以上执行需要切换调用函数，后面跟随的文件不变。
#FileName:moveBackFile.sh
#日期不带"-"的月份截取方法：awk -F"2017" {'print $2'}|cut  -c1,2
#
#日期带"-"的月份截取方法：awk -F"2017" {'print $2'}|awk -F"-" {'print $2'}

copyBackFile(){
        #$1: 全路径文件名;#$2: 文件名;#$3: 月份

        #检查并创建文件夹
        getAppName=`echo $1|awk -F/ {'print $4'}| head -1`
        getFileIp=`echo $1|awk -F/ {'print $5'}| head -1`
        typeBackPath="/backup/typeback/2017/"$3"/"${getAppName}"/"${getFileIp}"/"
        #测试使用，只输出命令
        #test -d ${typeBackPath} || echo "mkdir -p ${typeBackPath}" > ${mkPath} && echo "cp $1 ${typeBackPath}" >> ${moved_comd} && echo $1" to "${typeBackPath}" successed!" >> ${moved}
        #实际操作，输出结果
        test -d ${typeBackPath} || mkdir -p ${typeBackPath} && cp $1 ${typeBackPath} && echo $1" to "${typeBackPath}" successed!" >> ${moved}
}

checkBackFile(){
        #$1 全路径文件名;$2:文件名；$3:月份，主要功能为检查文件是否有备份
        getAppName=`echo $1|awk -F/ {'print $4'}| head -1`
        getFileIp=`echo $1|awk -F/ {'print $5'}| head -1`
        typeBackFile="/backup/typeback/2017/"$3"/"${getAppName}"/"${getFileIp}"/"$2
        test -f ${typeBackFile} && echo ${typeBackFile}" is OK!" >>${movedFile} || echo  $1 " is not Moved!" >> ${noMoedFile}
}



#变量
moved="moved`date +%s`.log" #移动文件
test -f ${moved} || cat /dev/null > ${moved}
flshFile="flshFile`date +%s`.log" #带横杠文件
test -f ${flshFile} || cat /dev/null > ${flshFile}
noFlshFile="noFlshFile`date +%s`.log" #不带横杠文件
test -f ${noFlshFile} || cat /dev/null > ${noFlshFile}
noFile="noFile`date +%s`.log" #不符合要求文件
test -f ${noFile} || cat /dev/null > ${noFile}
noMoedFile="noMoved`date +%s`.log" #没有移动成功文件
test -f ${noMoedFile} || cat /dev/null > ${noMoedFile}
movedFile="movedFile`date +%s`.log" #移动成果文件
test -f ${movedFile} || cat /dev/null > ${movedFile}
#测试使用
#mkPath="mkPath`date +%s`.log"
#test -f ${mkPath} || cat /dev/null > ${mkPath}
#moved_comd="moved_comd`date +%s`.list"
#test -f ${moved_comd} || cat /dev/null > ${moved_comd}


while read line ; do
        #判断标识
        Ft=1
        #月份带斜杠判断标识
        flshGet=`basename ${line} |awk -F"2017" {'print $2'}|awk -F"-" {'print $2'} `
        noFlshGet=`basename ${line} |awk -F"2017" {'print $2'}|cut  -c1,2 `
        test -f ${line} && \
        case ${flshGet} in
            01|02|03|04|05|06|07|08|09|10|11|12)
              Ft=0
              echo "flshFile:" ${line} >> ${flshFile}
              copyBackFile ${line} `basename ${line}` ${flshGet}
              #checkBackFile ${line} `basename ${line}` ${flshGet}
              ;;
        esac

        test -f ${line} && [[ ${Ft} == "1" ]] && \
        case ${noFlshGet} in
            01|02|03|04|05|06|07|08|09|10|11|12)
              Ft=0
              echo "noFlshFile:" ${line} >> ${noFlshFile}
              copyBackFile ${line} `basename ${line}` ${noFlshGet}
              #checkBackFile ${line} `basename ${line}` ${noFlshGet}
              ;;
              * )
              echo "ortherFile:" ${line} >> ${noFile}
              ;;
        esac
        [[ "${Ft}" != "0" ]] && echo "noFile:" ${line} >> ${noFile}
done < $1
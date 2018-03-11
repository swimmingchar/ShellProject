#!/bin/bash
# Swimming for backup log on Appserver
# Time:2017-12-05
# Version:1.4.2
# Email:shiwm@ulic.com.cn
# Tel:18611170241
# Tag: change Transfer sytanx.

f_main(){
        ServerIP=`/sbin/ifconfig | grep "Bcast" | cut -d: -f2 | awk {'print $1'}|head -1|awk -F. {'print $3"."$4'}`             #IP3&4
        BackServerIP=$1
        BackPath=$2
        #get user name
        userName=`/usr/bin/whoami`
        #get daytime
        keepday=`date -d "4 day ago" +%d`
        delday=`date -d "5 day ago" +%d`
        #Get ALL Log ALLPATH
        PathList=`find /home/tomcat/app/ -mtime -6 -type f 2>/dev/null | grep logs| awk -F"/logs" {'print $1'}|/usr/bin/uniq`
        AppD=`date -d "4 day ago" +%Y%m%d`
        OldAppD=`date -d "3 day ago" +%Y%m%d`
        #del log tag
        rm -rf /var/tmp/.Transfer${userName}
        #TransferLog ${BackServerIP} ${BackPath}
        for AppPath in ${PathList}
        do
                #Change Path
                cd ${AppPath}
                AppNameList=`ls ${AppPath}/webapps`
                AppNameCount=`ls ${AppPath}/webapps|wc -l`
                #Ensure AppName is Not Null
                if [ ${AppNameCount} -gt 0 ];then
                        cd ${AppPath}/logs
                        AppName=`echo ${AppNameList}|sed 's/\( \)\+/\n/g'|/usr/bin/head -1`
                        #Get tarlogList
                        TarLogList=`find . -mtime -6 -type f 2>/dev/null|xargs ls -lh|awk '$7==day' day=${keepday}|awk '{print $NF}'`
                        TmpLog=/var/tmp/logs/${AppName}/${ServerIP}/${AppD}
                        #mkdir filedoer
                        /bin/mkdir -p ${TmpLog}
        		TransferLog ${BackServerIP} ${BackPath}
			if [ -n "${TarLogList}" ];then
                        #New gt 2app write log
                        if [ ${AppNameCount} -gt 1 ];then
                                echo ${AppNameList}|sed 's/\( \)\+/\n/g' >>/var/tmp/logs/${AppName}/${ServerIP}/app.readme
                        fi
                        echo "Tar log Start:"${AppName}"------"`date` >> /var/tmp/logs/.log.rf${userName}
                        tar -czvPf - ${TarLogList}|/usr/bin/openssl enc -e -des3 -k HzYb?2016 -out ${TmpLog}/${AppName}"-"${AppD}.tgz >>/var/tmp/logs/.log.rf${userName}
                        #Trans
                        echo "Transfer log Start:"${AppName}"------"`date` >> /var/tmp/logs/.log.rf${userName}
                        #del log tag
                        rm -rf /var/tmp/.Transfer${userName}
                        TransferLog ${BackServerIP} ${BackPath}
                        echo "Delete befor yesterday log Start:"${AppName}"------"`date` >> /var/tmp/logs/.log.rf${userName}
                        #Delete log
                        find . -mtime -7 -type f 2>/dev/null|xargs ls -lh|awk '$7==day' day=${delday}|awk {'print $NF'}|xargs rm -rf
                        #delete Tar log
                        if [ -d "/var/tmp/logs/${AppName}/${ServerIP}/${OldAppD}" ];then
                                rm -rf /var/tmp/logs/${AppName}/${ServerIP}/${OldAppD} >>/var/tmp/logs/.log.rf${userName}
                                echo "The "${AppName}" END! ------"`date` >> /var/tmp/logs/.log.rf${userName}
                        else
                                echo "The /var/tmp/logs/"${AppName}/${ServerIP}/${OldAppD}"------no!-----"`date` >> /var/tmp/logs/.log.rf${userName}
                        fi
			fi
                else
                        countinue
                fi
        done

        #transfer Log
}

TransferLog(){
        for conut in `seq 240`
        do
                isfile=/var/tmp/.Transfer${userName}
                if [ ! -f "${isfile}" ];then
                        /usr/bin/rsync -avzP --bwlimit=5000 --password-file="/var/tmp/scripts/rsync.pwd" /var/tmp/logs/ test@${1}::${2}
                        #error no rsync or rsync error
                        if [ $? -eq 0 ];then
                                /bin/touch /var/tmp/.Transfer${userName}
                                return
                        fi
                else
                        return
                fi
                sleep 10
        done
}
f_main $1 $2

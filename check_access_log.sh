#！/bin/bash
#Path:/var/tmp/scripts/check_access_log.sh
#Get Data & Time
    
DATE_Str=`/bin/date +%Y-%m-%d`
TIME_Str=`/bin/date +%Y:%H:%M`

if [[ ! -z $*  ]];then
    DATE_Str=$1
    TIME_Str=$2
fi


CHECK_ARG=" 404 | 500 "

grep "${TIME_Str}" /home/tomcat/app/logs/localhost_access_log."${DATE_Str}".txt | /bin/egrep "${CHECK_ARG}" |awk -F" " '{print $1,$2,$7,$8,$9,$10}'  >/tmp/localhost_access_log


/usr/bin/ansible -i hostall 10.10.20.33 -m raw -a "grep -r \"10.10.20.40\" /home/tomcat/app/webapps/ulpay-core/WEB-INF/classes/ | grep "properties"
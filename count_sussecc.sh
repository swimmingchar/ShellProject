#!/bin/bash
slave_cfile="/tmp/slave.num"
master_cfile="/tmp/master.unm"

#count slave
/usr/bin/ansible-playbook -i /u01/CMSS_WORKDIR/etc/HostGroups/Slave/basecmm-riskfront-core get_success.yml|grep num.stdout| awk -F'"' {'print $4'}> ${slave_cfile}
count_node=`wc -l ${slave_cfile} | awk {'print $1'}`
count_time=`head -1 ${slave_cfile} |awk -F'-' {'print $1'} |awk {'print $1'}`
#slave_out=`awk -F`

cat ${slave_cfile}|while read line; do
	[[ $num ]] && ${bs}="第 1 个节点成功笔数：" & `cut -d'-' -f 2 ${line}` & "\n" || ${bs}=${bs} & "第 "${i}" 个节点成功笔数：" & `cut -d'-' -f 2 ${line}` & "\n"
	num+=1
done

[[ $? ]] && ${bs}=${bs} & "总成功笔数：" `awk 'BEGIN{sum=0}{sum+=$2}END{print sum}' ${slave_cfile}`
echo -e ${bs}


#count master
/usr/bin/ansible-playbook -i /u01/CMSS_WORKDIR/etc/HostGroups/Master/basecmm-riskfront-core get_success.yml|grep num.stdout| awk -F'"' {'print $4'}> ${master_cfile}




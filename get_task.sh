#!/bin/bash
#readme:添加定时任务，一分钟后执行
#此脚本执行时需要再后面添加参数，目前暂定为压缩文件名。
task_hour=`date +%H`
task_minute=`date -d '1 minutes' +%M`
#保留原来的定时任务
/usr/bin/crontab -l > /tmp/crontab.tmp_old
#删除上次执行痕迹
sed -i  /#untar_task/d /tmp/crontab.tmp_old
#合并定时文件
echo /tmp/crontab.tmp_old>>/tmp/crontab.${task_hour}${task_minute}
#生产定时文件
echo ${task_minute} ${task_hour} "* * * /var/tmp/script/untar_del_file_task.sh $1  #untar_task" >/tmp/crontab.${task_hour}${task_minute}
#生效定时文件
/usr/bin/crontab /tmp/crontab.${task_hour}${task_minute}
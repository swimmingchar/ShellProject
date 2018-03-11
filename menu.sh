#!/bin/bash
#menus
#

f_main_meun(){
	cat << EOF
--------------请选择机房--------------
1：主机房
2：备机房
3：退出
EOF

read -p "你的选择是：" input
case $inpu in
	1 ) master_menu;;
	2 ) slave_menu;;
	3 ) m_quit;
esac

}

#菜单返回 必须带参数0->1级，1->2级
m_back(){

case $1 in
	0 ) f_main_meun;;
	1 ) s_meun;;
esac
}

#菜单退出
m_quit(){exit 0}





f_main_meun






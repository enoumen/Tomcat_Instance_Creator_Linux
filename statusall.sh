#!/bin/sh

#App Name List
App_List_Path="/u01/apache_tomcat_group/Instances"
App_List=`ls -l --time-style="long-iso" $App_List_Path | egrep '^d' | gawk '{print $8}'`

# Stop all servers
for App_Name in ${App_List[@]}
do
  ps -ef | grep $App_Name | grep java | grep tomcat | grep start > /dev/null
  if [ $? -eq 0 ]; then
     echo "$App_Name is  running" 
  else
     echo "$App_Name is not running."
  fi
done


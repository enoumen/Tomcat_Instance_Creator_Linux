#!/bin/sh

#App Name List
App_List_Path="/u01/apache_tomcat_group/Instances"
App_List=`ls -l --time-style="long-iso" $App_List_Path | egrep '^d' | gawk '{print $8}'`

# Stop all servers
for App_Name in ${App_List[@]}
do
  ps -ef | grep $App_Name | grep java | grep tomcat | grep start > /dev/null
  if [ $? -eq 0 ]; then
   echo "$App_Name is already running: No need to re-start" 
  else
     /u01/bin/tomcat_server.sh start $App_Name > /dev/null
     sleep 5
     PID=`ps -ef | grep $App_Name | grep java | grep tomcat | grep start | gawk '{print $2}'`
     if [ -z "$PID" ]; then
       echo "$App_Name is still not running after attempted start: Investigate further"
     else
       echo "$App_Name is running."
     fi  
  fi
done

